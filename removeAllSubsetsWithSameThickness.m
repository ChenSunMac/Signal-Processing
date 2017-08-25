        %======================================================================
        %> @brief Function removes all subsets with approx. same thickness
        %>        A set will get a score of one for each subset that it
        %>        contains
        %>        A setA will have a subset, subsetB, if all harmonics in subsetB
        %>        are also in setA. SubsetB is only removed if setA and
        %>        subsetB has the same thickness within 10%
        %>        
        %> @param obj instance of the ThicknessAlgorithm class.
        %> @param set reference to resonance sets or main sets        
        % ======================================================================           
        function set = removeAllSubsetsWithSameThickness(set)
                         
            n = 1;
            while( n < numel(set) )                
                m = n + 1;
                while( m <= numel(set) )
                    %fprintf('Index n:%d m:%d \n',n ,m);
                    
                    if(numel(set(n).psdIndexArray) >= numel(set(m).psdIndexArray))
                        memberArray = ismember(set(m).psdIndexArray, set(n).psdIndexArray);
                        setIndexToRemove = m;
                    else
                        memberArray = ismember(set(n).psdIndexArray, set(m).psdIndexArray);
                        setIndexToRemove = n;
                    end

                    % Check if all element in memberArray is logical 1                    
                    if(sum(memberArray) == numel((memberArray)) && ...
                      ( abs(set(m).thickness - set(n).thickness)/(set(m).thickness) < 0.1 ))                        
                         
                        % Increment subset score
                        if( n ~= setIndexToRemove ) 
                            set(n).scoreSubset = set(n).scoreSubset + 1 + set(m).scoreSubset;
                            set(setIndexToRemove) = [];
                        else
                            set(m).scoreSubset = set(m).scoreSubset + 1 + set(n).scoreSubset;                            
                            set(setIndexToRemove) = [];
                            % Substract n with 1 since one set has been
                            % removed
                            n = n - 1; 
                            % Break inner while loop
                            break;
                        end                           
                    else
                        % Increment m
                        m = m + 1;
                    end
                end
                % Increment n
                n = n + 1; 
                               
            end        
        end   