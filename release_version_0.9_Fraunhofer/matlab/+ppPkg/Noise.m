%> @file Noise.m
%> @brief Class for noise calculation
% ======================================================================
%> @brief Contains algorithms for noise calculation
%
%> 
% ======================================================================
classdef Noise < matlab.mixin.Copyable
    % Noise class contain noise measurments for all transducer channels 
    %    
    properties (SetAccess = private)        
        %> Matrix containing PSD for each channel
        psdMatrix           
        %> Mean value of PSD in a given range 
        meanPsd             
        %> Variance of PSD in a given range
        varPsd  
        %> Reference to configuration class
        config        
    end
    
    methods      
                  
        %======================================================================
        %> @brief Constructor to the Noise class
        %>
        %> @param config instance of the Configuration class
        %> @retval obj instance of the Noise class
        % ======================================================================         
        function obj = Noise(config)
            import ppPkg.Configuration;
            
            if(isa(config,'Configuration'))
                obj.config = config;
            else
                error('Noise constructor: Configuration object is of wrong type')
            end  
            
            if nargin == 1                
                psdLength = config.FFT_LENGTH/2 + 1;
                obj.psdMatrix = zeros(obj.config.NUMBER_OF_CHANNELS, psdLength);
                obj.meanPsd = zeros(obj.config.NUMBER_OF_CHANNELS, 1); 
                obj.varPsd = zeros(obj.config.NUMBER_OF_CHANNELS, 1);                                 
            else
                error('Not enough arguments to constructor')
            end
        end
        
        % ======================================================================
        %> @brief Set function for config
        %>
        %> @param obj instance of the Noise class.
        %> @param configuration Configuration object                
        % ======================================================================            
        function setConfiguration(obj, configuration)
           obj.config = configuration; 
           psdLength = configuration.FFT_LENGTH/2 + 1;
           obj.psdMatrix = zeros(obj.config.NUMBER_OF_CHANNELS, psdLength);           
        end  
        
        %======================================================================
        %> @brief Function returns Noise psd for given transducerId
        %>
        %> @param obj instance of the Noise class. 
        %> @param transducerId Transducer id
        % ====================================================================== 
        function noisePsd = psd(obj, transducerId)
            if transducerId <= 0
                error('TransducerId can not be negative or zero')
            elseif transducerId > obj.config.NUMBER_OF_CHANNELS
                error('TransducerId larger than number of channels')
            else
                noisePsd = obj.psdMatrix(transducerId,:);
            end
        end
        
        %======================================================================
        %> @brief Function calculates psd for the noise for the given
        %>        transducer
        %>        TODO: Need to decide what is the best method for
        %>        estimating the PSD of the noise. Pwelch or periodogram,
        %>        windowType, segmentlength and overlap.
        %>
        %> @param obj instance of the Noise class. 
        %> @param transducerId Transducer id
        %> @param noiseSignal noise signal
        %> @param enableTS Enable shaping of the psd to compensate for the
        %>                 transducer sensitivity
        %> @param method Psd method: pwelch or periodogram
        %> @param windowType Window type: hanning, hamming and rect
        %> @param varargin
        %> @retval psd
        %> @retval f
        % ====================================================================== 
        function [psd, f] = calculatePsd(obj, transducerId, noiseSignal, enableTS, method, windowType, varargin)            

            % Validate TransducerId
            obj.validateId(transducerId);             
            
            % Check PSD method
            if (strcmp(method,'pwelch'))
                disp('Pwelch method')
                if ~isempty(varargin)                    
                    
                    if(isnumeric(varargin{1}))
                        segmentLength = varargin{1};
                        % Using hamming window
                        [psd, f] = obj.calculatePsdUsingPWelch(noiseSignal, windowType, segmentLength);
                    else
                        error('Error in segmentLength, must be numeric')
                    end
                    
                else
                    error('Need to specify segment length, for pwelch')
                end
            elseif (strcmp(method,'periodogram'))            
                % Calculate PSD using periodogram
                % Calculate window
                win = obj.getWindow(windowType, length(noiseSignal));
                  
                [psd, f] = periodogram(noiseSignal, win, obj.config.FFT_LENGTH, obj.config.SAMPLE_RATE,'psd');  
            else                
                error('Method \"%s\" not supported. Supported methods are: \"pwelch\" and \"periodogram\"', method);                
            end
            
            if( enableTS )
                % Save PSD in dB(k*Fs/FFT) to psdMatrix
                obj.psdMatrix(transducerId,:) = 10*log10(psd) + obj.config.TS_ARRAY;         
            else
                obj.psdMatrix(transducerId,:) = 10*log10(psd);
            end
        end
        
        %======================================================================
        %> @brief Function calculates mean and variance for the Noise psd 
        %>         for the given transducer in the fLow and fHigh
        %>                 
        %> @param obj instance of the Noise class. 
        %> @param transducerId Transducer id
        %> @param fLow The lower frequency in the range
        %> @param fHigh The higher frequency in the range
        % ======================================================================         
        function [meanPsd, varPsd] = calculateMeanVarInRange(obj, transducerId, fLow, fHigh)
            
            % Validate TransducerId
            obj.validateId(transducerId);
            
            % Retrieve psd for given transducerId
            psd = obj.psdMatrix(transducerId,:);
            
            % Calculate range index
            startIndex = 1 + floor(fLow/(obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH));
            stopIndex = 1 + floor(fHigh/(obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH));
            
            % Calculate mean and variance for given range
            meanPsd = mean(psd(startIndex:stopIndex));
            varPsd = var(psd(startIndex:stopIndex));
            
            % Store calculation
            obj.varPsd(transducerId,:) = varPsd;
            obj.meanPsd(transducerId,:) = meanPsd;            
        end
        
        %======================================================================
        %> @brief Function plots the noise psd for the given transducer
        %>                 
        %> @param obj instance of the Noise class. 
        %> @param transducerId Transducer id
        % ======================================================================         
        function fig = plotPsd(obj, transducerId)
            
            psd = obj.psdMatrix(transducerId,:);
            
            % Frequency vector
            f = 0:obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH:obj.config.SAMPLE_RATE/2; 
            
            fig = plot(f, psd);
            title('Noise PSD')
            xlabel('Frequency')
            ylabel('dB')
            grid on
            
        end
        
        %======================================================================
        %> @brief Function calculates Noise psd using pwelch. 
        %>        50% overlap         
        %> @param obj instance of the Noise class. 
        %> @param signal Noise signal
        %> @param windowType Type of window: hanning, hamming or rect
        %> @param segmentLength Length of segment in number of samples        
        % ======================================================================          
        function [pxx, f] = calculatePsdUsingPWelch(obj, signal, windowType, segmentLength)
            %% Calculate Power Spectral density using pwelch
            % 90% overlap for each segment.
            % Properties that must be defined
            % Window type to use. pWelch uses hamming as default
            % Segment length            
            OVERLAP_FACTOR = 0.5;
            
            %R = (segmentLength - 1)/2;
            %overlap2 = segmentLength -R;
            
            window = obj.getWindow(windowType, segmentLength);

            % Calculate number of samples to be used as overlap
            overlap = ceil(OVERLAP_FACTOR * segmentLength);

            [pxx, f] = pwelch(signal, window, overlap, obj.config.FFT_LENGTH, obj.config.SAMPLE_RATE);

        end
        
        %======================================================================
        %> @brief Function calculate window to be used with PSD calculation
        %
        %> @param ignoredArg instance of the Noise class
        %> @param type Window type
        %> @param length Length of window in number of samples 
        % ======================================================================          
        function win = getWindow(~, type, length)
            % Select window 
            windowType = lower(type);
            
            switch windowType
                case 'rect'
                    win = rectwin(length);

                case 'hamming'
                    win = hamming(length);                    

                case 'hanning'
                    win = hanning(length);

                otherwise
                    error('Window type not supported');                    
            end                        
        end

        %======================================================================
        %> @brief Function validates transducer is within allowed range
        %>        
        %> @param obj instance of the Noise class. 
        %> @param transducerId Transducer Id        
        %> @retval id Transducer Id        
        % ======================================================================            
        function id = validateId(obj, transducerId)
            %% Validate transducerId is within allowed range
            if transducerId <= 0
                error('TransducerId can not be negative or zero')
            elseif transducerId > obj.config.NUMBER_OF_CHANNELS;
                error('TransducerId larger than number of channels')
            else
                id = transducerId;
            end 
        end
    end    
end

