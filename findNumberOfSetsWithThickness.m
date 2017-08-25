        %======================================================================
        %> @brief Function returns sets with the given thickness within
        %>        given percentage range
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param thickness Thickness 
        %> @param set reference to array of HarmonicSet                        
        %> @param percentage 
        %> @retval count Number of sets found with given thickness   
        %> @retval sets Index to sets with given thickness
        % ======================================================================         
        function [count, sets] = findNumberOfSetsWithThickness(thickness, set, percentage) 
            
            % Allowed deviation
            allowedDeviation = percentage/100;
            
            % Vecorization
            indexArray = 1:numel(set);
            
            % Logical array for indexes that are less than allowed
            % deviation
            idxl = (abs((thickness - [set.thickness]))/thickness ) < allowedDeviation;
            
            % Sum to get number of sets 
            count = sum(idxl);
            
            sets = indexArray(idxl);            
        end