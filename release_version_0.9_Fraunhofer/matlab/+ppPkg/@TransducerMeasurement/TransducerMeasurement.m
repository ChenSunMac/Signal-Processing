classdef TransducerMeasurement < matlab.mixin.Copyable
    % TransducerMeasurement will contain raw data from one transducer measurement
    % 
    
    properties
        signal          single  % Recorded signal 
        date                    % Date
                                % Year | Month | day
        fireTime        uint64  % Time in 10 ms accuracy
                                % hour | minute | second | millisecond
        sampleRate      uint32  % SampleRate
        groupId         uint8
        transducerId    uint8   % Transducer Id        
        fLow            uint32  % Lower frequency
        fHigh           uint32  % Higher frequency
        roll            uint16  % Roll in 0.01 degrees
        pitch           uint16  % Pitch in 0.01 degrees
        xPos            single  % x position
        yPos            single  % y position
        zPos            single  % z position  
        uPos            single  % u position  
        startTimeRec    uint16  % Number of samples delay before recording is started               
            
    end
    
    
    properties (Dependent)
        numSamples        uint32 % Number of samples in data
        fireDateTimeDisp 
        
    end
    methods
        % Constructor
        function obj = TransducerMeasurement(recordedSignal, sampleRate, fLow, fHigh)
            if nargin == 4
                obj.signal = recordedSignal;
                obj.sampleRate = sampleRate;                
                obj.fLow = fLow;
                obj.fHigh = fHigh;                
            end
        end
        
        function n = get.numSamples(obj)
            n = length(obj.signal);
        end    
        
        function t = get.fireDateTimeDisp(obj)
            % Test function to display fire date time
            timeTm  = num2str(obj.fireTime);
            dateTm =  num2str(obj.date);
            if(numel(timeTm) == 7)
                % Append a zero to string
                timeTm = strcat('0',timeTm);
            end

            datetimeTm = strcat(dateTm,timeTm);
            t = datetime(datetimeTm, 'InputFormat', 'yyyyMMddHHmmssSS','Format','d-MMM-y HH:mm:ss:SS' );

        end    
        
        function plotDataInTime(obj)
            t = 0:1/obj.sampleRate:(obj.numSamples-1)/obj.sampleRate;                        
            plot(t,obj.signal);
            xlabel('Time[sec]');
        end
                   
    end    
end

