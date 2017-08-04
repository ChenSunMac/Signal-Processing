function res = pulseTest(ctrl, folder, folderToSaveFig)

    % Read folder 
    % Get all subfolder names
    % Do a regex
    % Keep the ones that matches the regex
    listing = dir(folder);
    
    %folderNames;
    [pathstr,name,ext] = fileparts(folder); 
    
    folderIndex = 1;
    for index = 1:size(listing,1)        
        temp = regexp(listing(index).name,'CIP_.*','match');
        if(~isempty(temp))
            dataFolders(folderIndex) = cellstr(listing(index).name);
            folderIndex = folderIndex + 1;
        end
    end
    
    folderFirstPart = strcat(listing(1).folder,'\');

    % Initialize struct
    res(numel(dataFolders)) = struct('medianNoise',0,...
           'meanNoise',0,...
           'medianDbAboveNoise',0,...
           'meanDbAboveNoise',0,...
           'thickness',0,...
           'averageF0',0,...
           'snr',0,...
           'psdF',0,...
           'psdMain', 0,...
           'psdResonance', 0,...
           'dataHeader','',...           
           'title','');    
                    
    
    % Get path to all header files in dataFolders    
    for indexN = 1:numel(dataFolders)
        folderPath = char(dataFolders(indexN));        
        folderPath = strcat(folderFirstPart, folderPath);
        folderPath = strcat(folderPath,'\');
        
        % Get content of folderPath
        listingFolder = dir(char(folderPath));
        
        % Iterate through the files in the folder
        for indexM = 1:size(listingFolder,1)     
            
            % Get the file that contains 'header' and extract information
            % from the file name
            temp = regexp(listingFolder(indexM).name,'.*header','match');
            if(~isempty(temp))
                
                % Get Transducer info
              %  token1 = regexp(listingFolder(indexM).name,'.*(CHIRP_\d\d_\d\d\d).*','tokens');
              %  res(indexN).transducer = char(token1{1});
                
                % Get Title txt
                token2 = regexp(listingFolder(indexM).name,'(.*)_[0-9]+_[0-9]+_header','tokens');
                %strrep(res.transducer, '_', ' ');
                %res(indexN).title = char(token2{1});
                res(indexN).title = strrep(char(token2{1}), '_', ' ');
                %strrep(char(token2{1}), '_', ' ')
                
                % Get path to data file header               
                fileName = listingFolder(indexM).name;    
                res(indexN).dataHeader = strcat(folderPath, fileName);                                
            end
        end                
    end
    
    % Iterate through struct array to process data from each transducer
    for index = 1:numel(res)

        % Process data
        index
        res(index) = processData(ctrl, res(index), folderToSaveFig);
        
        % Plot PSD main with psd compare        
        %plotPsdMain(ctrl, res(index), psdCompare, folderToSaveFig);
        %plotPsdResonance(ctrl, res(index), folderToSaveFig);
               
        %res(index);
        %pause()
        
        close all
        
    end              
end

function res = processData(ctrl, res, folderToSaveFig)
    import ppPkg.*
    
    im = ImportHandler;
    im.readHeader(res.dataHeader);
    
    s = SignalGenerator(lower(im.header.pulsePattern), ...
                        im.header.sampleRate, ...
                        im.header.pulseLength/im.header.sampleRate, ...
                        im.header.fLow, ...
                        im.header.fHigh);
    txPulse = s.signal;
    %plot(s.time, s.signal)
    %grid on
    
    ctrl.config.SAMPLE_RATE = im.header.sampleRate;
    
    im.dataFileIndex = 1;

    tmArr = im.importDataFile();

    index = 1;
    
    tm = tmArr(index);
    
    ctrl.callipAlg.setTxPulse(txPulse);
    delay = 1000; % Start searching at index
    %
    % Calculate time in number of samples before recording is started
    [distance, firstReflectionStartIndex, secondReflectionStartIndex, pitDept] = ctrl.callipAlg.calculateDistance( delay, tm.signal, tm.startTimeRec);
    %ctrl.callipAlg
    %
    % Second reflection is in this data
    %callipAlg.secondReflectionIndex = 2000;
    if(distance < 0)
        error('Outside pipe')
        return
    end 
    
    %% Noise signal
    noiseSignal = tm.signal(1000:firstReflectionStartIndex-20);

    %
    % Enable / Disable use of transducer sensitivity
    enableTS = false;
    enableTS_noise = false;
    
    transducerId = 1;

    % Noise PSD calculation: Using pWelch or periodogram
    [psdNoise, fNoise] = ctrl.noiseAlg.calculatePsd(tm.transducerId, noiseSignal, enableTS_noise, 'periodogram', 'hanning', 400);

    % Calculate mean and var for range [fLow, fHigh]
    [meanValue, varValue] = ctrl.noiseAlg.calculateMeanVarInRange(tm.transducerId, im.header.fLow , im.header.fHigh);

    % Plot Noise PSD
%     fig = ctrl.noiseAlg.plotPsd(tm.transducerId);
%     titleTxt = sprintf('Noise psd tr %d mean: %0.1f dB var: %0.1f dB ',tm.transducerId, round(meanValue,1), round(varValue,1));
%     title(titleTxt);
%     ylim([-160 -100]);  
    %% Calculate psdMain and psdResonance    
    ctrl.thicknessAlg.fLow = tm.fLow;
    ctrl.thicknessAlg.fHigh = tm.fHigh;

    if(false == ctrl.thicknessAlg.calculateStartStopForAbsorptionAndResonance(tm.signal, ctrl.callipAlg))
        error('Error in calculating start and stop index for resonance')
    end

    % Calculate PSD for resonance and absoption part of the signal
    ctrl.thicknessAlg.calculatePsd(tm.signal);

    % Plot PSD for resonance and absoption part of the signal
    %ctrl.thicknessAlg.plotPsd(tm.signal);
    
    res.psdResonance = ctrl.thicknessAlg.psdResonance;
    res.psdMain = ctrl.thicknessAlg.psdMain;
    res.psdF = ctrl.thicknessAlg.fVector;
    
    res.snr = ctrl.thicknessAlg.calculateSNR(tm.signal, noiseSignal); 
    
   
    
    
    ctrl.thicknessAlg.meanNoiseFloor = meanValue;%noiseAlg.meanPsd(1);
    % Override frequency range by setting fLow or fHigh.
    fLow = tm.fLow; %tm.fLow;
    fHigh = tm.fHigh + ctrl.config.DELTA_FREQUENCY_RANGE; %tm.fHigh;
    %ctrl.config.Q_DB_ABOVE_NOISE = 10;
    %ctrl.config.Q_DB_MAX = 10;
    %ctrl.config.PROMINENCE = 8;

    %tic
    % Find peaks
    ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);
    %toc

    %
    % Plot peaks
    %ctrl.thicknessAlg.plotPsdPeaks(ctrl.thicknessAlg.RESONANCE); 
    ctrl.config.DEVIATION_FACTOR = (ctrl.config.FFT_LENGTH/ctrl.config.SAMPLE_RATE) * (ctrl.config.SAMPLE_RATE/ctrl.config.PERIODOGRAM_SEGMENT_LENGTH) * 1.5;

    requiredNumberOfHarmonicsInSet = 2;

    % Find sets
    ctrl.thicknessAlg.findFrequencySets(ctrl.thicknessAlg.RESONANCE, fLow, fHigh, requiredNumberOfHarmonicsInSet);
    %set = ctrl.thicknessAlg.setResonance

    %% Find resonance sets        
    ctrl.thicknessAlg.processSets(ctrl.thicknessAlg.RESONANCE, ctrl.noiseAlg.psd(transducerId)) ;
    %set = ctrl.thicknessAlg.setResonance  
    
    [setC] = ctrl.thicknessAlg.findBestSetE(ctrl.thicknessAlg.setResonance);
    
    res.averageF0 = ctrl.thicknessAlg.setResonance(setC).averageFreqDiff;  
    res.thickness =  ctrl.thicknessAlg.setResonance(setC).thickness;  
    

    % Plot the set candidate
    close all
    ctrl.thicknessAlg.plotAllSets('resonance', setC)
    titleTxtPart = strrep(im.header.projectId, '_', ' '); 
    %filenameFig = strcat('Psd_Resonance_', res.title); 

    titleTxt = sprintf('Resonance PSD, \"%s\" segL %d', titleTxtPart, ctrl.config.PERIODOGRAM_SEGMENT_LENGTH);
    %titleTxt = sprintf('Resonance PSD, %s F %2.2d %2.2e Hz, t: %1.2e s', im.header.pulsePattern, im.header.fLow, im.header.fHigh, im.header.pulseLength/im.header.sampleRate);
    title(titleTxt)
    
    filenameFig = strcat(im.header.projectId,'_psd_resonance'); 
    
    saveFigPath = strcat(folderToSaveFig,filenameFig);
    fig = gcf;
    savefig(fig, saveFigPath)
    
    
    

end


