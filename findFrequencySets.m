% ======================================================================
%> @brief findFrequencySets(obj, type, fLow, fHigh, noHarmonics)
%> Changed by CS, no obj
%> Function finds all frequencies that matches a harmonic set
%>
%> @param obj ThicknessAlgorithm class object
%> @param type Type of psd to search: RESONANCE or MAIN
%> @param fLow Lower Frequency
%> @param fLow Higher Frequency
%> @param fLow Required number of harmonics in each set
%>
%> @retval setsFound Reference to sets found
% ======================================================================
function [setsFound] = findFrequencySets(type, fLow, fHigh, noHarmonics)
    %% Function finds all frequencies that matches a harmonic set.
    %  Start searching for sets from fHigh and towards fLow
    % psd:      PSD 
    % locs:     Array containing index to peaks in PSD
    % fHigh:    Upper frequency in emitted pulse.
    % Deviation is calculated based on (Fs/N) * deviationFactor
    import ppPkg.HarmonicSet            

    if(obj.RESONANCE == type)
        psd = obj.psdResonance;
        locs = obj.peakLocationResonance;
        deviationInFrequency = (obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH) * obj.config.DEVIATION_FACTOR; 
        % @TODO: Consider changing how we calculate the deviation frquency.
        %       It should be based on the relevant frequency resolution
        %       Frequency resolution is given by 
        %       R = 1/T, 
        %       where T is the recording time of the signal. T = Fs/L, 
        %       where L is number of samples 
        %       
        %       FTT resolution is given by:
        %       Rf = Fs/Nfft. 
        %       So having a high Nfft does not improve the frequency
        %       resolution if T is short
        %       Ideal we should have:   Fs/L = Fs/Nfft  => L = Nfft, but this is not the
        %       case



    MIN_REQUIRED_HARMONICS = noHarmonics;

    numberOfSets = 0;

    % Calculate minimum fundemental frequency that can exists
    freqFundamentalMinimum = obj.config.V_PIPE/(2*obj.config.D_NOM);

    % Allowed percentage deviaion from target harmonic frequency
              

    % Iterate through array of maxima and find all frequencies that
    % matches a set.

    % Flip array so start searching from higher frequency
    locs = sort(locs);
    locs = flip(locs);

    for n = 1:length(locs)
        for m = (n+1):length(locs)
            for j =(m):length(locs)     
                %fprintf('index n: %d m: %d j: %d\n',n, m, j); 
                if( j == m )
                                        
                    fN.freq = (locs(n)-1)*obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH; 
                    fN.peakValue = (psd(locs(n)));                    
                    fN.index = locs(n);

                    fM.freq = (locs(m)-1)*obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH; 
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
                    fJ.freq = (locs(j)-1)*obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH; 
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

                    fK.freq = (K-1)*obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH; 
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
        if(obj.config.DEBUG_INFO)
            disp('No Sets found, try do adjust dB level')
        end
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

    % Store set to class            
    if(obj.RESONANCE == type)
        obj.setResonance = set;            
    elseif(obj.MAIN == type)            
        obj.setMain = set;
    end

    setsFound = numel(set);

end      