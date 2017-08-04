%> @file ThicknessAlgorithm.m
%> @brief Class contains algorithms for calculating thickness
% ======================================================================
%> @brief Here we have a brief description of the class.
%
%> 
% ======================================================================
classdef ThicknessAlgorithm < matlab.mixin.Copyable
    % Class containing algorithms for calculating thickness of pipewall.
    %    
    
    % Local variables
    properties    
        
        %> index for start of main reflection pulse
        beginMain uint32           
        %> index for end of main reflection pulse
        endMain   uint32                     
        %> index for start of resonance part
        beginResonance  uint32               
        %> index for end of resonance part
        endResonance  uint32                 
        %> PSD for absorption segment
        psdMain             
        %> PSD for resonance segment 
        psdResonance               
        %> PSD for resonance segment calculated with pwelch 
        psdWelch        
        %> Frequency vector for PSD plot
        fVector             
        %> Harmonic Sets found in Resonance spectrum
        setResonance        
        %> Harmonic Sets found in Main reflection spectrum
        setMain             
        fLow     uint32 
        fHigh    uint32 
        meanNoiseFloor        
    end
    
    properties  (SetAccess = private)
        config 
        peakValueResonance
        peakLocationResonance
        peakProminenceResonance
        peakWidthResonance
        peakValueMain
        peakLocationMain
        peakProminenceMain
        peakWidthMain
        
        RESONANCE = 1;
        MAIN = 2;
    end
    
    properties (Access = private)
        psdResonanceMatrix
        lineIndexPsdResonanceSegments
        startPeakSearchIndex
        stopPeakSearchIndex       
    end
    
    methods
        %======================================================================
        %> @brief Find peaks in the psd 
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param psdType Type of psd to search for peaks: RESONANCE or MAIN
        %> @param fLow Start frequency to search
        %> @param fHigh Stop frequency
        %> @param method Peak find method
        % ======================================================================
        [peakLocation, peakValue, peakWidth, peakProminence] = findPeaksInPsd(obj, psdType, fLow, fHigh, method, varargin)
        
        %======================================================================
        %> @brief Function finds frequency sets
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param psdType Type of psd to search for peaks: RESONANCE or MAIN
        %> @param fLow Start frequency to search
        %> @param fHigh Stop frequency
        %> @param noHarmonics Minimum number of harmonics that the sets
        %>                    should contain
        % ======================================================================        
        [setsFound] = findFrequencySets(obj, psdType, fLow, fHigh, noHarmonics)
    end
    
    methods
        
        % ======================================================================
        %> @brief Class constructor
        %>
        %> @param configuration Configuration object        
        %> @return instance of the ThicknessAlgorithm class.
        % ======================================================================        
        function obj = ThicknessAlgorithm(configuration)
            import ppPkg.Configuration;
            
            if(isa(configuration,'Configuration'))
                obj.config = configuration;
            else
                error('ThicknessAlgorithm constructor: Configuration object is of wrong type')
            end            
        end
        
        % ======================================================================
        %> @brief Set function for config
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param configuration Configuration object                
        % ======================================================================           
        function setConfiguration(obj, configuration)
           obj.config = configuration; 
        end        
                
        %======================================================================
        %> @brief Function calculates start and stop index for absorption and
        %> @brief resonance part of the recorded signal
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal
        %> @param callipAlg instance of the CalliperAlgorithm class
        %> @param varargin Set varargin to 'plot' for plotting Psd       
        % ======================================================================        
        function status = calculateStartStopForAbsorptionAndResonance(obj, recordedSignal, callipAlg, varargin)        
        
            import ppPkg.*
            
            firstReflection = callipAlg.firstReflectionIndex;
            secondReflection = callipAlg.secondReflectionIndex;
            txPulseLength = length(callipAlg.txPulse);

            % Validate if there is enough samples to do calculations on the
            % resonance part of the signal
            resonanceMaxLength = abs(secondReflection - firstReflection) - txPulseLength;
            
            if(resonanceMaxLength < obj.config.PERIODOGRAM_SEGMENT_LENGTH)
                errorMsg = sprintf('calculateStartStopForAbsorptionAndResonance: Error 1: \nSegmentLength: (%d) must be less than length of resonance signal: %d\n', obj.config.PERIODOGRAM_SEGMENT_LENGTH, resonanceMaxLength );
                if(obj.config.DEBUG_INFO)
                    disp(errorMsg);
                end
                if( resonanceMaxLength < 250)
                    status = 0;
                    return;
                end
            end
            
            
            % Set begin and end index for reflected main pulse
            obj.beginMain = firstReflection - callipAlg.adjustBeginMain;
            obj.endMain = firstReflection + txPulseLength + obj.config.ADJUST_START_TIME_RESONANCE + callipAlg.adjustEndMain;
                                                             
            % Set begin and end index for resonance part of recorded signal
            obj.beginResonance = obj.endMain + 1;              
            obj.endResonance = obj.beginResonance + resonanceMaxLength - 1 - callipAlg.adjustEndMain + obj.config.ADJUST_STOP_TIME_RESONANCE - obj.config.ADJUST_START_TIME_RESONANCE; 
            
            if(obj.beginResonance >= obj.endResonance)
                errorMsg = sprintf('calculateStartStopForAbsorptionAndResonance: Error4: begin and resonance has illegal values ');
                if(obj.config.DEBUG_INFO)
                    disp(errorMsg);
                end
                status = 0;
                return;
            end

            resonanceLength = obj.endResonance - obj.beginResonance + 1;
            if( resonanceLength < obj.config.PERIODOGRAM_SEGMENT_LENGTH)
                errorMsg = sprintf('calculateStartStopForAbsorptionAndResonance: Error2: \nSegmentLength: (%d) must be less than length of resonance signal: %d\n', obj.config.PERIODOGRAM_SEGMENT_LENGTH, length(recordedSignal(obj.beginResonance:obj.endResonance)) );
                if(obj.config.DEBUG_INFO)
                    disp(errorMsg);
                end
                if( resonanceMaxLength < 250)
                    status = 0;
                    return;
                end   
                if( resonanceLength < 250)
                    status = 0;
                    return;
                end  
                 
            end
            
            % Check that endResonance index is not larger then end of
            % signal
            if(obj.endResonance > length(recordedSignal))
                obj.endResonance = length(recordedSignal);
                if(obj.config.DEBUG_INFO)
                    disp('calculateStartStopForAbsorptionAndResonance: Adjusted endResonance')
                end
            end
            
            % Plot signal with lines if requested
            if ~isempty(varargin)
                if (strcmp(varargin{1},'plot'))
                    figure
                    plot(recordedSignal) 
                    lineMax = max(recordedSignal);
                    line([obj.beginMain obj.beginMain],[lineMax,-lineMax],'color','r')
                    line([obj.endMain obj.endMain],[lineMax,-lineMax],'color','g')
                    line([obj.endResonance obj.endResonance],[lineMax,-lineMax],'color','r')
                    
                    title('Time signal')
                    xlabel('Samples')
                    ylabel('')
                    grid on
                end
            end            
            
            status = 1;
            return
            
        end
        
        %======================================================================
        %> @brief Function calculates Signal to Noise ratio        
        %>        Signal before main reflection is regarded as the noise
        %>        Main reflection is regarded as the signal
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal 
        %> @param noiseSignal
        % ======================================================================         
        function [snrOut ] = calculateSNR(obj, recordedSignal, noiseSignal)
            
            mainLength = obj.endMain - obj.beginMain;
            mainSignal = double(recordedSignal(obj.beginMain:(obj.endMain-1)));
            
            if( numel( noiseSignal ) >= mainLength)
                noiseSignalSample = double(noiseSignal(1:mainLength));

                snrOut = 20*log10((sqrt(mean(mainSignal.^2))/sqrt(mean(noiseSignalSample.^2))));
            else
                snrOut = 0;
            end
            
        end
        
        %======================================================================
        %> @brief Function calculated PSD for main and resonance part of recorded signal        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal        
        %> @param varargin Set varargin to 'plot' for plotting Psd       
        % ======================================================================           
        function [psdResonance, psdMain] = calculatePsd(obj, recordedSignal)
                        
            % Calculate Psd Main
            obj.calculatePsdMain( recordedSignal );            
            psdMain = obj.psdMain;
            
            % Calculate Psd Resonance
            obj.calculatePsdResonance( recordedSignal );            
            psdResonance = obj.psdResonance;
                        
            % Adjust PSD according to Transducer sensitiviy if enabled
            if(obj.config.TS_ADJUST_ENABLE)
                obj.transducerSensitivityAdjust();
            end                                   
        end

        %======================================================================
        %> @brief Function calculates PSD of reflected main pulse        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================    
        function [psd, f] = calculatePsdMain(obj, recordedSignal)
            %% Function calculates PSD for reflected main pulse
            
            if(obj.beginMain <= 0)
                obj.beginMain = 1;
            end
            
            mainLength = obj.endMain - obj.beginMain;
            mainSignal = recordedSignal(obj.beginMain:(obj.endMain-1));
                       
            % Window type should be taken from config
            mainWindow = obj.getWindow(obj.config.WINDOW_MAIN, double(mainLength));
            
            % Calculate PSD using periodogram
            [psd, f] = periodogram(mainSignal, mainWindow, obj.config.FFT_LENGTH, obj.config.SAMPLE_RATE, 'psd');
            
            % Convert to dB
            psdDb = 10*log10(psd);         
            
            % Store psd main            
            obj.psdMain = double(psdDb);
            obj.fVector = double(f);
            
        end

        %======================================================================
        %> @brief Function calculates FFT of main
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================   
        function [P, f] = calculateFFTMain(obj, recordedSignal)
            
            if(obj.beginMain <= 0)
                obj.beginMain = 1;
            end
                        
            mainSignal = recordedSignal(obj.beginMain:(obj.endMain-1));            
            
            Y = fft( mainSignal,  obj.config.FFT_LENGTH);
            f = obj.config.SAMPLE_RATE*(0:(obj.config.FFT_LENGTH/2))/obj.config.FFT_LENGTH;
            P = abs(Y/obj.config.FFT_LENGTH);

