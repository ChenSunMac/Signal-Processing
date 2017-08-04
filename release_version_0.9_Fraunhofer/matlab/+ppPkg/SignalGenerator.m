classdef SignalGenerator < handle
    
    properties
        type,
        sampleRate, 
        lengthInTime,             
        fLow, 
        fHigh      
        signal
        time
    end
    
    properties (Dependent)
        lengthInSamples              
    end    
           
    methods
        
        %======================================================================
        %> @brief Class constructor
        %> 
        %> @param type Type of signal
        %> @param sampleRate Sample rate
        %> @param lengthInTime Length in seconds
        %> @param fLow Lower frequency
        %> @param fHigh Higher frequency
        %> @retval obj instance of the SignalGenerator class.         
        % ======================================================================                   
        function obj = SignalGenerator(type, sampleRate, lengthInTime, fLow, fHigh)
            
            type = lower(type);
            
            switch type
                case 'sin'
                case 'sinc'                
                case 'chirp'
                case 'chirptest'
                case 'rectchirp'
                case 'simple'
                %case 'rectpulse'            
                otherwise
                    error('Signal type not supported')
            end
            
            obj.type = type;
            
            obj.sampleRate = sampleRate;
            obj.lengthInTime = lengthInTime;
            
            
            if(fLow > fHigh )
                error('fLow must be lower or equal to fHigh')
            end
            
            obj.fLow = fLow;
            obj.fHigh = fHigh;
            
            obj.createSignal();
                                                            
        end
        %======================================================================
        %> @brief Get function for lengthInSamples property
        %> 
        %> @param obj instance of the SignalGenerator class.         
        % ======================================================================           
        function value = get.lengthInSamples(obj)                        
            value = obj.lengthInTime * obj.sampleRate;       
        end        
        
        %======================================================================
        %> @brief Function creates requested signal
        %> 
        %> @param obj instance of the SignalGenerator class.         
        %> @retval x created signal 
        %> @retval t time array
        % ======================================================================         
        function [x, t] = createSignal(obj)
            
            switch obj.type
                case 'sin'  
                case 'simple' 
                    [x, t] = obj.generateSin();                
                case 'sinc'                    
                    [x, t] = obj.generateSinc();            
                case 'chirp'
                    [x, t] = obj.generateChirp();
                case 'chirptest'                    
                    [x, t] = obj.generateChirpExperiment();
                case 'rectchirp'                    
                    [x, t] = obj.generateChirp();            
                     x = sign(x);  
                     
