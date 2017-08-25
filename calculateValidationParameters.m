       %======================================================================
        %> @brief Function calculates validation parameters        
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param psdNoise Psd of the noise
        %> @param meanNoise Mean value of the psd noise spectrum
        %> @param qSet Number of dB above noise set
        %> @param qMax Maximum dB above noise as set in the configuration
        % ======================================================================        
        function vp = calculateValidationParameters(psdNoise, meanNoise, qSet, qMax)          

            import ppPkg.VP;                                
                        
            % Absolute Number of harmonics
            vp(VP.ABSOLUTE_NUM_HARMONICS) = ...
                obj.numFrequencies;
            
            % Relative Number of harmonics            
            % Calculates the number of harmonics that can exist in the 
            % bandwidth of the transmitted pulse.                      
            
            vp(VP.RELATIVE_NUM_HARMONICS) = ...
                (obj.numFrequencies/obj.calculateMaxHarmonics());
            
            % Average deviation from theoretical frequency             
            % Calculate mean of abs of the deviation frequencies. 
            vp(VP.AVERAGE_DEVIATION) = ...
                mean(abs(obj.calculateDeviationFromAverageF0()));             
            
            % Relative Q applied 
            % These numbers are taken from configuration used.
            vp(VP.RELATIVE_Q_ABOVE_NOISE) = qSet/qMax;
                        
            % Total resonance energy
            resonanceEnergy = obj.calculateResonanceEnergy(psdNoise, meanNoise);
            
            vp(VP.TOTAL_RESONANCE_ENERGY) = ...
                sum(resonanceEnergy);
            
            % Average resonance energy
            vp(VP.AVERAGE_RESONANCE_ENERGY) = ...
                mean(resonanceEnergy);
            
        end