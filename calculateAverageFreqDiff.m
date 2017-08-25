       %======================================================================
        %> @brief Function calculates the average frequency difference 
        %>        between frequencies in the set
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param varargin Input if one want to use a subset of the frequencies
        % ======================================================================  
        function [averageDiff] = calculateAverageFreqDiff(obj, varargin)                    
        
            useWeightedAverage = true;
            if(nargin == 2)               
               diffArray = diff(varargin{1});
            else
               diffArray = diff(obj.freqArray);    
            end            
            
            % Find skipped frequencies
            divArray = round(diffArray/obj.freqDiff);
            
            % To take care of skipped harmonic frequencies
            diffArrayAdjusted = diffArray./divArray;
            
            if(useWeightedAverage)
                index = 1;
                diffArrayWeighted = zeros(1, sum(divArray));            

                % Create weigthed diffArray
                for n=1:length(divArray)
                    for k = 1:divArray(n)
                        diffArrayWeighted(index) = diffArrayAdjusted(n);
                        index = index + 1;
                    end
                end  
            end
                        
            averageDiff = mean(diffArrayAdjusted);            
            obj.averageFreqDiff = averageDiff;
        end   