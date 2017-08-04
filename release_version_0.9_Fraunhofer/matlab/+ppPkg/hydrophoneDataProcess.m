function [ meanArray, startIndexArray ] = hydrophoneDataProcess( fileName, varargin)
% Function calculates the mean peak2peak value of the sinus recorded 
% by the hydrophone, for each shot the transducer is moved in an angle. 
% Function now assumes that transducer is moved with 1 degree for each shot

% 

    import ppPkg.*
    im = ImportHandler
    
    % Create function input parser object
    p = inputParser;
    
    nVarargs = length(varargin);
    
    defaultStep = 0;
    defaultStartIndex = 0;
    
      
    
    addRequired(p, 'fileName', @ischar);
    addRequired(p,'angleResolution', @isnumeric);
    addRequired(p,'startAngle', @isnumeric);
    addRequired(p,'stopAngle', @isnumeric); 
    addParameter(p,'stepProcessing', defaultStep, @isnumeric);
    addParameter(p,'startIndex', defaultStartIndex, @isnumeric);
    
    % Parse function input
    parse(p, fileName, varargin{:})
    
    if(p.Results.stepProcessing)
        f = figure;  
    end
    
    header = im.readHeader(fileName);
    tmArr = im.importDataFile();
    
    % Create tx pulse
    txPulse = generatePulse(header.pulsePattern, header.sampleRate, header.pulseLength, header.fLow, header.fHigh );
    
    % Init array 
    meanArray = zeros(1, length(tmArr));
    startIndexArray = zeros(1, length(tmArr) );
    
    
    
    if(p.Results.angleResolution == 0)
        startIndex = 1;
        stopIndex = length(tmArr)
        
    elseif(p.Results.startIndex ~= 0)
        
        if(p.Results.startIndex>1)
            startIndex = p.Results.startIndex-1;
            
        else
            startIndex = p.Results.startIndex;
        end
        
        stopIndex = length(tmArr);
        
    else
    
        startIndex = p.Results.startAngle/p.Results.angleResolution;
        stopIndex = p.Results.stopAngle/p.Results.angleResolution;
        
        
        if(startIndex > length(tmArr) || stopIndex > length(tmArr))
            error('Error in calculating start and stop index')
            return
        end
    end
    
    
%     if(p.Results.startIndex ~= 0)
%         if(p.Results.startIndex>1)
%             startIndex = p.Results.startIndex-1;
%         else
%             startIndex = p.Results.startIndex;
%         end
%     end
    
    for index = (startIndex+1):stopIndex
    %for index = 1:length(tmArr)
        
        tm = tmArr(index);
        recordedSignal = tm.signal;    
        
        % Find start index pulse       
        startIndexPulse = findStartIndexPulse(txPulse, recordedSignal);
        startIndexArray(index) = startIndexPulse;
        
        %plot(recordedSignal)
        
        if(startIndexPulse <= 450 || startIndexPulse > 6000  )
            disp('StartIndexPulse outside valid range');
            continue;
        end                

        % Extract signal segment with pulse
        signalSegment = recordedSignal(startIndexPulse:(startIndexPulse + header.pulseLength));

        % Calculate minimum peak distance
        peakDistance = round(2/3 *  header.sampleRate / header.fLow);
        
        % Calculate 6 max and min peaks for signal
        [maxPeaks, locsMax, minPeaks, locsMin, segmentWithPeaks] = findMaxAndMinPeaks((signalSegment), peakDistance);

        % Sum max and min to calculate "peak2peak" value
        peak2peakArray = maxPeaks - minPeaks;

        % Calculate mean
        meanArray(index) = mean(peak2peakArray);

        
        if(p.Results.stepProcessing)
            subplot(2,1,1)
            plot(recordedSignal)
            hold on 
            plot(startIndexPulse,recordedSignal(startIndexPulse), '*')
            title('Red start: start of signal segment')
            grid on
            hold off
                       
            x = 1:length(segmentWithPeaks);
            padding = 10;
            % Create x array for signal segment
            x_ = ((1:length(signalSegment))*padding)-padding;

            
            subplot(2,1,2)
            plot(x, segmentWithPeaks, ...
                        locsMax, maxPeaks, 'o', ...
                        locsMin, minPeaks,'*',...
                        x_, signalSegment);
        
            grid on
            titleTxt = sprintf('Index %d, press button to continue', index);
            title(titleTxt);
            
            
            w = 0;
            while(w == 0)
                w = waitforbuttonpress;
%                 if w == 0
%                     disp('Button click')
%                 else
%                     disp('Key press')
%                 end
            end
        end
       
        
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

function startIndexPulse = findStartIndexPulse(txPulse, signal)
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
end

function [maxPeaks, locsMax, minPeaks, locsMin, segment] = findMaxAndMinPeaks(signalSegment, peakDistance)

    if(1)
        interpFactor = 10;
        peakDistanceModified = peakDistance * interpFactor;
        signalSegment_interp = interp(signalSegment,interpFactor);
        [pksMax, locsMax] = findpeaks(signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
        [pksMin, locsMin] = findpeaks(-signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    else
        [pksMax, locsMax] = findpeaks(signalSegment,'MinPeakDistance',  peakDistance);
        [pksMin, locsMin] = findpeaks(-signalSegment,'MinPeakDistance',  peakDistance);
    end
    
    segment = signalSegment_interp;
    
    
    % Only keep peaks 3 to 8
    if((length(pksMax) > 12) && (length(pksMin) > 12))
        maxPeaks = pksMax(6:13);
        minPeaks = -pksMin(6:13);      
        locsMax  = locsMax(6:13);
        locsMin  = locsMin(6:13);
%     elseif(length(pksMax) > 2)
%         lengthMax = length(pksMax);
%         lengthMin = length(pksMin);
%         if(lengthMax > lengthMin)
%             maxLength = lengthMin;
%         else
%             maxLength = lengthMax;
%         end
%         
%         maxPeaks = pksMax(1:maxLength);
%         minPeaks = -pksMin(1:maxLength);      
%         locsMax  = locsMax(1:maxLength);
%         locsMin  = locsMin(1:maxLength);

    else
        disp('Error in finding peaks')
        maxPeaks = 0;
        minPeaks = 0;
    end            
    
end
