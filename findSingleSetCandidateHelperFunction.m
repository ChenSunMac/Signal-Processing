        %======================================================================
        %> @brief Function will select the candidate with the following
        %>        features:
        %>        - Most harmonics
        %>        - Highest average energy
        %>        - Lowest deviation
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @param setCandidates Index to possible set candidates
        % ======================================================================            
        function [candidate] = findSingleSetCandidateHelperFunction(set, setCandidates)
            
                % Select the ones with most harmonics
                if(numel(setCandidates) > 1 ) 
                    [setCandidates, ~] = findSetWithMostHarmonics(set(setCandidates), setCandidates);
                end

                % Select the ones with highest average energy
                if(numel(setCandidates) > 1 )                    
                    setCandidates = findSetWithHighestAveragePeakEnergy(set, setCandidates);
                end                    

                % Select the one with lowest deviation from target
                % frequency
                if(numel(setCandidates) > 1 )                    
                    [setCandidates] = findSetWithLowestDeviation(set, setCandidates);
                end 
                                
                candidate = setCandidates;                
        end