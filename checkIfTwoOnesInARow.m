        %======================================================================
        %> @brief Function checks if there are two consecutive ones [1 1] 
        %>        the given array
        %>
        %> @param obj instance of the ThicknessAlgorithm class.                        
        %> @param array Logical array
        %> @retval twoOnesInARow True is correct, false otherwise        
        % ======================================================================                                    
        function twoOnesInARow = checkIfTwoOnesInARow( array)
            twoOnesInARow = false;
            previous = 0;
            for i=1:length(array)
                if(array(i) == true && previous == true)
                    twoOnesInARow = true;
                    break
                end
                previous = array(i);                        
            end             
        end        
        