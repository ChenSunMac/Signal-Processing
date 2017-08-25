        %======================================================================
        %> @brief Function returns sets with given class
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        %> @param class
        %> @param varargin Array of set indices to search within
        %> @retval setsWithMaxSize Index to sets with given class
        % ======================================================================        
        function setsWithGivenClass = findSetWithClass(set, class, varargin)

            if(nargin > 3)
                arrayOfSetIndicesToSearch = varargin{1};    
            else
                arrayOfSetIndicesToSearch = 1:length(set);
            end
                    
            setsWithGivenClass = arrayOfSetIndicesToSearch([set(arrayOfSetIndicesToSearch).class] == class);            
        end 
        