%             figure
%             plot(f,P(1:thicknessAlg.config.FFT_LENGTH/2+1))
%             title('')
%             xlabel('Frequency (f)')
%             ylabel('|P(f)|')            
            
        end

        
        %======================================================================
        %> @brief Function calculates PSD of resonance part of signal        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================    
        function [psd, f] = calculatePsdResonance(obj, recordedSignal)
            %% Function calculates PSD for resonance signal
            %  
                        
            resonanceSignal = recordedSignal(obj.beginResonance:obj.endResonance);
            
            if(obj.config.USE_PWELCH)
                
                if(length(resonanceSignal) < obj.config.MAX_WELCH_LENGTH)
                    pwelchSegment = resonanceSignal;
                else
                    pwelchSegment = resonanceSignal(1:obj.config.MAX_WELCH_LENGTH);
                end
                
                if(length(pwelchSegment) < obj.config.PERIODOGRAM_SEGMENT_LENGTH)                                
                    [psdWelch, f] = obj.calculatePsdUsingPWelch(pwelchSegment, obj.config.WINDOW_RESONANCE, length(pwelchSegment), obj.config.FFT_LENGTH, obj.config.SAMPLE_RATE);                              
                else
                    [psdWelch, f] = obj.calculatePsdUsingPWelch(pwelchSegment, obj.config.WINDOW_RESONANCE, obj.config.PERIODOGRAM_SEGMENT_LENGTH, obj.config.FFT_LENGTH, obj.config.SAMPLE_RATE);            
                end
                
                psdWelchdB = 10*log10(psdWelch);

            else
                % Calculate PSD using periodogram with overlap
                [obj.psdResonanceMatrix, f, ~, obj.lineIndexPsdResonanceSegments] = obj.calculatePsdUsingPeriodogram( resonanceSignal, obj.config.WINDOW_RESONANCE, obj.config.PERIODOGRAM_SEGMENT_LENGTH, obj.config.PERIODOGRAM_OVERLAP, obj.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE );            
            end                        
            
            if(obj.config.USE_PWELCH)
                psd = psdWelchdB;
            elseif(obj.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE == 1 )
                psd = obj.psdResonanceMatrix(1,:)';
            else
                psd = mean(obj.psdResonanceMatrix(1:obj.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE,:))';
            end                        
            
            obj.psdResonance = double(psd);
            
        end
        
        %======================================================================
        %> @brief Function plots psd for main and resonance 
        %>        and draw lines for start and stop for the main
        %>        reflection part and resonance part of the signal
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================          
        function plotPsd(obj, recordedSignal)
            % Function plots time signal, psd resonance and psd main in
            % on figure. 
            
            figure
            subplot(3,1,1)
            plot(recordedSignal)  
            lineMax = max(recordedSignal);
            line([obj.beginMain obj.beginMain],[lineMax,-lineMax],'color','r')
            line([obj.endMain obj.endMain],[lineMax,-lineMax],'color','g')
            line([obj.endResonance obj.endResonance],[lineMax,-lineMax],'color','r')
            title('Time signal')
            xlabel('Samples')
            ylabel('')
            grid on; grid minor
            
            subplot(3,1,2)
            plot(obj.fVector, obj.psdMain)
            title('Main Power Spectrum')
            xlabel('Frequency')
            ylabel('dB')
            grid on; grid minor
            
            subplot(3,1,3)
            plot(obj.fVector, obj.psdResonance)
            title('Resonance Power Spectrum')
            xlabel('Frequency')
            ylabel('dB')
            grid on;grid minor
        end
        
        %======================================================================
        %> @brief Function plots psd for each periodogram segment
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================            
        function plotPeriodogramSegments(obj, recordedSignal)
            %% Function plot periodogram segments for psd resonance
            lineMax = max(recordedSignal);
            
            for index = 1:obj.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE        
                figure('units','normalized','outerposition',[0 0 1 1])
                subplot(2,1,2)
                plot(recordedSignal)
                startLine = obj.lineIndexPsdResonanceSegments(index,1)+obj.beginResonance;
                stopLine = obj.lineIndexPsdResonanceSegments(index,2)+obj.beginResonance;
                line([startLine startLine],[lineMax,-lineMax],'color','g')
                line([stopLine stopLine],[lineMax,-lineMax],'color','r')
                subplot(2,1,1)
                plot(obj.fVector, obj.psdResonanceMatrix(index,:))
                ylim([ -160 -80 ])
                grid on        
            end
        end
        
        %======================================================================
        %> @brief Experimental function for removing frequencies 
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================          
        function removeFrequency(obj, freq)            
            
            index = 1 + round((freq * obj.config.FFT_LENGTH) / ... 
                obj.config.SAMPLE_RATE);
            
            indexMax = 1 + round((freq * 1.05 * obj.config.FFT_LENGTH) / ... 
                obj.config.SAMPLE_RATE);
            
            indexMin = index - (indexMax - index);
            
            % Second impl; match a range centered around index.
            idxl = (obj.peakLocationResonance > indexMin) & ...
                (obj.peakLocationResonance < indexMax);            
            
            % Remove frequency from location, prominence, value and width
            % array
            obj.peakLocationResonance = obj.peakLocationResonance(~idxl);
            obj.peakProminenceResonance = obj.peakProminenceResonance(~idxl);
            obj.peakValueResonance = obj.peakValueResonance(~idxl);
            obj.peakWidthResonance = obj.peakWidthResonance(~idxl);            
        end
        
        %======================================================================
        %> @brief Function calculates several PSDs of overlapping segements
        %>        of the input signal
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param x input signal
        %> @param windowType Window function: 'hanning', 'hamming', 'rect'
        %> @param segmentLength Length in number of samples for each segment 
        %> @param overlap Overlap in percentage ( 0 - 0.9 )              
        %> @param maxNumberPsd Number of psd segments       
        %> @retval psdArray Array of psd for each segment
        %> @retval fArray Frequency array
        %> @retval numberOfPsd Number of PSDs calculated 
        %> @retval lineIndex Array og start and stop indecies for each
        %>         segment
        % ======================================================================          
        function [psdArray, fArray, numberOfPsd, lineIndex] = calculatePsdUsingPeriodogram(obj, x, windowType, segmentLength, overlap, maxNumberPsd )
 
            startIndex = 1;
            stopIndex = startIndex + segmentLength;
            if(stopIndex > length(x))
                stopIndex = length(x);
            end
            
            % Get window for length equal to segmentLength or remaining
            % signal
            window_ = obj.getWindow(windowType, stopIndex - startIndex);
            
            % Init arrays
            psdArray = zeros(maxNumberPsd,1+obj.config.FFT_LENGTH/2);
            lineIndex = zeros(maxNumberPsd, 2);
            
            i = 1;
            while(startIndex < length(x) && i < maxNumberPsd+1)
                
                % If lenght of remaining signal is less than segmentLength
                % calculate a new window. 
                if(length( x(startIndex:stopIndex-1) ) < length(window_))
                    
                    window_ = obj.getWindow(windowType, length( x(startIndex:stopIndex-1)));            
                end
                
                % Calculated psd using periodogram
                [psdArrayTemp, fArray] = periodogram(x(startIndex:stopIndex-1), window_, obj.config.FFT_LENGTH, obj.config.SAMPLE_RATE, 'psd');
                
                % Convert to dB
                psdArray(i,:) = 10*log10(psdArrayTemp);
                
                % Save start and stop index for the segment
                lineIndex(i,:) = [startIndex, stopIndex];
               
                % Calculate next startIndex and stopIndex
                startIndex = startIndex + round(segmentLength*(1-overlap));
                stopIndex = startIndex + segmentLength;
                if(stopIndex > length(x))
                    stopIndex = length(x);
                end
                
                % Increment i
                i = i + 1;                    
            end
                        
            numberOfPsd = i-1;
        end
        
        %======================================================================
        %> @brief Function calculates psd using welch method
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param x
        %> @param windowType
        %> @param segmentLength
        %> @param nfft
        %> @param fs        
        % ======================================================================         
        function [pxx, f] = calculatePsdUsingPWelch(obj, x, windowType, segmentLength, nfft, fs)
            %% Calculate Power Spectral density using pwelch            
            window = obj.getWindow(windowType, segmentLength);

            % Calculate number of samples to be used as overlap
            overlap = floor(obj.config.PERIODOGRAM_OVERLAP * segmentLength);
            
            % Calculate psd using welch method
            [pxx, f] = pwelch(x, window, overlap, nfft, fs, 'mean');

        end        
            
        %======================================================================
        %> @brief Function for adjusting the resonance psd with a
        %>        transducer sensitivity array
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================           
        function transducerSensitivityAdjust(obj)
            %% Adjust PSD with transducer sensitivity array                                
            obj.psdResonance = obj.psdResonance + obj.config.TS_ARRAY;                                   
        end
        
        %======================================================================
        %> @brief Experimental function for calculating the thickness by
        %>        analyzing the resonance part of the time-signal.
        %>        
        %>        Calculates thickness based on finding the time between two signal
        %>        leaks out of pipe wall
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param recordedSignal transducer recorded signal                
        % ======================================================================         
        function thickness = calculateThicknessTimeSigRes(obj, signal, txPulse)
        %% Calculate thichness based on anaylzing resonance part of time-signal
            % Assume that beginResonance and endResonance is set.

        
            % Cross correlate resonance part of signal with emitted pulse
            [r, lags] = xcorr(double(signal), txPulse);           
            
            
            absR = abs(r);
            [maxR, maxRIndex] = max(absR);
            
            testSignal = r(maxRIndex:end);
            [pxx,f] = periodogram(testSignal,[],[],15.5e6);
            
            minPeakDistance = (obj.config.D_NOM * obj.config.SAMPLE_RATE ) / obj.config.V_WATER;
            %, 'MinPeakDistance', 
            
            
            % Find the two tallest peaks. Minimum peak height is set to 3dB
            % below max
            [~, lc] = findpeaks(r(maxRIndex+length(txPulse):end), 'SortStr','descend','NPeaks', 2, 'MinPeakHeight',max(r(maxRIndex+length(txPulse):end))/2 ,'MinPeakDistance', minPeakDistance);
            figure
            findpeaks(r(maxRIndex+length(txPulse):end), 'SortStr','descend','NPeaks', 2, 'MinPeakHeight',max(r(maxRIndex+length(txPulse):end))/2,'MinPeakDistance', minPeakDistance);
            
            % Sort peak locations            
            lc = sort(lc);
            
            % Use interpolation to get a better resolution
            if( length(lc) >= 2)
                
                % Create a time vector
                x = 1:length(r);
                
                pkIndex1 = obj.interpolation(r, x, lc(1)); 
                pkIndex2 = obj.interpolation(r, x, lc(2));
                
                thickness = (pkIndex2-pkIndex1)*obj.config.V_PIPE/(2*obj.config.SAMPLE_RATE);
            else
                thickness = 0; 
            end
            
        end
        
        function location = interpolation(~, r, x, targetIndex)
        %%
        %   This function uses interpolation to find a better estimate for the
        %   location of the maximum value of r. 
        %   r: sample values (cross correlation)
        %   x: sample points (lags)
        %   max_index: index where r has its maximum value.

            % Number of point before and after max peak
            deltaPoint = 1;

            % Number of quary points for each sample
            interpolation_factor = 10;

            startIndex = targetIndex-deltaPoint;
            stopIndex = targetIndex+deltaPoint;
            x_startIndex = x(startIndex);
            x_stopIndex = x(stopIndex);    

            %% Retrieve small segment including max peak
            % Segment sample points
            segmentRange = startIndex:1:stopIndex;
            % Segment sample values
            r_segment = r(segmentRange);

            %% Create quary vector
            % Quary segment sample points
            interpolationRange = x_startIndex:1/interpolation_factor:x_stopIndex;     
            x_segmentRange = x_startIndex:1:x_stopIndex;

            r_interp = interp1(x_segmentRange, r_segment, interpolationRange, 'spline');

            % Draw figure
