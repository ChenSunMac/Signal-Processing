classdef SetGroup < handle
    % Group of HarmonicSet that belongs together.
    %  
    
    properties
        group
        count = 0;
        setWithMaxDb
        set
    end
    
    methods
        
        function obj = SetGroup( setIndex1, setIndex2 )
            % Constructor
            if nargin == 2
                obj.group = [ setIndex1, setIndex2 ];
                obj.count = 2;
            else
                error('Constructor must have 2 arguments')
            end  
        end
        
        function ret = addSets(obj, setIndexN, setIndexM)
        % Function returns true if setIndexN and setIndexM belongs to this group
            intersect1 = intersect(obj.group, setIndexN);
            intersect2 = intersect(obj.group, setIndexM);
        
            if( length(intersect1) > 0 || length(intersect2) > 0)
                ret = true;
                tempGroup = [ obj.group, setIndexN, setIndexM ];
                obj.group = unique(tempGroup);
                obj.count = length(obj.group);
            else
                ret = false;
            end            
        end
        
        
        function combineSets(obj, set, psd)
            import ppPkg.HarmonicSet
            tempCombined = [];
            SAMPLE_RATE = 15e6;
            FFT_LENGTH = 4096;

            for index = 1:length(obj.group)

                tempCombined = [set(obj.group(index)).psdIndexArray, tempCombined];
                tempCombined = unique(tempCombined);
            end
            
            peakLocation = tempCombined;
            freq = [];
            for loc = peakLocation
                freq(end+1) = (loc-1)*SAMPLE_RATE/FFT_LENGTH;
            end
            
            obj.set = HarmonicSet(freq, psd(peakLocation)', peakLocation);
            
            obj.set.freqDiff = mean([set(obj.group).freqDiff]);
            obj.set.calculateAverageFreqDiff();
            
        end
    end
    
end

