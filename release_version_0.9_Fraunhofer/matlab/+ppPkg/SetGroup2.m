classdef SetGroup2 < handle
    % Class to represent a group of sets
    % Sets can be added to group if the deviation is less than a set
    % percentage
    
    properties
        group
        meanFreq
        count = 0;
        deviationP = 5;     % Deviation Percentage
        setWithMaxDb
    end
    
    methods
        function obj = SetGroup2( setIndex )
            % Constructor
            if nargin == 1
                obj.group = [ setIndex ];
                obj.count = 1;
            else
                error('Constructor must have 1 arguments')
            end  
        end
        
        function setAdded = tryAddSet( obj, index, set )
            
            intersectA = intersect(obj.group, index);
            if(length(intersectA) > 0)
                setAdded = false;
                return
            end
            
            freqs = [set(obj.group).averageFreqDiff];
            meanFreq = mean(freqs);
            freqToAdd = set(index).averageFreqDiff;
            deviation = 100*abs(meanFreq-freqToAdd)/meanFreq;
            
            % TODO: Check that index is not already in group, use intersect
            
            if(deviation > obj.deviationP)
                setAdded = false;
            else
                setAdded = true;
                obj.count = obj.count + 1;
                obj.group(obj.count) = index;
            end
            
        end
    end
    
end