%              figure
%              plot(x_segmentRange, r_segment,'o',interpolationRange,r_interp,':.');    
%              title('Spline Interpolation');

            % Find index for max peak for the interpolated curve
            [~,I_intep] = max(r_interp);

            % Find lag at this index
            location = interpolationRange(I_intep);


        end        
                         
        %======================================================================
        %> @brief Function plots PSD for the main reflection and resonance       
        %>        and start and stop lines for where peaks are searched for
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param type RESONANCE, MAIN
        % ======================================================================          
        function plotPsdPeaks(obj, type)
            %% Function plot peaks in resonance spectrum
            
            figure
            if(obj.RESONANCE == type)
                plot(obj.fVector, obj.psdResonance,obj.fVector(obj.peakLocationResonance),obj.peakValueResonance,'o')
                
                % Start line
                line([ obj.fVector(obj.startPeakSearchIndex),  obj.fVector(obj.startPeakSearchIndex)], ... 
                     [obj.psdResonance(obj.startPeakSearchIndex)+5, obj.psdResonance(obj.startPeakSearchIndex)-5],'color','g')
                 
                % Stop line
                line([ obj.fVector(obj.stopPeakSearchIndex)  obj.fVector(obj.stopPeakSearchIndex)], ... 
                     [obj.psdResonance(obj.startPeakSearchIndex)+5, obj.psdResonance(obj.startPeakSearchIndex)-5],'color','r')
                                 
            elseif(obj.MAIN == type)
                plot(obj.fVector, -obj.psdMain,obj.fVector(obj.peakLocationMain),obj.peakValueMain,'o')
                
                % Start line
                line([ obj.fVector(obj.startPeakSearchIndex),  obj.fVector(obj.startPeakSearchIndex)], ... 
                    [-obj.psdMain(obj.startPeakSearchIndex)+20, -obj.psdMain(obj.startPeakSearchIndex)-20],'color','g')

                % Stop line
                line([ obj.fVector(obj.stopPeakSearchIndex)  obj.fVector(obj.stopPeakSearchIndex)], ... 
                    [-obj.psdMain(obj.stopPeakSearchIndex)+20, -obj.psdMain(obj.stopPeakSearchIndex)-20],'color','r')                
            end
            
            title('Resonance peaks')
            xlabel('Frequency')
            ylabel('Gain [dB]')            
            legend('Psd', 'Peaks', 'fLow','fHigh' )
            grid on
        end
                
        %======================================================================
        %> @brief Function does calculations on the harmonics sets
        %>        - Calculates thickness
        %>        - Calculates validation parameters
        %>        - Remove subsets with same thickness and calculate subset
        %>          score
        %>        - Calculate group score
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param type RESONANCE, MAIN
        %> @param noisePsd
        % ======================================================================           
        function processSets(obj, type, noisePsd)
                         
            if(obj.RESONANCE == type) 
                
                if( isempty(obj.setResonance) )
                    return;
                end
                
                % Calculate thickness
                obj.calculateSetThickness(obj.setResonance); 
                
                % Calculate validation parameters
                obj.calculateSetValidationParameters(obj.setResonance, noisePsd  );                  
                
                % Remove all subsets
                obj.setResonance = obj.removeAllSubsetsWithSameThickness(obj.setResonance);
                
                % Remove sets with invalid thickness
                obj.setResonance = obj.removeInvalidSets(obj.setResonance, obj.config.D_MIN, obj.config.D_NOM * 1.1);
                
                % Calculate group score
                obj.findSetGroupScore(obj.setResonance);
                
            elseif(obj.MAIN == type)   
                
                if( isempty(obj.setMain) )
                    return;
                end
                
                % Calculate thickness
                obj.calculateSetThickness(obj.setMain);
                
                % Calculate validation parameters
                obj.calculateSetValidationParameters(obj.setMain, noisePsd  );                      
                
                % Remove all subsets
                obj.setMain = obj.removeAllSubsetsWithSameThickness(obj.setMain);
                
                % Remove sets with invalid thickness
                obj.setMain = obj.removeInvalidSets(obj.setMain, obj.config.D_MIN, obj.config.D_NOM * 1.1);
                
                % Calculate group score
                obj.findSetGroupScore(obj.setMain);
            end                                          
        end
        
        %======================================================================
        %> @brief Function removes all subsets with approx. same thickness
        %>        A set will get a score of one for each subset that it
        %>        contains
        %>        A setA will have a subset, subsetB, if all harmonics in subsetB
        %>        are also in setA. SubsetB is only removed if setA and
        %>        subsetB has the same thickness within 10%
        %>        
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param set reference to resonance sets or main sets        
        % ======================================================================           
        function set = removeAllSubsetsWithSameThickness(obj, set)
                         
            n = 1;
            while( n < numel(set) )                
                m = n + 1;
                while( m <= numel(set) )
                    %fprintf('Index n:%d m:%d \n',n ,m);
                    
                    if(numel(set(n).psdIndexArray) >= numel(set(m).psdIndexArray))
                        memberArray = ismember(set(m).psdIndexArray, set(n).psdIndexArray);
                        setIndexToRemove = m;
                    else
                        memberArray = ismember(set(n).psdIndexArray, set(m).psdIndexArray);
                        setIndexToRemove = n;
                    end

                    % Check if all element in memberArray is logical 1                    
                    if(sum(memberArray) == numel((memberArray)) && ...
                      ( abs(set(m).thickness - set(n).thickness)/(set(m).thickness) < 0.1 ))                        
                         
                        % Increment subset score
                        if( n ~= setIndexToRemove ) 
                            set(n).scoreSubset = set(n).scoreSubset + 1 + set(m).scoreSubset;
                            set(setIndexToRemove) = [];
                        else
                            set(m).scoreSubset = set(m).scoreSubset + 1 + set(n).scoreSubset;                            
                            set(setIndexToRemove) = [];
                            % Substract n with 1 since one set has been
                            % removed
                            n = n - 1; 
                            % Break inner while loop
                            break;
                        end                           
                    else
                        % Increment m
                        m = m + 1;
                    end
                end
                % Increment n
                n = n + 1; 
                               
            end        
        end          
                
        
        function y = movingAverageFilter(~, x, N)            
            b = (1/N)*ones(1, N);
            a = 1;            
            y = filtfilt(b, a, x);            
        end

                      
        %======================================================================
        %> @brief Experimental function. Function will remove all subsets
        %>        and give a score for each subset.
        %>        Subset is removed as soon as it is found
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param set reference to resonance sets or main sets        
        % ======================================================================           
        function set = removeAllSubsets(obj, set)
            
            n = 1;
            while( n < numel(set) )                
                m = n + 1;
                while( m <= numel(set) )
                    fprintf('Index n:%d m:%d \n',n ,m);
                    
                    if(numel(set(n).psdIndexArray) >= numel(set(m).psdIndexArray))
                        memberArray = ismember(set(m).psdIndexArray, set(n).psdIndexArray);
                        setIndexToRemove = m;
                    else
                        memberArray = ismember(set(n).psdIndexArray, set(m).psdIndexArray);
                        setIndexToRemove = n;
                    end

                    % Check if all element in memberArray is logical 1                    
                    if(sum(memberArray) == numel((memberArray)))                        
                         
                        % Increment subset score
                        if( n ~= setIndexToRemove ) 
                            set(n).scoreSubset = set(n).scoreSubset + 1 + set(m).scoreSubset;
                            set(setIndexToRemove) = [];
                        else
                            set(m).scoreSubset = set(m).scoreSubset + 1 + set(n).scoreSubset;                            
                            set(setIndexToRemove) = [];
                            % Substract n with 1 since one set has been
                            % removed
                            n = n - 1; 
                            % Break inner while loop
                            break;
                        end                           
                    else
                        % Increment m
                        m = m + 1;
                    end
                end
                % Increment n
                n = n + 1; 
                               
            end        
        end                 
        
        %======================================================================
        %> @brief Experimental function for reducing number of peads using
        %>        moving window. 
        %>        NOTE function does not seem to work as well for removing
        %>        peaks
        %>
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param type RESONANCE, MAIN
        % ======================================================================          
        function peakReduction(obj, type)
            
            % Type check
            if(obj.RESONANCE == type)
                psd = obj.psdResonance;
                peakValue = obj.peakValueResonance;
                peakLoc = obj.peakLocationResonance;
                peakProm = obj.peakProminenceResonance;
                peakWidth = obj.peakWidthResonance;
            elseif(obj.MAIN == type)
                % @TODO: must do something here
                psd = -obj.psdMain;
                peakValue = obj.peakValueMain;
                peakLoc = obj.peakLocationMain;
                peakProm = obj.peakProminenceMain;
                peakWidth = obj.peakWidthMain;                
            else
                error('Ilegal type %d', type');
            end
            
            % Use a moving window to remove peaks that have a much lower
            % prominence than neighbour peaks
            
            peakIndexToRemove = [];
            peakIndexMax = numel(peakProm);
            windowSize = 3;
            windowIndex = 0:(windowSize-1);
            for i = 1:numel(peakProm)
                if(i+(windowSize-1) > peakIndexMax)
                    % Window has reached the end 
                    break;
                end
                
                [minProm, minIndex] = min([peakProm(i:i+(windowSize-1))]);
                [maxProm, maxIndex] = max([peakProm(i:i+(windowSize-1))]);
                
                
                 indexToRemove = windowIndex(peakProm(i:i+(windowSize-1)) < (maxProm*0.5));
                
                 peakIndexToRemove = [peakIndexToRemove (i+indexToRemove)];
                 %peakIndexToRemove
                
            end
            
            peakIndexToRemove = unique(peakIndexToRemove);
            
            peakValue(peakIndexToRemove) = [];
            peakLoc(peakIndexToRemove) = [];
            peakProm(peakIndexToRemove) = [];
            peakWidth(peakIndexToRemove) = [];
            
            if(obj.RESONANCE == type)
                
                obj.peakValueResonance = peakValue;
                obj.peakLocationResonance = peakLoc;
                obj.peakProminenceResonance = peakProm;
                obj.peakWidthResonance = peakWidth;
            elseif(obj.MAIN == type)
                % @TODO: must do something here
                
                obj.peakValueMain = peakValue;
                obj.peakLocationMain = peakLoc;
                obj.peakProminenceMain = peakProm;
                obj.peakWidthMain = peakWidth;                
            end            
            
        end
          
        %======================================================================
        %> @brief Experimental function.Testing use of envelope for
        %>        reducing the number of peaks in the psd resonance. 
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        % ======================================================================           
        function envelopeTest(obj)
            % Plot thickness psd
            obj.plotPsdPeaks(obj.RESONANCE);
            % Envelope function
            [yupper,ylower] = envelope(obj.psdResonance, 75, 'peak');
            hold on
            plot(obj.fVector, yupper)
            hold off
        end
        
        
        %======================================================================
        %> @brief Function for finding the "best" set. This function is not
        %>        used anymore and has been replaced by another function.
        %>        1. Find the sets with most number of harmonics. 
        %>        2. For each of the largest sets give 1 point in score for
        %>           each set that these larger set has at least 2 frequencies in
        %>           common.
        %>        3. 
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @param allSet reference to array of HarmonicSet
        %> @param varargin
        % ====================================================================== 
        function [setCandidate, setsWithMaxSize, setsWithEstimatedThickness] = findBestSetD(obj, set, allSet, varargin)

            estimatedThicknessFromAbsorption = 0;
            if(nargin > 3)
                estimatedThicknessFromAbsorption = varargin{1};  
            end
            
            
            if(0 == estimatedThicknessFromAbsorption)
            

                % Find sets with most harmonics
                setsWithMaxSize = findSetWithMostHarmonics(obj, set);                        

                % Calculate set score
                % A set will get a score for each set that it is sharing two
                % frequencies with
                MINIMUM_COMMON_FREQUENCIES = 2;            
                for setIndexN = setsWithMaxSize
                    for setIndexM = 1:length(set)
                        if(setIndexN ~= setIndexM)

                            commonFreqLocation = intersect(set(setIndexM).psdIndexArray, set(setIndexN).psdIndexArray);
                            if(length(commonFreqLocation) >= MINIMUM_COMMON_FREQUENCIES)
                               set(setIndexN).scoreHarmonic = set(setIndexN).scoreHarmonic + 1;
                            end
                        end        
                    end
                end

                % Find maximum score                
                maxHarmonicScore = sort([set(setsWithMaxSize).scoreHarmonic]);
                maxHarmonicScore = maxHarmonicScore(end);
                
                % Find sets with maximum score                
                setWithMaxHarmonicScore = setsWithMaxSize([set(setsWithMaxSize).scoreHarmonic] == maxHarmonicScore);

                % Check if there are sets that measure multiple thickness's
                % @TODO: Double or trippel thickness have to a higher count
                % than 1 to be saved as a score for double or trippel
                % thickness
                PERCENTAGE_DEVIATION = 5;
                for setIndex = setWithMaxHarmonicScore
                    doubleThickness = 2 * set(setIndex).thickness;
                    [count, sets] = obj.findNumberOfSetsWithThickness(doubleThickness, set, PERCENTAGE_DEVIATION);
                    if(count > 1)
                        set(setIndex).scoreDoubleThickness = count;
                    end

                    trippelThickness = 3 * set(setIndex).thickness;
                    [count, sets] = obj.findNumberOfSetsWithThickness(trippelThickness, set, PERCENTAGE_DEVIATION);
                    if(count > 1)
                        set(setIndex).scoreTrippelThickness = count;
                    end                
                end

                % Iterate through Double and Trippel thickness score to find
                % the most probable thickness
                estimatedThicknessArray = zeros(1, length(setWithMaxHarmonicScore));

                for setIndex = 1:length(setWithMaxHarmonicScore)
                    if(set(setWithMaxHarmonicScore(setIndex)).scoreTrippelThickness > 0)
                        estimatedThicknessArray(setIndex) = set(setWithMaxHarmonicScore(setIndex)).thickness * 3;
                    elseif(set(setWithMaxHarmonicScore(setIndex)).scoreDoubleThickness > 0)
                        estimatedThicknessArray(setIndex) = set(setWithMaxHarmonicScore(setIndex)).thickness * 2;
                    else
                        estimatedThicknessArray(setIndex) = set(setWithMaxHarmonicScore(setIndex)).thickness;
                    end
                end

                % If there are more than ONE thichness in estimatedThicknessArray we
                % need to find the thickness that is most likely.


                % Find number of sets for each thicknessTemp
                countArray = zeros(1,length(estimatedThicknessArray));

                % @TODO optimize: Should here store in matrix, so both number of
                % set with the thickness and the set indexes are stored
                for index = 1:length(estimatedThicknessArray)
                    countArray(index) = obj.findNumberOfSetsWithThickness(estimatedThicknessArray(index), allSet, 5);
                end

                % Select the thickness with mosts sets
                [count, indexWithMax] = max(countArray);                       
                estimatedThickness = estimatedThicknessArray(indexWithMax);
                
                [count, setsWithEstimatedThickness] = obj.findNumberOfSetsWithThickness(estimatedThickness, allSet, PERCENTAGE_DEVIATION);
            else
                
                PERCENTAGE_DEVIATION = 10;
                [count, setsWithEstimatedThickness] = obj.findNumberOfSetsWithThickness(estimatedThicknessFromAbsorption, allSet, PERCENTAGE_DEVIATION);
            end
            
            
            % If no sets with estimatedThickness if found, find the set
            % with best class.
            if(count ~= 0)


                %setsWithEstimatedThickness
                % Find largest set with estimated thickness


                largestSetWithEstimatedThickness = obj.findSetNLargestSet(allSet, 2, setsWithEstimatedThickness);
                %largestSetWithEstimatedThickness = obj.findSetWithMostHarmonics(allSet, setsWithEstimatedThickness);

                setsWithEstimatedThickness = largestSetWithEstimatedThickness;
            else
                
               setsWithEstimatedThickness = 1:length(allSet); 
            end
            % Iterate through sets and find the set with highest class
            % given the estimated thickness
            classArray = ['A', 'B', 'C', 'D'];            
            index = 1;
            setCandidate = [];
            while(isempty(setCandidate))                                
                setCandidate = findSetWithClassAndThickness(obj, allSet, classArray(index), setsWithEstimatedThickness);
                index = index + 1;
            end            
            
            % If remaining setCandidate is of class D, check if there is
            % other sets with class A that probably should be chosen
            % instead
            
            % Needed to disable the functionality below when using
            % information from absorption spectrum
if(0)            
            if(0 == estimatedThicknessFromAbsorption)
                if( ~isempty(setCandidate) )
                    if(numel(setCandidate) > 1)                        
                        setCandidate = setCandidate(1);
                    end
                    if(allSet(setCandidate).class == 'D' || allSet(setCandidate).class == 'C')
                        classArray = [allSet(:).class];
                        setsWithClassA = find(classArray == 'A');
                        if( length(setsWithClassA) > 1)                            
                            setCandidate = findSetWithHighestAveragePeakEnergy(obj, allSet, setsWithClassA);
                        elseif(length(setsWithClassA) == 1)
                            setCandidate = setsWithClassA;
                        end
                    end
                 end
            end                       
end            
                                           
        end
        
        %======================================================================
        %> @brief Function compares two sets A and B and give a score for
        %>        each "feature" that best in each of the sets and return
        %>        the index to the set that has highest score.
        %> 
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @param A index for set A that will be compared with set B
        %> @param B index for set B that will be compared with set A
        % ======================================================================         
        function [setCandidate] = compareTwoCandidates(obj, set, A, B)
            pointsA = 0;
            pointsB = 0;
            
            import ppPkg.VP;
            
            % Compare number of frequencies
            if(set(A).numFrequencies > set(B).numFrequencies)
                pointsA = pointsA + 1;
            elseif(set(A).numFrequencies < set(B).numFrequencies)
                pointsB = pointsB + 1;
            end
            
            % Highest class
            if(set(A).class == set(B).class)
            elseif(set(A).class < set(B).class)
                pointsA = pointsA + 1;
            else
                pointsB = pointsB + 1;
            end
            
            % Highest Average energy
            if(set(A).vp(VP.AVERAGE_RESONANCE_ENERGY) > set(B).vp(VP.AVERAGE_RESONANCE_ENERGY))
                pointsA = pointsA + 1;
            elseif(set(A).vp(VP.AVERAGE_RESONANCE_ENERGY) < set(B).vp(VP.AVERAGE_RESONANCE_ENERGY))
                pointsB = pointsB + 1;
            end
            
            % Lowest Deviation from target
%             if(set(A).vp(3) < set(B).vp(3))
%                 pointsA = pointsA + 1;
%             elseif(set(A).vp(3) > set(B).vp(3))
%                 pointsB = pointsB + 1;
%             end
            
            if(pointsA > pointsB)
                setCandidate = A;
            elseif(pointsA < pointsB)
                setCandidate = B;
            else
                setCandidate = [];
            end
            
        end
        
        %======================================================================
        %> @brief Function finds set candidate based on thickness score
        %>        1. Check if there are any sets with double or trippel thickness  
        %>           compared to the thickness given by setCandidate. 
        %>        2. If there are sets with double or trippel thickness
        %>           they are probably the correct sets representing the real thickness
        %>           of the pipe wall.
        %>        3. If there are neither sets with double or trippel
        %>           thickness: Compare the setCandidate members. If the
        %>           are several members. Start selecting the ones with
        %>           highest class.
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @param setCandidate 
        % ======================================================================         
        function [setCandidateOut] = findCandidateBasedOnThicknessScore(obj, set, setCandidate)
                   
                % Find number of sets with double thickness compared to
                % setCandidate
                PERCENTAGE_DEVIATION = 10;
                doubleThickness = 2 * set(setCandidate).thickness;
                [countDouble, setsDouble] = obj.findNumberOfSetsWithThickness(doubleThickness, set, PERCENTAGE_DEVIATION);
                if(countDouble > 0)
                    set(setCandidate).scoreDoubleThickness = countDouble;
                end

                % Find number of sets with trippel thickness compared to
                % setCandidate
                trippelThickness = 3 * set(setCandidate).thickness;
                [countTrippel, setsTrippel] = obj.findNumberOfSetsWithThickness(trippelThickness, set, PERCENTAGE_DEVIATION);
                if(countTrippel > 0)
                    set(setCandidate).scoreTrippelThickness = countTrippel;
                end   
                
                % Select the score that is highest of countTrippel and
                % countDouble 
                if(countTrippel < countDouble )
                    % Double thickness
                    
                    % Out of the sets with double thickness find the ones
                    % with highest subset score
                    setCandidateTemp = setsDouble([set(setsDouble).scoreSubset] == max([set(setsDouble).scoreSubset]));                    
                    
                    % Select the ones with highest average energy
                    if(numel(setCandidateTemp) > 1 )                    
                        setCandidateTemp = obj.findSetWithHighestAveragePeakEnergy(set, setCandidateTemp);
                    end                                     
                    
                    % Select the one with lowest deviation from target
                    % frequency
                    if(numel(setCandidateTemp) > 1 )                    
                        [setCandidateTemp] = obj.findSetWithLowestDeviation(set, setCandidateTemp);
                    end                    
                                       
                    %if(set(setCandidateTemp).scoreSubset >= 1 || countSetsWithCandidateThickness > 1 )
                        setCandidateOut = setCandidateTemp(1);
                    %end
                    
                    
                elseif(countTrippel > countDouble)
                    % Trippel thickness
                    setCandidateTemp = setsTrippel([set(setsTrippel).scoreSubset] == max([set(setsTrippel).scoreSubset]));                                   
                    
                    % Select the ones with highest average energy
                    if(numel(setCandidateTemp) > 1 )                    
                        setCandidateTemp = obj.findSetWithHighestAveragePeakEnergy(set, setCandidateTemp);
                    end 
                    % Select the ones with most harmonics
                    if(numel(setCandidateTemp) > 1 ) 
                        [setCandidateTemp, ~] = findSetWithMostHarmonics(obj, set(setCandidateTemp), setCandidateTemp);
                    end                       
                    
                    % Select the one with lowest deviation from target
                    % frequency
                    if(numel(setCandidateTemp) > 1 )                    
                        [setCandidateTemp] = obj.findSetWithLowestDeviation(set, setCandidateTemp);
                    end                                           
                    
                    %if(set(setCandidateTemp).scoreSubset >= 1 || countSetsWithCandidateThickness > 1)
                        setCandidateOut = setCandidateTemp(1);
                    %end
                    
                else                                        
                    % There was no candidates with do  
                    if( ~isempty(set(setCandidate).setMember) )
                        
                        candidateClass = set(setCandidate).class;
                        members = set(setCandidate).setMember;

                        % Select the members with the same class or higher
                        switch candidateClass
                            case 'A'                                
                                membersWithClass = members(obj.findSetWithClass(set(members), candidateClass));                    
                            case 'B'
                                membersWithClass = members(obj.findSetWithClass(set(members), 'A'));                    
                                membersWithClass = [membersWithClass members(obj.findSetWithClass(set(members), 'B'))];                    
                            case 'C'
                                membersWithClass = members(obj.findSetWithClass(set(members), 'A'));                    
                                membersWithClass = [membersWithClass members(obj.findSetWithClass(set(members), 'B'))];                                                    
                                membersWithClass = [membersWithClass members(obj.findSetWithClass(set(members), 'C'))];                                                    
                            case 'D'
                                membersWithClass = members(obj.findSetWithClass(set(members), 'A'));                    
                                membersWithClass = [membersWithClass members(obj.findSetWithClass(set(members), 'B'))];                                                    
                                membersWithClass = [membersWithClass members(obj.findSetWithClass(set(members), 'C'))];                                                    
                                membersWithClass = [membersWithClass members(obj.findSetWithClass(set(members), 'D'))];                                                    
                        end
                                
                        
                        setCandidateOut = findSingleSetCandidateHelperFunction(obj, set, membersWithClass);
                        %@TODO fix this
                        setCandidateOut = setCandidateOut(1);
                    
                    else
                        setCandidateOut = setCandidate; 
                    end
                end                
        end
        
        %======================================================================
        %> @brief Function will select the candidate with the following
        %>        features:
        %>        - Most harmonics
        %>        - Highest average energy
        %>        - Lowest deviation
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @param setCandidates Index to possible set candidates
        % ======================================================================            
        function [candidate] = findSingleSetCandidateHelperFunction(obj, set, setCandidates)
            
                % Select the ones with most harmonics
                if(numel(setCandidates) > 1 ) 
                    [setCandidates, ~] = findSetWithMostHarmonics(obj, set(setCandidates), setCandidates);
                end

                % Select the ones with highest average energy
                if(numel(setCandidates) > 1 )                    
                    setCandidates = obj.findSetWithHighestAveragePeakEnergy(set, setCandidates);
                end                    

                % Select the one with lowest deviation from target
                % frequency
                if(numel(setCandidates) > 1 )                    
                    [setCandidates] = obj.findSetWithLowestDeviation(set, setCandidates);
                end 
                                
                candidate = setCandidates;                
        end
        
        %======================================================================
        %> @brief Function find set candidates based on combining group and
        %>        subset score and looks at the sets with the highest
        %>        score.
        %>        The sets with the two highest combined score
        %>        are used as set candidates
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @retval setCandidate index to set candidiate
        % ======================================================================        
        function [setCandidate] = findSetBasedOnCombinedGroupAndSubsetScore(obj, set)
            
            setIndex = 1:numel(set); 
            
            % Calculated the combined score and add 1 to each score type
            scoreCombinedGroupAndSubset = ([set.scoreGroupCount] + 1) .* ([set.scoreSubset]+ 1);                        
            
            if( sum(scoreCombinedGroupAndSubset) > 0)

                % Use the two highest scores
                scores = sort(unique(scoreCombinedGroupAndSubset),'descend');                                
                
                % Find the set with the highest score
                idxl = (scoreCombinedGroupAndSubset == scores(1));          
                setCandidatesTemp = setIndex(idxl); 

               % Find the set with the next highest score
                if(numel(scores) > 1 )                    
                    % Score must be higher than 1 to be considered
                    if(scores(2) > 1)
                        idx2 = (scoreCombinedGroupAndSubset == scores(2));          
                        setCandidatesTemp = [setCandidatesTemp setIndex(idx2)];                 
                    end
                end
                
                % With a high scoreGroupCount that is a good indication that
                % these sets represent the correct thickness.
                % Could then search for all sets with this thickness to find
                % even more. 

                setCandidates = zeros(1,numel(setCandidatesTemp));
                for i = 1:numel(setCandidatesTemp)
                     setCandidates(i) = obj.findCandidateBasedOnThicknessScore(set, setCandidatesTemp(i));
                end
                                
                setCandidates = unique(setCandidates);
                
                % If there are several candidates return the "best" one
                if(numel(setCandidates) > 1 )
                    setCandidate = obj.findSingleSetCandidateHelperFunction(set, setCandidates);
                else
                    setCandidate = setCandidates;
                end 
                                
            else
               setCandidate = [];
            end                                
        end
        
        %======================================================================
        %> @brief Experimental function: This function is using the set
        %>        with most harmonics as the initial set candidate
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        % ======================================================================           
        function [setCandidateOut] = findSetBasedOnNumberOfHarmonics(obj,set)
            
            % Find the set with most harmonics
            [setCandidatesTemp, ~] = findSetWithMostHarmonics(obj, set);
            
            % Check if there are other sets with double or trippel
            % thickness
            for i = 1:numel(setCandidatesTemp)
                 setCandidates(i) = obj.findCandidateBasedOnThicknessScore(set, setCandidatesTemp(i));
            end

            setCandidates = unique(setCandidates);

            % If there are several candidates select the "best" one.
            if(numel(setCandidates) > 1 )
                setCandidateOut = obj.findSingleSetCandidateHelperFunction(set, setCandidates);
            else
                setCandidateOut = setCandidates;
            end 
             
        end
        
        %======================================================================
        %> @brief Function finds set that most likely represent the
        %>        thickness of the pipe wall.
        %>        Function uses the combined group and subset score as the
        %>        initial set candidiate
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        % ======================================================================        
        function [setCandidate] = findBestSetE(obj, set)
                        
            setCandidateCombined = 0;
            % Test combined score. 1 score point is added to the groupScore
             
            % Find set based on combined group and subset score
            setCandidateCombined = findSetBasedOnCombinedGroupAndSubsetScore(obj, set);
            setCandidate = setCandidateCombined;
            
%             setCandidateNumHarmonics = findSetBasedOnNumberOfHarmonics(obj, set);
%             
%             setCandidate = compareTwoCandidates(obj,set, setCandidateCombined, setCandidateNumHarmonics);
%             if( isempty(setCandidate))
%                 setCandidate = setCandidateCombined;
%             end
            
            if( isempty(setCandidate) )
                
                %Select set with highest class and highest average peak energy
                if(1)
                    classArray = ['A', 'B', 'C', 'D'];            
                    index = 1;
                    setCandidate = [];
                    while(isempty(setCandidate))                                
                        setCandidate = obj.findSetWithClassAndHighestAverageEnergy(set, classArray(index));
                        index = index + 1;
                    end 
                end
            end
                          
        end
        
        %======================================================================
        %> @brief Experimental function
        %>        A collection of test algorithms for finding the set
        %>        representing the pipe wall thickness
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        % ======================================================================          
        function findSetCandidateTest(obj, set)
            % Find set with highest subset score
            [~, setIndexMaxSubsetScore] =  findSetWithHighestSubsetScore(obj, set);
            
            setIndex = 1:numel(set);
                        
            maxScore = max([set.scoreGroupCount]);

            validateAlternativeCandidate = false;
            
            %%%%%
            % @TODO: Need to rewrite this first part. Does not work for all
            % cases.
            %%%%%
            idxl = ([set.scoreGroupCount] == max([set.scoreGroupCount]));          
            setIndexMaxGroupCountScore = setIndex(idxl);  
            % Combined subset and group score
            idxMember = ismember(setIndexMaxSubsetScore, setIndexMaxGroupCountScore);
            if(maxScore > 1 && sum(idxMember) > 0)                  


                setCandidate = setIndexMaxSubsetScore(idxMember);   
                if(numel(setCandidate) > 1)
                    setCandidate = setCandidate(findSetWithMostHarmonics(obj, set(setCandidate)));
                end

                % Select the ones with highest average energy
                if(numel(setCandidate) > 1 )                    
                    setCandidate = obj.findSetWithHighestAveragePeakEnergy(set, setCandidate);
                end 

                % Select the one with lowest deviation from target
                % frequency
                if(numel(setCandidate) > 1 )                    
                    [setCandidate] = obj.findSetWithLowestDeviation(set, setCandidate);
                end                       
                
                validateAlternativeCandidate = true;
                setCandidateWithHighGroupScore = setCandidate;
                
            else
                setCandidate = setIndexMaxSubsetScore;
                
                % Select the one with most harmonics
                if(numel(setCandidate) > 1)
                    setCandidate = setCandidate(findSetWithMostHarmonics(obj, set(setCandidate)));
                end

                % Select the ones with highest average energy
                if(numel(setCandidate) > 1 )                    
                    setCandidate = obj.findSetWithHighestAveragePeakEnergy(set, setCandidate);
                end 

                % Select the one with lowest deviation from target
                % frequency
                if(numel(setCandidate) > 1 )                    
                    [setCandidate] = obj.findSetWithLowestDeviation(set, setCandidate);
                end                 
            end   
            
         %                 
%             end
%                
%             if(validateAlternativeCandidate)
%                 setCandidateTemp = 0;
%                 if( (set(setCandidateWithHighGroupScore).class == 'A') && ...
%                    (set(setCandidateWithHighGroupScore).numFrequencies >= set(setCandidate).numFrequencies))
%                    
%                     setCandidateTemp = setCandidateWithHighGroupScore;
% 
%                     if( 1 == round(set(setCandidate).thickness / set(setCandidateTemp).thickness) )
%                         setCandidate = setCandidateTemp; 
%                     end                      
%                    
%                 elseif(numel(set(setCandidateWithHighGroupScore).setMember) > 1)
%                     
%                     members = set(setCandidateWithHighGroupScore).setMember;
%                     % Keep set with highest class
%                 
%                     classArray = ['A', 'B', 'C', 'D'];            
%                     index = 1;
%                     setCandidateMembers = [];
%                     while(isempty(setCandidateMembers))                                
%                         setCandidateMembers = obj.findSetWithClassAndHighestAverageEnergy(set(members), classArray(index));
%                         index = index + 1;
%                     end 
%                                   
%                     setCandidateTemp = members(setCandidateMembers);
%                     
%                     if(numel(setCandidateTemp) > 1)
%                         error('Error in number of candidates')
%                     end
%                     
%                     if( 1 == round(set(setCandidate).thickness / set(setCandidateTemp).thickness) )
%                         setCandidate = setCandidateTemp; 
%                     end                     
%                     
%                 else
%                     disp('test')
%                 end
%                 
%                 %countSetsWithCandidateTempThickness =  obj.findNumberOfSetsWithThickness(set(setCandidateTemp).thickness, set, PERCENTAGE_DEVIATION);            
%                 
%               
%             end             
        end
         
        %======================================================================
        %> @brief Function calculates group score
        %>        A set will get a group score if two conditions are met:
        %>        - They must share two frequencies
        %>        - The two frequencies must be in a row
        %>        - The two sets must have the same thickness within 10%
        %>          margin        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        % ======================================================================               
        function findSetGroupScore(obj, set)
            
            for i = 1:(numel(set)-1)
                for m = (i+1):numel(set)
                    x_im = ismember( set(i).psdIndexArray, set(m).psdIndexArray);
                    x_mi = ismember( set(m).psdIndexArray, set(i).psdIndexArray);        

                    if((true == obj.checkIfTwoOnesInARow(x_im)) && ...
                       (true == obj.checkIfTwoOnesInARow(x_mi)) && ...
                       (true == obj.compareNumber(set(i).averageFreqDiff, set(m).averageFreqDiff, 10/100)) )

                        set(i).scoreGroupCount = set(i).scoreGroupCount + 1;
                        set(m).scoreGroupCount = set(m).scoreGroupCount + 1;
                        set(i).setMember = unique([i set(i).setMember m ]);
                        set(m).setMember = unique([m set(m).setMember i ]);
                    end
                end
            end                        
        end
                
        %======================================================================
        %> @brief Function find a set with a given class from all sets in the 
        %>        set array or from a group of sets in set array.
        %>        If there are several sets with given class this function
        %>        will return the one with lowest deviation and highest average peak
        %>        energy.
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        %> @param class Set class ('A', 'B', 'C', 'D')
        %> @param setWithEstimatedThickness
        % ======================================================================              
        function setCandidate = findSetWithClassAndThickness(obj, set, class, setWithEstimatedThickness)
            
            setsWithGivenClass = obj.findSetWithClass(set, class, setWithEstimatedThickness);
            
            if( length(setsWithGivenClass) > 1)
                % Find set with lowest deviation
                setCandidate = findSetWithLowestDeviation( obj, set, setsWithGivenClass);   
                
                if( length(setCandidate) > 1)                   
                    setCandidate = findSetWithHighestAveragePeakEnergy(obj, set, setCandidate);                                        
                end                              
                                
            elseif(length(setsWithGivenClass) == 1)                
                setCandidate = setsWithGivenClass;                
            else
                setCandidate = [];
            end            
        end
        
        %======================================================================
        %> @brief Function find a set with a given class from all sets in the 
        %>        set array or from a group of sets in set array.
        %>        If there are several sets with given class this function
        %>        will return the one highest average peak
        %>        energy.
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        %> @param class Set class ('A', 'B', 'C', 'D')
        % ======================================================================         
        function setCandidate = findSetWithClassAndHighestAverageEnergy(obj, set, class)
         
            setsWithGivenClass = obj.findSetWithClass(set, class);
            
            % If several candidates, return the one with highest average 
            % peak energy
            if( length(setsWithGivenClass) > 1)
            
                setCandidate = findSetWithHighestAveragePeakEnergy(obj, set, setsWithGivenClass);                                   
                                           
            elseif(length(setsWithGivenClass) == 1)                
                setCandidate = setsWithGivenClass;                
            else
                setCandidate = [];
            end                 
        end
        
        %======================================================================
        %> @brief Function returns the set the highest harmonic frequency        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        % ======================================================================             
        function setCandidate = findSetWithHighestFrequency(obj, set)
            
            maxFrequency = max([set.freqArray]);
            
            idx = zeros(1,numel(set));
            indexArray = 1:numel(set);
            
            setCandidate = [];
            for i = 1:numel(set)
                idx(i) = sum(set(i).freqArray == maxFrequency);
            end
            
            idx = logical(idx);
            
            setCandidate = indexArray(idx);
            
        end
        
        %======================================================================
        %> @brief Function returns the set the highest subset score        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        % ======================================================================
        function [setsWithMaxSubsetScore, setIndex] = findSetWithHighestSubsetScore(obj, set)
                       
            setIndex = 1:numel(set);
            idxl = ([set.scoreSubset] == max([set.scoreSubset]));
            setsWithMaxSubsetScore =  set(idxl);
            setIndex = setIndex(idxl);
        end
        
        %======================================================================
        %> @brief Function returns the set with most harmonics frequencies        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        %> @param varargin Array of set indices to search within
        % ======================================================================        
        function [setsWithMaxSize, maxSize] = findSetWithMostHarmonics(obj, set, varargin)            
            if(nargin > 2)
                arrayOfSetIndicesToSearch = varargin{1};    
            else
                arrayOfSetIndicesToSearch = 1:length(set);
            end
          
            % Find all sizes and sort
            sortedSized = sort([set.numFrequencies]);
            
            % The last one is the largest
            maxSize = sortedSized(end);                
            
            % Find sets with max size
            setsWithMaxSize = arrayOfSetIndicesToSearch([set.numFrequencies] == maxSize);
        end

        %======================================================================
        %> @brief Function calculate number of harmonics frequencies that
        %>        can be found in the range [fLow to FHigh] assuming that the first
        %>        harmonic is located at fLow.
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param fLow Lower frequency range
        %> @param fHigh Higher frequency range
        %> @retval numberOfHarmoncsExpected in the range given
        % ======================================================================      
        function numberOfHarmonicsExpected = findNumberOfHarmonics(obj, flow, fhigh)
            
            f0 = obj.config.V_PIPE/(2 * obj.config.D_NOM);
            n = 0;
            f = flow;
            while( f <= fhigh)
                n = n + 1;
                f = f + f0;
            end
            
            numberOfHarmonicsExpected = n;
        end

        %======================================================================
        %> @brief Function returns the set with the highest average peak
        %>        energy
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        %> @param varargin Array of set indices to search within
        %> @retval numberOfHarmoncsExpected in the range given
        % ======================================================================              
        function [setWithHighestPeakEnergy] = findSetWithHighestAveragePeakEnergy(obj, set, varargin)
            
            import ppPkg.VP;
            
            if(nargin > 2)
                arrayOfSetIndicesToSearch = varargin{1};    
            else
                arrayOfSetIndicesToSearch = 1:length(set);
            end

            % Place all validation parameters of all sets into a matrix
            vpMatrix = reshape([set(arrayOfSetIndicesToSearch).vp], length(set(1).vp),numel(arrayOfSetIndicesToSearch));
    
            % Find the set with highest average peak energy
            idxHighest = vpMatrix(VP.AVERAGE_RESONANCE_ENERGY,:) == ...
                max(vpMatrix(VP.AVERAGE_RESONANCE_ENERGY,:));
            
            setWithHighestPeakEnergy = arrayOfSetIndicesToSearch(idxHighest);            
        end 
        
        %======================================================================
        %> @brief Function returns the N largest sets
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        %> @param varargin Array of set indices to search within
        %> @retval setsWithMaxSize Largest sets        
        % ======================================================================          
        function [setsWithMaxSize] = findSetNLargestSet(obj, set, N, varargin)
            %% Function will return index to the sets with highest number of
            %  harmonics
            %  set:         Array of HarmonicSet objects
            %  varargin:    Array of set indices to search within.
          
           
            if(nargin > 3)
                arrayOfSetIndicesToSearch = varargin{1};    
            else
                arrayOfSetIndicesToSearch = 1:length(set);
            end

            sortedSizes = sort([set(arrayOfSetIndicesToSearch).numFrequencies]);
            
            if(length(sortedSizes) >= N)
                largestNSizes = sortedSizes(end-(N-1):end);
                maxSize = largestNSizes(1);
            else
                maxSize = sortedSizes(1);
            end
            
            setsWithMaxSize = arrayOfSetIndicesToSearch([set(arrayOfSetIndicesToSearch).numFrequencies]' >= maxSize);
                    
        end        
        
        %======================================================================
        %> @brief Function returns sets with given class
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        %> @param class
        %> @param varargin Array of set indices to search within
        %> @retval setsWithMaxSize Index to sets with given class
        % ======================================================================        
        function setsWithGivenClass = findSetWithClass( obj, set, class, varargin)

            if(nargin > 3)
                arrayOfSetIndicesToSearch = varargin{1};    
            else
                arrayOfSetIndicesToSearch = 1:length(set);
            end
                    
            setsWithGivenClass = arrayOfSetIndicesToSearch([set(arrayOfSetIndicesToSearch).class] == class);            
        end 
        
        %======================================================================
        %> @brief Function returns sets with lowest deviation
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                        
        %> @param varargin Array of set indices to search within
        %> @retval setWithLowestDeviation Index to sets with lowest
        %>                                deviation
        % ======================================================================                         
        function setWithLowestDeviation = findSetWithLowestDeviation( obj, set, varargin)          
        
            import ppPkg.VP;
            
            if(nargin > 2)
                arrayOfSetIndicesToSearch = varargin{1};    
            else
                arrayOfSetIndicesToSearch = 1:length(set);
            end
    
            % Place all validation parameters of all sets into a matrix
            vpMatrix = reshape([set(arrayOfSetIndicesToSearch).vp],length(set(1).vp),numel(arrayOfSetIndicesToSearch));

            % Find the set with lowest deviation
            idx = vpMatrix(VP.AVERAGE_DEVIATION,:) == ...
                min(vpMatrix(VP.AVERAGE_DEVIATION,:));
            
            setWithLowestDeviation = arrayOfSetIndicesToSearch(idx);            
        end
        
        %======================================================================
        %> @brief Function returns sets with the given thickness within
        %>        given percentage range
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param thickness Thickness 
        %> @param set reference to array of HarmonicSet                        
        %> @param percentage 
        %> @retval count Number of sets found with given thickness   
        %> @retval sets Index to sets with given thickness
        % ======================================================================         
        function [count, sets] = findNumberOfSetsWithThickness(obj, thickness, set, percentage) 
            
            % Allowed deviation
            allowedDeviation = percentage/100;
            
            % Vecorization
            indexArray = 1:numel(set);
            
            % Logical array for indexes that are less than allowed
            % deviation
            idxl = (abs((thickness - [set.thickness]))/thickness ) < allowedDeviation;
            
            % Sum to get number of sets 
            count = sum(idxl);
            
            sets = indexArray(idxl);            
        end
        
        %======================================================================
        %> @brief Function checks if there are two consecutive ones [1 1] 
        %>        the given array
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param array Logical array
        %> @retval twoOnesInARow True is correct, false otherwise        
        % ======================================================================                                    
        function twoOnesInARow = checkIfTwoOnesInARow(obj, array)
            twoOnesInARow = false;
            previous = 0;
            for i=1:length(array)
                if(array(i) == true && previous == true)
                    twoOnesInARow = true;
                    break
                end
                previous = array(i);                        
            end             
        end        
        
        %======================================================================
        %> @brief Function checks if two numbers are equal within a given
        %>        deviation in percentage
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param f1 Number 1
        %> @param f2 Number 2
        %> @retval isEqual True if correct, false otherwise        
        % ======================================================================         
        function isEqual = compareNumber(obj, f1, f2, allowedDeviation)        
            deviation = abs(f1-f2)/f1;
            if(deviation > allowedDeviation)
                isEqual = false;
            else
                isEqual = true;
            end            
        end
        
        %======================================================================
        %> @brief Function removes sets that are outside given allowed thickness
        %>        range
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param set reference to array of HarmonicSet                        
        %> @param dMin Minimum thickness
        %> @param dMax Maximum thickness
        %> @retval setRet Remaining set indexes
        % ======================================================================          
        function setRet = removeInvalidSets(obj, set, dMin, dMax)
            
            set = set(([set.thickness] >= dMin) & ([set.thickness ] <= dMax)) ;
            setRet = set;            
        end             
        
        %======================================================================
        %> @brief Function can plot sets of type resonance or absroption. 
        %>
        %> Usage:
        %> plotAllSets('resonance'):        Will plot all sets from
        %>                                      resonance
        %> plotAllSets('absorption'):       Will plot all sets from
        %>                                      absorption spectrum        
        %> plotAllSets('resonance','A'):    Will only plot sets with class 'A'
        %> plotAllSets('resonance','B'):    Will only plot sets with class 'B'
        %> plotAllSets('resonance',[ 1 2 3]): Will plot sets 1,2 and 3
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param type Psd type 'resonance' or 'absorption'
        %> @param varargin class or set index
        % ======================================================================         
        function plotAllSets(obj, type, varargin)
                     
            if(strcmp(type, 'resonance'))                
                psd = obj.psdResonance;
                set = obj.setResonance;
            elseif(strcmp(type, 'absorption'))                
                psd = obj.psdMain;
                set = obj.setMain;
            else
                error('Unknown type')
            end
                
            if(nargin == 3)
                searchClass = varargin{1};
                
                if(isnumeric(searchClass))
                    for i = 1:length(searchClass)
                        set(searchClass(i)).plotSet(psd, obj.config.SAMPLE_RATE);   
                    end                    
                else
                    % Find set with class 'searchClass'
                    setClass = obj.findSetWithClass(set, searchClass);

                    if(isempty(setClass))
                        fprintf('No sets with class %s found\n',searchClass);
                    else
                        fprintf('Plotting sets with class %s\n',searchClass);
                        for index = 1:length(setClass)
                            set(setClass(index)).plotSet(psd, obj.config.SAMPLE_RATE);
                        end
                    end
                    
                end
            else
                for index = 1:length(set)
                    set(index).plotSet(psd, obj.config.SAMPLE_RATE);
                end
                
            end            
        end
             
        %======================================================================
        %> @brief Function calculates set thickness
        %>        1. The average frequency is calculated          
        %>        2. Thickness is calculated for each set. 
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param set reference to array of HarmonicSet                        
        %> @retval set
        % ======================================================================                
        function set = calculateSetThickness(obj, set)
                        
            for index = 1:length(set)
                averageF0 = set(index).calculateAverageFreqDiff;                                                                
                set(index).thickness = obj.config.V_PIPE/(2*averageF0);
                
                % Alternativ method for calculating averageF0
                %medianF0 = set(index).calculateMedianFreqDiff;
                %set(index).thickness = obj.config.V_PIPE/(2*medianF0);
            end                        
        end
        
        %======================================================================
        %> @brief Function calculates Set validation parameters and class        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param set reference to array of HarmonicSet                        
        %> @param psdNoise Noise psd                       
        %> @retval set 
        % ======================================================================            
        function set = calculateSetValidationParameters(obj, set, psdNoise)
        
            for i = 1:length(set)
                set(i).calculateValidationParameters(psdNoise, obj.meanNoiseFloor, obj.config.Q_DB_ABOVE_NOISE, obj.config.Q_DB_MAX);
                set(i).findVpClass(obj.config.SAMPLE_RATE, obj.config.FFT_LENGTH);
            end                        
        end                
        
        %======================================================================
        %> @brief Experimental function: Calculate thickness 
        %>        1. Uses interpolation to get a better estimate of the 
        %>           peak position.
        %>        2. Then calculates the average distance between the peaks
        %>        3. And then use this for calculating the thickness
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                                
        %> @retval set 
        % ======================================================================        
        function set = calculateSetThicknessWithInterpolation(obj, set)
            
            for index = 1:length(set)
                psdIndexArray = obj.interpolatePeaks(obj.psdResonance, set(index));
                freqArrayIntp = psdIndexArray * (obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH);
                
                averageF0 = set(index).calculateAverageFreqDiff(freqArrayIntp);
             
                              
                set(index).thickness = obj.config.V_PIPE/(2*averageF0);
            end            
        end
                        
        %======================================================================
        %> @brief Function retrieves the requested window
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                                
        %> @retval type Type of window: 'rect', 'hamming', 'hanning',
        %>              'kaiser'
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
                    
                case 'kaiser'
                    win = kaiser(length, 2.5);                    

                otherwise
                    error('Window type not supported');                    
            end                        
        end                       
        
        %======================================================================
        %> @brief Function 
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                                
        %> @retval type Type of window: 'rect', 'hamming', 'hanning',
        %>              'kaiser'
        % ======================================================================         
        function locs = interpolatePeaks(~, psd, set)
                        
            locsToInterpolate = set.psdIndexArray;
            
            locs = zeros(1, length(locsToInterpolate));
            deltaPoint = 2;
            interpolation_factor = 10;     
            for index = 1:length(locsToInterpolate)
                
                loc = locsToInterpolate(index);
                x = loc-deltaPoint:loc+deltaPoint;                   
                y = psd(loc-deltaPoint:loc+deltaPoint)';
                                               
                interpolationRange = (loc-deltaPoint):1/interpolation_factor:(loc+deltaPoint);  
                
                interpolatedCurve = interp1(x, y,interpolationRange,'spline');
                %figure
                %plot(interpolatedCurve)
                %plot(y, x,'o',interpolationRange,interpolatedCurve,':.');    
                %title('Spline Interpolation');                
                [~,locationIndex] = max(interpolatedCurve);
                
                locs(index) = interpolationRange(locationIndex);
            end            
        end
    end    
end



