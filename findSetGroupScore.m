        %======================================================================
        %> @brief Function calculates group score
        %>        A set will get a group score if two conditions are met:
        %>        - They must share two frequencies
        %>        - The two frequencies must be in a row
        %>        - The two sets must have the same thickness within 10%
        %>          margin        
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet        
        % ======================================================================               
        function findSetGroupScore(set)
            
            for i = 1:(numel(set)-1)
                for m = (i+1):numel(set)
                    x_im = ismember( set(i).psdIndexArray, set(m).psdIndexArray);
                    x_mi = ismember( set(m).psdIndexArray, set(i).psdIndexArray);        

                    if((true == checkIfTwoOnesInARow(x_im)) && ...
                       (true == checkIfTwoOnesInARow(x_mi)) && ...
                       (true == compareNumber(set(i).averageFreqDiff, set(m).averageFreqDiff, 10/100)) )

                        set(i).scoreGroupCount = set(i).scoreGroupCount + 1;
                        set(m).scoreGroupCount = set(m).scoreGroupCount + 1;
                        set(i).setMember = unique([i set(i).setMember m ]);
                        set(m).setMember = unique([m set(m).setMember i ]);
                    end
                end
            end                        
        end