function [meanArray ] = hydrophoneDataProcessSineSweep(  fileName, startFrequency, stepFrequency )

    import ppPkg.*
    im = ImportHandler;

    % Import data file
    header = im.readHeader(fileName);    
    tmArr = im.importDataFile();

    fileName
    %% Use moving average filter to smooth the data points
    N = 4;
    b = (1/N)*ones(1, N);
    a = 1;
    
    
    
    % Frequency increases with 100kHz for each step
    for index = 1:1:length(tmArr)   
        tm = tmArr(index);
%         
%         if(index < 170 ) 
%             recordedSignal = filtfilt(b, a, tm.signal);  
%         else
%             recordedSignal = tm.signal;  
%         end
        
        recordedSignal = tm.signal;  
    

        %plot(recordedSignal)
        
        
        sinusFrequency = startFrequency + stepFrequency*(index-1);
        pulseLength = 20 * header.sampleRate / sinusFrequency;
        
        % Create tx pulse
        txPulse = generatePulse(header.pulsePattern, header.sampleRate, pulseLength, sinusFrequency, sinusFrequency );    
                
        [startIndexPulse] = findStartIndexPulse(txPulse, recordedSignal, 1000);         

        if(round(startIndexPulse) < 7500 && round(startIndexPulse) > 6500 )

            % Extract signal segment to investigate
            signalSegment = recordedSignal(round(startIndexPulse):round(startIndexPulse+pulseLength));

            % Calculate minimum peak distance
            peakDistance = round(2/3 *  header.sampleRate / sinusFrequency);

            [maxPeaks, locsMax, minPeaks, locsMin] = findMaxAndMinPeaks(signalSegment, peakDistance);

            % Sum max and min to calculate "peak2peak" value
            peak2peakArray = maxPeaks - minPeaks;

            % Calculate mean
            meanArray(index) = mean(peak2peakArray);   
        else
            meanArray(index) = 0;   
        end
        %plot(tm.signal, )                
        %grid on
        
    end
end

function [maxPeaks, locsMax, minPeaks, locsMin] = findMaxAndMinPeaks(signalSegment, peakDistance)

    interpFactor = 10;
    peakDistanceModified = peakDistance * interpFactor;
    signalSegment_interp = interp(signalSegment,interpFactor);
    %findpeaks(signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    %findpeaks(-signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    [pksMax, locsMax] = findpeaks(signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    [pksMin, locsMin] = findpeaks(-signalSegment_interp,'MinPeakDistance',  peakDistanceModified);

%     sigZeropad(1:10:10 * length(signalSegment) - 1) = signalSegment;
%         stem(sigZeropad)
%         hold on
%         plot(signalSegment_interp)
%         hold off
    
    % Only keep peaks 3 to 8
    if((numel(pksMax) >= 12) && (numel(pksMin) >= 12))
        maxPeaks = pksMax(5:12);
        minPeaks = -pksMin(5:12);      
        locsMax  = locsMax(5:12);
        locsMin  = locsMin(5:12);
    elseif(length(pksMax) > 2)
        disp('Error Should find more than 12 peaks')
        lengthMax = length(pksMax);
        lengthMin = length(pksMin);
        if(lengthMax > lengthMin)
            maxLength = lengthMin;
        else
            maxLength = lengthMax;
        end
        
        maxPeaks = pksMax(1:maxLength);
        minPeaks = -pksMin(1:maxLength);      
        locsMax  = locsMax(1:maxLength);
        locsMin  = locsMin(1:maxLength);

    else
        error('Error in finding peaks')
    end            
    
end

function [txPulse, tPulse] = generatePulse(pattern, sampleRate, pulseLength, fLow, fHigh)
    import ppPkg.*
    switch lower(pattern)
        case 'simple'
            [txPulse, tPulse] = generateSin(sampleRate, pulseLength, fLow);
        case 'chirp'
            [txPulse, tPulse] = generateChirp(sampleRate, pulseLength, fLow, fHigh);            
        case 'rectchirp'
            [txPulse, tPulse] = generateChirp(sampleRate, pulseLength, fLow, fHigh);            
            txPulse = sign(txPulse);        
        case 'sinc'       
            [txPulse, tPulse] = generateSinc(sampleRate, pulseLength, fLow, fHigh);
        case 'rectpulse'       
            [txPulse, tPulse] = generateRectPulseTrain(sampleRate, pulseLength, fLow, fHigh);        
            txPulse = flip(txPulse)        
        otherwise
            error('Signal pattern not supported')
    end    
end

function startIndexPulse = findStartIndexPulse(txPulse, signal, delay)
% Function use correlation between emitted pulse and recorded signal to find
% startIndex for pulse in recorded signal

    startIndex = 1 + delay;

    [r, lags] = xcorr(signal(startIndex:end), txPulse);

    % Find the index where the absolute value of the cross correlation is at its
    % maximum
    r_abs = abs(r); 
    [maxValue, maxIndex] = max(r);
    
    lagInterp = findLagUsingInterpolation(r_abs, lags, maxIndex);
    
    startIndexPulse = delay + round(lagInterp);
    
end

function lag = findLagUsingInterpolation(r, x, maxIndex)
%%
%   This function uses interpolation to find a better estimate for the
%   location of the maximum value of r. 
%   r: sample values (cross correlation)
%   x: sample points (lags)
%   max_index: index where r has its maximum value.

    % Number of point before and after max peak
    deltaPoint = 3;
    
    % Number of quary points for each sample
    interpolation_factor = 8;

    startIndex = maxIndex-deltaPoint;
    stopIndex = maxIndex+deltaPoint;
    x_startIndex = x(startIndex);
    x_stopIndex = x(stopIndex);    

    %% Retrieve small segment including max peak
    % Segment sample points
    segmentRange = startIndex:1:stopIndex;
    % Segment sample values
    r_segment = r(segmentRange);
        
    %% Create quary vector
    % Quary segment sample points
    interpolationRange = x_startIndex:1/interpolation_factor:x_stopIndex;     
    x_segmentRange = x_startIndex:1:x_stopIndex;

    r_interp = interp1(x_segmentRange, r_segment,interpolationRange,'spline');
    

    % Find index for max peak for the interpolated curve
    [~,I_intep] = max(r_interp);
    
    % Find lag at this index
    lag = interpolationRange(I_intep);
    
    
end