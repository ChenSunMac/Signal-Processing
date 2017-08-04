%> @file ProcessingResult.m
%> @brief Class representing processing result for one transducer
% ======================================================================
%> @brief Class representing processing result for one transducer
%
%> 
% ======================================================================
classdef ProcessingResult < matlab.mixin.Copyable
    
    properties
        %> Date when transducer data was recorded
        date            
        %> Fire time in micro seconds
        fireTime        uint64
        %> Group Id
        groupId         uint16
        %> Transducer Id [1, ->]
        transducerId    uint16
        %> File index 
        fileIndex       uint32
        %> Shot index 
        shotIndex       uint32
        %> Thickness [m] 
        thickness = single(0)          
        %> Set number 
        setNo           uint16
        %> Calliper distance [m]
        calliper = single(0)
        %> Roll
        roll            uint16
        %> Pitch
        pitch           uint16
        %> IMU data X position
        xPos            single
        %> IMU data Y position
        yPos            single
        %> IMU data Z position
        zPos            single
        uPos            single
        %> Validation parameters
        vp = single([0 0 0 0 0 0])
        %> Classification
        class = 'D'
        
        snr          = single(0)
        
        psdResonance
        fMain
        psdMain
        pMain
        noiseMean  
        peakDB
    end
    
    properties (Dependent)
        fireDateTimeDisp
    end
    
    properties (Hidden)
        % Experimental properties
        thicknessSecond = single(0)
        thicknessMain = single(0)
        calliperPitDetect = single(0)
        debug = single(0)
    end

    
    methods
        % ======================================================================
        %> @brief Class constructor
        %>
        %> @retval instance of the ProcessingResult class
        % ======================================================================          
        function obj = ProcessingResult()
          
        end
        
        % ======================================================================
        %> @brief Function copies properties from transducer measurement
        %>        to processing result
        %>
        %> @param obj reference to ProcessingResult object
        %> @param tm reference to TransducerMeasurement object  
        % ======================================================================          
        function setPrPropertiesFromTm(obj, tm)
            obj.date = tm.date;
            obj.fireTime = uint64(tm.fireTime);   
            obj.transducerId = uint16(tm.transducerId);
            obj.groupId = uint16(tm.groupId);
            obj.roll = uint16(tm.roll);                               
            obj.pitch = uint16(tm.pitch);                               
            obj.xPos = single(tm.xPos);                               
            obj.yPos = single(tm.yPos);
            obj.zPos = single(tm.zPos);
            obj.uPos = single(tm.uPos);
            
        end
   
        
        % ======================================================================
        %> @brief Function for dependent parameter fireDateTimeDisp        
        %>
        %> @param obj Reference to ProcessingResult object
        %> @retval t  datetime object
        % ======================================================================              
        function t = get.fireDateTimeDisp(obj)
            
            % Test function to display fire date time
            timeTm  = num2str(obj.fireTime);
            
            if(isnumeric(obj.date))
                dateTm =  num2str(obj.date);
               if(numel(timeTm) == 7)
                    % Append a zero to string
                    timeTm = strcat('0',timeTm);
                end

                datetimeTm = strcat(dateTm,timeTm);
                t = datetime(datetimeTm, 'InputFormat', 'yyyyMMddHHmmssSS','Format','d-MMM-y HH:mm:ss:SS' );

            else
                dateTm = char(obj.date);


                datetimeTm = strcat(dateTm,timeTm);
                
                t = datetime(datetimeTm, 'InputFormat', 'dd-MMM-yyyy HH:mm:ssSS','Format','d-MMM-y HH:mm:ss:SS' );

            end
            
 
        end          
    end    
end

