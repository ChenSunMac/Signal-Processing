function [ psdArray, fVector, distanceArray, meanArray ] = processHydrophoneDataLinear( FFT_LENGTH, fileName )

    import ppPkg.*
    im = ImportHandler;

    % Import data file
    header = im.readHeader(fileName);    
    tmArr = im.importDataFile();
    
    % Init variables
    psdArray = zeros(length(tmArr), FFT_LENGTH/2 + 1); 
    distanceArrayTemp = zeros(1, length(tmArr)); 
    
    % Create tx pulse
    txPulse = generatePulse(header.pulsePattern, header.sampleRate, header.pulseLength, header.fLow, header.fHigh );    
    
    enablePeak2PeakCalc = 1;
    for index = 1:length(tmArr)        
        tm = tmArr(index);
        recordedSignal = tm.signal;
        
        %plot(recordedSignal)
        %y = smooth(recordedSignal, 4);
        %hold on
        %plot(y)
        %grid on
        
        if(enablePeak2PeakCalc )
            % Find start of emitted pulse in recording
            [distance, startIndexPulse] = findStartIndexPulse(txPulse, recordedSignal);

            % Extract signal segment to do FFT etc
            signalSegment = recordedSignal(startIndexPulse:startIndexPulse+header.pulseLength);

            % Calculate periodogram
            [psdPulse, fVector] = periodogram(signalSegment, rectwin(length(signalSegment)), FFT_LENGTH, header.sampleRate,'psd');
            psdArray(index, : ) = psdPulse; 
            distanceArrayTemp(index) = distance; 

            % Calculate minimum peak distance
            peakDistance = round(2/3 *  header.sampleRate / header.fLow);

            % Calculate 6 max and min peaks for signal
            [maxPeaks, locsMax, minPeaks, locsMin] = findMaxAndMinPeaks(signalSegment, peakDistance);

            % Sum max and min to calculate "peak2peak" value
            peak2peakArray = maxPeaks - minPeaks;

            % Calculate mean
            meanArray(index) = mean(peak2peakArray);        
        end
    end
    
    
    
    distanceArray = distanceArrayTemp;        

end

function y = smooth(x, N)
    b = (1/N)*ones(1, N);
    a = 1;    
    y = filtfilt(b, a, x);      
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

function [distance, startIndexPulse] = findStartIndexPulse(txPulse, signal)
% Function use correlation between emitted pulse and recorded signal to find
% startIndex for pulse in recorded signal
    import ppPkg.*
    ctrl = Controller;
    callipAlg = CalliperAlgorithm(ctrl.config);
    
    % Calculate Calliper
    % Set transmitted pulse
    callipAlg.setTxPulse(txPulse);

    % Start searching at index 0 
    delay = 0;

    %% Calculate startIndex for pulse in recording    
    [distance, startIndexPulse] = callipAlg.calculateDistance( delay, signal, 0);    
    
    % Need to double distance since this is calculated as it should have
    % been reflected
    distance = distance * 2;
    
end

function plotFrequency(step, psdArray, distanceArray, FFT_LENGTH)
    f = 0:0.5e6:4e6;
    N = round( f*FFT_LENGTH/15e6);
    N(1) = 1;
    for index = 1:length(N)
        figure       
        plot(distanceArray, psdArray(:,N(index)))        
        grid on        
        msg = sprintf('Frequency vs distance plot, for f=%d', f(index));
        title(msg);
        xlabel('distance')
        ylabel('Frequency gain')        
    end
end

function [maxPeaks, locsMax, minPeaks, locsMin] = findMaxAndMinPeaks(signalSegment, peakDistance)

    interpFactor = 10;
    peakDistanceModified = peakDistance * interpFactor;
    signalSegment_interp = interp(signalSegment,interpFactor);
    [pksMax, locsMax] = findpeaks(signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    [pksMin, locsMin] = findpeaks(-signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    
    % Only keep peaks 3 to 8
    if((length(pksMax) >= 15) && (length(pksMin) >= 15))
        maxPeaks = pksMax(10:15);
        minPeaks = -pksMin(10:15);      
        locsMax  = locsMax(10:15);
        locsMin  = locsMin(10:15);
    elseif(length(pksMax) > 2)
        error('Error Should find more than 17 peaks')
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