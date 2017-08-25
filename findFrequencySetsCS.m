function [setsFound, set] = findFrequencySetsCS(locs,psd, SAMPLE_RATE, FFT_LENGTH, freqFundamentalMinimum, deviationInFrequency, fLow, fHigh, MIN_REQUIRED_HARMONICS)
        import ppPkg.HarmonicSet  
            numberOfSets = 0;
   for n = 1:length(locs)
        for m = (n+1):length(locs)
            for j =(m):length(locs)     
                %fprintf('index n: %d m: %d j: %d\n',n, m, j); 
                if( j == m )
                                        
                    fN.freq = (locs(n)-1)*SAMPLE_RATE/FFT_LENGTH; 
                    fN.peakValue = (psd(locs(n)));                    
                    fN.index = locs(n);

                    fM.freq = (locs(m)-1)*SAMPLE_RATE/FFT_LENGTH; 
                    fM.peakValue = (psd(locs(m)));    
                    fM.index = locs(m);

                    %tempSet = HarmonicSet(freqN, peakN, locs(n), freqM, peakM, locs(m), deviationInFrequency);
                    %fprintf('create set index n: %d m: %d j: %d\n',n, m, j);
                    % Only create a new set if the difference
                    % between freqN and freqM is larger than
                    % freqFundamentalMinimum                            
                    if(abs(fM.freq - fN.freq) > freqFundamentalMinimum)
                    % Create harmonicSet object
                       %fprintf('index n: %d m: %d j: %d\n',n, m, j); 
                        %tempSet = HarmonicSet(freqN, peakN, locs(n), freqM, peakM, locs(m), deviationInFrequency);                             
                        tempSet = HarmonicSet(fN, fM, deviationInFrequency, fLow, fHigh);                             
                    else
                        tempSet = [];
                        break;
                    end
                else                           
                    fJ.freq = (locs(j)-1)*SAMPLE_RATE/FFT_LENGTH; 
                    fJ.peakValue = (psd(locs(j)));     
                    fJ.index = locs(j);

                    % Try to add next frequency to set
                    if(tempSet.tryAddFreqFromHigh(fJ))
                    end

                end                                                
            end

            % Search the other direction 
            % Try to add frequencies
            if(n > 1 && ( numel(tempSet) > 0 ))
                %fprintf('index n: %d m: %d j: %d\n',n, m, j); 

                for K = flip(locs(1:n-1))'

                    fK.freq = (K-1)*SAMPLE_RATE/FFT_LENGTH; 
                    fK.peakValue = (psd(K));  
                    fK.index = K;

                    tempSet.tryAddFreqFromLow(fK);

                end
            end

            if( j == length(locs))
                 %fprintf('try save sets %d countf %d\n',numberOfSets, tempSet.frequencyCount);
                if(isempty(tempSet))

                elseif(numberOfSets == 0 && (tempSet.numFrequencies >= MIN_REQUIRED_HARMONICS))
                    numberOfSets = 1;
                    set = tempSet;

                % Only keep sets that have more than MIN_REQUIRED_HARMONICS
                % harmonic frequencies
                elseif(tempSet.numFrequencies >= MIN_REQUIRED_HARMONICS)
                    numberOfSets = numberOfSets + 1;


                    set(numberOfSets) = tempSet;
                    tempSet = [];
                end                         
            end                                        
        end                                                
    end                                      

    if(numberOfSets == 0)
            disp('No Sets found, try do adjust dB level')
        set = [];
    else
        % Remove all subsets                
        %set = obj.removeAllSubsets2(set);

        % Flip frequency array in Harmonic set so that set always
        % start with the lower frequency
        for index = 1:length(set)
            set(index).flip();
        end                
    end      

    setsFound = numel(set);
end
