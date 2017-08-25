        %======================================================================
        %> @brief Function returns the set with most harmonics frequencies        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        %> @param varargin Array of set indices to search within
        % ======================================================================        
        function [setsWithMaxSize, maxSize] = findSetWithMostHarmonics(set, varargin)            
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