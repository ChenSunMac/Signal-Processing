        %======================================================================
        %> @brief Function find set candidates based on combining group and
        %>        subset score and looks at the sets with the highest
        %>        score.
        %>        The sets with the two highest combined score
        %>        are used as set candidates
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @retval setCandidate index to set candidiate
        % ======================================================================        
        function [setCandidate] = findSetBasedOnCombinedGroupAndSubsetScore(set)
            
            setIndex = 1:numel(set); 
            
            % Calculated the combined score and add 1 to each score type
            scoreCombinedGroupAndSubset = ([set.scoreGroupCount] + 1) .* ([set.scoreSubset]+ 1);                        
            
            if( sum(scoreCombinedGroupAndSubset) > 0)

                % Use the two highest scores
                scores = sort(unique(scoreCombinedGroupAndSubset),'descend');                                
                
                % Find the set with the highest score
                idxl = (scoreCombinedGroupAndSubset == scores(1));          
                setCandidatesTemp = setIndex(idxl); 

               % Find the set with the next highest score
                if(numel(scores) > 1 )                    
                    % Score must be higher than 1 to be considered
                    if(scores(2) > 1)
                        idx2 = (scoreCombinedGroupAndSubset == scores(2));          
                        setCandidatesTemp = [setCandidatesTemp setIndex(idx2)];                 
                    end
                end
                
                % With a high scoreGroupCount that is a good indication that
                % these sets represent the correct thickness.
                % Could then search for all sets with this thickness to find
                % even more. 

                setCandidates = zeros(1,numel(setCandidatesTemp));
                for i = 1:numel(setCandidatesTemp)
                     setCandidates(i) = findCandidateBasedOnThicknessScore(set, setCandidatesTemp(i));
                end
                                
                setCandidates = unique(setCandidates);
                
                % If there are several candidates return the "best" one
                if(numel(setCandidates) > 1 )
                    setCandidate = findSingleSetCandidateHelperFunction(set, setCandidates);
                else
                    setCandidate = setCandidates;
                end 
                                
            else
               setCandidate = [];
            end                                
        end