%                 case 'rectpulse'            
%                     % call generate rect pulse
%                     numberOfPulses = fHigh;
%                     width = fLow;
%                     [x, t] = generateRectPulseTrain( sampleRate, length, width, numberOfPulses );
%                     x = flip(x);
                otherwise
                    error('Signal type not supported')
            end 
            
            obj.signal = x;
            obj.time = t;
        end

        %======================================================================
        %> @brief Function plots time signal
        %> 
        %> @param obj instance of the SignalGenerator class.                 
        % ======================================================================          
        function plotSignal(obj)
            figure
            plot(obj.time, obj.signal)
            titleTxt = sprintf('Signal: %s %sus %sMHz  %#1.2f-%#1.2f MHz',obj.type, num2str(obj.lengthInTime*1e6), num2str(obj.sampleRate/1e6), obj.fLow/1e6, obj.fHigh/1e6);
            title(titleTxt)
            grid on
            xlabel('[sec]')
        end

        %======================================================================
        %> @brief Function plots FFT of time signal
        %> 
        %> @param obj instance of the SignalGenerator class.                 
        % ======================================================================                
        function plotFFT(obj)
            figure
            
            FFT_LENGTH = 4096;%length(obj.signal);            
            
            Y = fft( obj.signal, FFT_LENGTH);
            f = obj.sampleRate*(0:(FFT_LENGTH/2))/FFT_LENGTH;
            P2 = abs(Y/FFT_LENGTH);
            P1 = P2(1:FFT_LENGTH/2+1);
            P1(2:end-1) = 2*P1(2:end-1);                        
            plot(f,P1);            
            
            titleTxt = sprintf('FFT: %s %sus %sMHz  %#1.2f-%#1.2f MHz',obj.type, num2str(obj.lengthInTime*1e6), num2str(obj.sampleRate/1e6), obj.fLow/1e6, obj.fHigh/1e6);
            title(titleTxt)
            xlabel('Frequency (f)')
            ylabel('|P(f)|')  
            grid on
        end   

        %======================================================================
        %> @brief Function plots PSD of time signal
        %> 
        %> @param obj instance of the SignalGenerator class.                 
        % ======================================================================                        
        function plotPSD(obj)
            figure
            
            FFT_LENGTH = length(obj.signal);            
            
             win = rectwin(length(obj.signal));     
            
            [psd, f] = periodogram(obj.signal, win, FFT_LENGTH, obj.sampleRate, 'psd');
            
            plot(f, 10*log10(psd))
            titleTxt = sprintf('PSD: %s %sus %sMHz  %#1.2f-%#1.2f MHz',obj.type, num2str(obj.lengthInTime*1e6), num2str(obj.sampleRate/1e6), obj.fLow/1e6, obj.fHigh/1e6);
            title(titleTxt)
            xlabel('Frequency (f)')
            ylabel('dB |P(f)|')  
            grid on
        end           
        
        %======================================================================
        %> @brief Function calculates the sinc pulse
        %> 
        %> @param obj instance of the SignalGenerator class.                 
        %> @retval x created signal
        %> @retval t time vector
        % ======================================================================                                
        function [ x, t ] = generateSinc(obj )
            fBandWidth = double(obj.fHigh - obj.fLow);
            fShift = double(obj.fLow + fBandWidth/2);    

            t = double((-obj.lengthInSamples/2)*(1/obj.sampleRate):1/obj.sampleRate:((obj.lengthInSamples/2)-1)*(1/obj.sampleRate));   % Time vector

            x = real(sinc(fBandWidth*(t)).* exp(1i*fShift*2*pi*(t)));
        end        
        
        %======================================================================
        %> @brief Function calculates the chirp pulse
        %> 
        %> @param obj instance of the SignalGenerator class.                 
        %> @retval x created signal
        %> @retval t time vector
        % ======================================================================                                        
        function [ x, t ] = generateChirp( obj)
            
            % Time vector
            t = 0:1/obj.sampleRate:(obj.lengthInSamples-1)*(1/obj.sampleRate);   
            
            x = chirp(t,obj.fLow,(obj.lengthInSamples-1)*(1/obj.sampleRate),obj.fHigh,'linear', 270);            
        end    
        
        
        function [ x, t ] = generateChirpExperiment( obj)

            % Time vector
            t = 0:1/obj.sampleRate:(obj.lengthInSamples-1)*(1/obj.sampleRate); 

            x = chirp(t,obj.fLow,(obj.lengthInSamples-1)*(1/obj.sampleRate),obj.fHigh,'linear', 270);
            
            mbFilt = designfilt('arbmagfir','FilterOrder',30, ...
                     'Frequencies',0:0.5e6:7.5e6,'Amplitudes',[1.0000    0.6000    0.2667    0.033    0.3000    0.4667    0.3333    0.3000    0.7667 0 0 0 0 0 0 0], ...
                     'SampleRate',15e6);


            x = filter(mbFilt, x); 
            
           
        end    
        
        %======================================================================
        %> @brief Function calculates the sinus pulse
        %> 
        %> @param obj instance of the SignalGenerator class.                 
        %> @retval x created signal
        %> @retval t time vector
        % ======================================================================                                                
        function [ x ,t ] = generateSin( obj )
            
            t = 0:1/obj.sampleRate:(obj.lengthInSamples-1)/obj.sampleRate;   % Time vector

            x = sin(obj.fLow*2*pi*t);
        end        
        
        %======================================================================
        %> @brief Function saves signal to file
        %>        filename is created based on signal type, bandwidth and
        %>        length
        %> 
        %> @param obj instance of the SignalGenerator class.                 
        % ======================================================================                                                
        function saveToFile(obj)
            %% Write signal to file
            
            % create filename            
            filename = sprintf('%s_%sk_%sk_%sus.txt',obj.type, num2str(obj.fLow/1000), num2str(obj.fHigh/1000), num2str(obj.lengthInTime*1e6) );

            % Create empty file
            csvwrite(filename, '');

            % Write file header
            fId = fopen(filename,'w');
            if fId < 0        
                error('Error opening filename %s', filename);
            end

            noBytes = fprintf(fId,'SignalType: %s\n', obj.type);
            noBytes = fprintf(fId,'Length: %u\n', round(obj.lengthInSamples));
            noBytes = fprintf(fId,'SampleRate: %d\n', obj.sampleRate);
            noBytes = fprintf(fId,'F_low: %d\n', obj.fLow);
            noBytes = fprintf(fId,'F_high: %d\n', obj.fHigh);
            %noBytes = fprintf(fId,'\n\n\n\n\n');        
            fclose(fId);

            % Write data samples
            dlmwrite(filename,obj.signal','precision','%10.10f','delimiter',',', '-append' )
                                       
        end            
    end    
end

