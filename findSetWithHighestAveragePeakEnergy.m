        %======================================================================
        %> @brief Function returns the set with the highest average peak
        %>        energy
        %>
        %> @param obj instance of the ThicknessAlgorithm class.        
        %> @param set reference to array of HarmonicSet                
        %> @param varargin Array of set indices to search within
        %> @retval numberOfHarmoncsExpected in the range given
        % ======================================================================              
        function [setWithHighestPeakEnergy] = findSetWithHighestAveragePeakEnergy(set, varargin)
            
            import ppPkg.VP;
            
            if(nargin > 2)
                arrayOfSetIndicesToSearch = varargin{1};    
            else
                arrayOfSetIndicesToSearch = 1:length(set);
            end

            % Place all validation parameters of all sets into a matrix
            vpMatrix = reshape([set(arrayOfSetIndicesToSearch).vp], length(set(1).vp),numel(arrayOfSetIndicesToSearch));
    
            % Find the set with highest average peak energy
            idxHighest = vpMatrix(VP.AVERAGE_RESONANCE_ENERGY,:) == ...
                max(vpMatrix(VP.AVERAGE_RESONANCE_ENERGY,:));
            
            setWithHighestPeakEnergy = arrayOfSetIndicesToSearch(idxHighest);            
        end 