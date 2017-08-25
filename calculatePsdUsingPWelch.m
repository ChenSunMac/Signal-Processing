        function [pxx, f] = calculatePsdUsingPWelch(x, windowType, segmentLength, nfft, fs, PERIODOGRAM_OVERLAP)
            %% Calculate Power Spectral density using pwelch            
            window = getWindow(windowType, segmentLength);

            % Calculate number of samples to be used as overlap
            overlap = floor(PERIODOGRAM_OVERLAP * segmentLength);
            
            % Calculate psd using welch method
            [pxx, f] = pwelch(x, window, overlap, nfft, fs, 'mean');

        end   