    function [setCandidate setCandidateWithBetterClass groupsWithMostSets] = findBestSetB(obj, group, set)
        %% 1. Find group with most sets
         % 2. Pick set with most harmonic energy in group
         % 3. If another set has better class pick this set too
         
            % Find largest group size
            groupMaxSize = 0;
            for index = 1:length(group)
                if(groupMaxSize < group(index).count)
                    groupMaxSize = group(index).count;
                end
            end
            
            % Find groups that have size == groupMaxSize
            groupsWithMostSets = [];
            for index = 1:length(group)
                if(groupMaxSize == group(index).count)
                    groupsWithMostSets(end+1) = index;
                end
            end
            
            setCandidate = [];
            % Find set with most harmonic energy in largest group
            for index = 1:length(groupsWithMostSets)
                setCandidate(end + 1) = group(groupsWithMostSets(index)).setWithMaxDb;  
            end
  
            [setCandidate]
            setCandidateUpdated = [setCandidate];
            % In each group check if there is a set with better class than
            % the setCandidate. 
            for index = 1:length(groupsWithMostSets)
                currentSet = setCandidate(index)
                classCandidate = set(setCandidate(index)).class;
                bestClassSet = [];
                for setIndex = group(groupsWithMostSets(index)).group
                     
                     if(set(setIndex).class < classCandidate)
                         bestClassSet(end+1) = setIndex  ;     
                     end
                end
                
                setCandidateUpdated = unique([setCandidateUpdated, bestClassSet]);                
            end
            
            %setCandidate = setCandidateUpdated;
            setCandidateWithBetterClass = setCandidateUpdated;
            
        end
        

        
        function [setCandidate] = findSetWithHighestEnergy(obj, group, set)
        %% 1. Find set with highest peak energy
         
            peakEnergy = 0;
            for setIndex = 1:length(set)
                peakEnergyTemp = set(setIndex).validationParameter(5);
                if( peakEnergyTemp > peakEnergy)
                    peakEnergy = peakEnergyTemp;
                    setCandidate = setIndex;
                end
            end
        end
                
        function [groupCandidate] = findGroupWithHighestAverageEnergy(obj, group, set)
            % Find the group with highest average energy.
            groupCandidate = 0;
            
            maxGroupAverage = 0;
            
            for groupIndex = 1:length(group)
                
                groupEnergy = [];
                for setIndex = 1:length(group(groupIndex).group)
                    groupEnergy(end+1) = set(group(groupIndex).group(setIndex)).validationParameter(6);
                end
                
                groupAverageTemp = mean(groupEnergy);
                
                if(groupAverageTemp > maxGroupAverage)
                    maxGroupAverage = groupAverageTemp;
                    groupCandidate = groupIndex;
                end
            end       
        
        end
        
        function group = groupSetsMethodA(obj, set)
        %% Function will find sets that have two or more equal frequencies 
        %  in a row, and group them together in a SetGroup class. 
        %  Function returns an array of objects of the SetGroup class
           
            import ppPkg.*;
            groupCount = 0;
            for n = 1:(length(set)-1)
                for m = (n+1):length(set)
                    %fprintf('Index n:%d m:%d \n',n ,m);
                    arrayA = ismember(set(n).psdIndexArray, set(m).psdIndexArray);
                    arrayB = ismember(set(m).psdIndexArray, set(n).psdIndexArray);
                    
                    if(true == obj.checkIfTwoOnesInARow(arrayA) && ...
                       true == obj.checkIfTwoOnesInARow(arrayB) && ...
                       true == obj.compareNumber(set(n).averageFreqDiff, set(m).averageFreqDiff, 5/100))   
                        fprintf('Sets %d %d %d\n',n,m, obj.compareNumber(set(n).averageFreqDiff, set(m).averageFreqDiff, 5/100));
                        if(groupCount == 0)
                            % First time: Create a new group containing set n and m
                            group = SetGroup(n,m);
                            groupCount = groupCount + 1;
                        else
                            % Init state variable
                            setsAdded = false;
                            for index = 1:length(group)
                                % Check if n, m can be added to a existing group
                                if((setsAdded == false) && (group(index).addSets(n,m) == true))
                                    setsAdded = true;
                                end
                            end
                                
                            % If sets n and m could not be added to an
                            % existing group, create a new group
                            if(setsAdded == false)
                                groupCount = groupCount + 1;
                                group(index+1) = SetGroup(n,m);
                            end                            
                        end
                    end                        
                end           
            end
            
            
            
        end
        
        function group = groupSetsBasedOnAverageFrequency(obj, set)
        %% Function will find sets that have equal average frequency and group them together 
        %   
        %  Function returns an array of objects of the SetGroup class
           
            import ppPkg.*;
            groupCount = 0;
            for n = 1:(length(set)-1)
                for m = (n+1):length(set)
                    %fprintf('Index n:%d m:%d \n',n ,m);                    
                    if(true == obj.compareNumber(set(n).averageFreqDiff, set(m).averageFreqDiff, 5/100))   
                        %fprintf('Sets %d %d %d\n',n,m, obj.compareNumber(set(n).averageFreqDiff, set(m).averageFreqDiff, 5/100));
                        if(groupCount == 0)
                            % First time: Create a new group containing set n and m
                            group = SetGroup(n,m);
                            groupCount = groupCount + 1;
                        else
                            % Init state variable
                            setsAdded = false;
                            for index = 1:length(group)
                                % Check if n, m can be added to a existing group
                                if((setsAdded == false) && (group(index).addSets(n,m) == true))
                                    setsAdded = true;
                                end
                            end
                                
                            % If sets n and m could not be added to an
                            % existing group, create a new group
                            if(setsAdded == false)
                                groupCount = groupCount + 1;
                                group(index+1) = SetGroup(n,m);
                            end                            
                        end
                    end                        
                end           
            end                            
        end
        
        function group = groupSetsMethodC(obj, set)
        % Group sets based on average frequency
            import ppPkg.*;
           
            
            % Initial
            group = SetGroup2(1);
            groupCount = 1;
            
            for n = 2:(length(set))
                setAdded = false;
                for k = 1:length(group)
                    if(group(k).tryAddSet(n, set))
                        setAdded = true;
                        break
                    end
                end
                
                if(setAdded == false)
                    % Add set to new group
                    groupCount = groupCount +1;
                    group(groupCount) = SetGroup2(n);
                end
                
            end
        end
        
        function groupMax = findSetWithMaxDBInEachGroup(obj, group, set)
        %% Function finds set with max peak energy for each group     
            groupMax = zeros(1,length(group));
            for groupIndex = 1:length(group)
                peakDB = 0;
                elementsInGroup = length(group(groupIndex).group); 
                for index = 1:elementsInGroup;
                    setIndex = group(groupIndex).group(index);
                    peakTemp = set(setIndex).validationParameter(5);
                    if(peakTemp > peakDB)
                        groupMax(groupIndex) = setIndex;
                        peakDB = peakTemp;
                    end
                end
                
                group(groupIndex).setWithMaxDb = groupMax(groupIndex); 
            end            
        end        
