        %======================================================================
        %> @brief Function finds set candidate based on thickness score
        %>        1. Check if there are any sets with double or trippel thickness  
        %>           compared to the thickness given by setCandidate. 
        %>        2. If there are sets with double or trippel thickness
        %>           they are probably the correct sets representing the real thickness
        %>           of the pipe wall.
        %>        3. If there are neither sets with double or trippel
        %>           thickness: Compare the setCandidate members. If the
        %>           are several members. Start selecting the ones with
        %>           highest class.
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet
        %> @param setCandidate 
        % ======================================================================         
        function [setCandidateOut] = findCandidateBasedOnThicknessScore(set, setCandidate)
                   
                % Find number of sets with double thickness compared to
                % setCandidate
                PERCENTAGE_DEVIATION = 10;
                doubleThickness = 2 * set(setCandidate).thickness;
                [countDouble, setsDouble] = findNumberOfSetsWithThickness(doubleThickness, set, PERCENTAGE_DEVIATION);
                if(countDouble > 0)
                    set(setCandidate).scoreDoubleThickness = countDouble;
                end

                % Find number of sets with trippel thickness compared to
                % setCandidate
                trippelThickness = 3 * set(setCandidate).thickness;
                [countTrippel, setsTrippel] = findNumberOfSetsWithThickness(trippelThickness, set, PERCENTAGE_DEVIATION);
                if(countTrippel > 0)
                    set(setCandidate).scoreTrippelThickness = countTrippel;
                end   
                
                % Select the score that is highest of countTrippel and
                % countDouble 
                if(countTrippel < countDouble )
                    % Double thickness
                    
                    % Out of the sets with double thickness find the ones
                    % with highest subset score
                    setCandidateTemp = setsDouble([set(setsDouble).scoreSubset] == max([set(setsDouble).scoreSubset]));                    
                    
                    % Select the ones with highest average energy
                    if(numel(setCandidateTemp) > 1 )                    
                        setCandidateTemp = findSetWithHighestAveragePeakEnergy(set, setCandidateTemp);
                    end                                     
                    
                    % Select the one with lowest deviation from target
                    % frequency
                    if(numel(setCandidateTemp) > 1 )                    
                        [setCandidateTemp] = findSetWithLowestDeviation(set, setCandidateTemp);
                    end                    
                                       
                    %if(set(setCandidateTemp).scoreSubset >= 1 || countSetsWithCandidateThickness > 1 )
                        setCandidateOut = setCandidateTemp(1);
                    %end
                    
                    
                elseif(countTrippel > countDouble)
                    % Trippel thickness
                    setCandidateTemp = setsTrippel([set(setsTrippel).scoreSubset] == max([set(setsTrippel).scoreSubset]));                                   
                    
                    % Select the ones with highest average energy
                    if(numel(setCandidateTemp) > 1 )                    
                        setCandidateTemp = findSetWithHighestAveragePeakEnergy(set, setCandidateTemp);
                    end 
                    % Select the ones with most harmonics
                    if(numel(setCandidateTemp) > 1 ) 
                        [setCandidateTemp, ~] = findSetWithMostHarmonics(set(setCandidateTemp), setCandidateTemp);
                    end                       
                    
                    % Select the one with lowest deviation from target
                    % frequency
                    if(numel(setCandidateTemp) > 1 )                    
                        [setCandidateTemp] = findSetWithLowestDeviation(set, setCandidateTemp);
                    end                                           
                    
                    %if(set(setCandidateTemp).scoreSubset >= 1 || countSetsWithCandidateThickness > 1)
                        setCandidateOut = setCandidateTemp(1);
                    %end
                    
                else                                        
                    % There was no candidates with do  
                    if( ~isempty(set(setCandidate).setMember) )
                        
                        candidateClass = set(setCandidate).class;
                        members = set(setCandidate).setMember;

                        % Select the members with the same class or higher
                        switch candidateClass
                            case 'A'                                
                                membersWithClass = members(findSetWithClass(set(members), candidateClass));                    
                            case 'B'
                                membersWithClass = members(findSetWithClass(set(members), 'A'));                    
                                membersWithClass = [membersWithClass members(findSetWithClass(set(members), 'B'))];                    
                            case 'C'
                                membersWithClass = members(findSetWithClass(set(members), 'A'));                    
                                membersWithClass = [membersWithClass members(findSetWithClass(set(members), 'B'))];                                                    
                                membersWithClass = [membersWithClass members(findSetWithClass(set(members), 'C'))];                                                    
                            case 'D'
                                membersWithClass = members(obj.findSetWithClass(set(members), 'A'));                    
                                membersWithClass = [membersWithClass members(findSetWithClass(set(members), 'B'))];                                                    
                                membersWithClass = [membersWithClass members(findSetWithClass(set(members), 'C'))];                                                    
                                membersWithClass = [membersWithClass members(findSetWithClass(set(members), 'D'))];                                                    
                        end
                                
                        
                        setCandidateOut = findSingleSetCandidateHelperFunction(set, membersWithClass);
                        %@TODO fix this
                        setCandidateOut = setCandidateOut(1);
                    
                    else
                        setCandidateOut = setCandidate; 
                    end
                end                
        end