        %======================================================================
        %> @brief Function returns sets with lowest deviation
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                        
        %> @param varargin Array of set indices to search within
        %> @retval setWithLowestDeviation Index to sets with lowest
        %>                                deviation
        % ======================================================================                         
        function setWithLowestDeviation = findSetWithLowestDeviation( set, varargin)          
        
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