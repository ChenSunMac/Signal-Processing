function [psdArray, fArray, numberOfPsd, lineIndex] = calculatePsdUsingPeriodogram(x, windowType, segmentLength, overlap, maxNumberPsd, SAMPLE_RATE, FFT_LENGTH )
 
            startIndex = 1;
            stopIndex = startIndex + segmentLength;
            if(stopIndex > length(x))
                stopIndex = length(x);
            end
            
            % Get window for length equal to segmentLength or remaining
            % signal
            window_ = getWindow(windowType, stopIndex - startIndex);
            
            % Init arrays
            psdArray = zeros(maxNumberPsd,1+FFT_LENGTH/2);
            lineIndex = zeros(maxNumberPsd, 2);
            
            i = 1;
            while(startIndex < length(x) && i < maxNumberPsd+1)
                
                % If lenght of remaining signal is less than segmentLength
                % calculate a new window. 
                if(length( x(startIndex:stopIndex-1) ) < length(window_))
                    
                    window_ = getWindow(windowType, length( x(startIndex:stopIndex-1)));            
                end
                
                % Calculated psd using periodogram
                [psdArrayTemp, fArray] = periodogram(x(startIndex:stopIndex-1), window_, FFT_LENGTH, SAMPLE_RATE, 'psd');
                
                % Convert to dB
                psdArray(i,:) = 10*log10(psdArrayTemp);
                
                % Save start and stop index for the segment
                lineIndex(i,:) = [startIndex, stopIndex];
               
                % Calculate next startIndex and stopIndex
                startIndex = startIndex + round(segmentLength*(1-overlap));
                stopIndex = startIndex + segmentLength;
                if(stopIndex > length(x))
                    stopIndex = length(x);
                end
                
                % Increment i
                i = i + 1;                    
            end
                        
            numberOfPsd = i-1;
        end