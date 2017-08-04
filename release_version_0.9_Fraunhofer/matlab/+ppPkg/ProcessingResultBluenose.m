classdef ProcessingResultBluenose < handle
    
    properties
        date
        fireTime
        groupId
        transducerId
        fileIndex
        shotIndex
        thickness
        calliper   
        roll
        pitch
        yaw
        xPos
        yPos
        zPos
        uPos     
        class        
    end

    
    methods
        function obj = ProcessingResultBluenose()
            obj.thickness = 0;
            obj.calliper = 0;
                   
        end
        
        
    end
    
end



