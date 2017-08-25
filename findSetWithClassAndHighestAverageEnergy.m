        %======================================================================
        %> @brief Function find a set with a given class from all sets in the 
        %>        set array or from a group of sets in set array.
        %>        If there are several sets with given class this function
        %>        will return the one highest average peak
        %>        energy.
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        %> @param class Set class ('A', 'B', 'C', 'D')
        % ======================================================================         
        function setCandidate = findSetWithClassAndHighestAverageEnergy(set, class)
         
            setsWithGivenClass = findSetWithClass(set, class);
            
            % If several candidates, return the one with highest average 
            % peak energy
            if( length(setsWithGivenClass) > 1)
            
                setCandidate = findSetWithHighestAveragePeakEnergy(set, setsWithGivenClass);                                   
                                           
            elseif(length(setsWithGivenClass) == 1)                
                setCandidate = setsWithGivenClass;                
            else
                setCandidate = [];
            end                 
        end
        