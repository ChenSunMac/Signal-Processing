        %======================================================================
        %> @brief Function checks if two numbers are equal within a given
        %>        deviation in percentage
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param f1 Number 1
        %> @param f2 Number 2
        %> @retval isEqual True if correct, false otherwise        
        % ======================================================================         
        function isEqual = compareNumber(f1, f2, allowedDeviation)        
            deviation = abs(f1-f2)/f1;
            if(deviation > allowedDeviation)
                isEqual = false;
            else
                isEqual = true;
            end            
        end