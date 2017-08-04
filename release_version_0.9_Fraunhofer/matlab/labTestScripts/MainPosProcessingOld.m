%% Import Post processing package files

clear all
%%

import ppPkg.*

%% Import data from Bluenose without headerfile. 
im = ImportHandler;

im.readFolder('/Volumes/Samsung_T3/data/fromBlueNoseFtp/Flowloop_Test/Nov16/Test1/splitRun2');

%% Hardcoded configuration since header file is missing
%im.header.sampleRate = 12.4e6;
im.header.sampleRate = 15.5e6;
im.header.pulseLength = (30e-6)*im.header.sampleRate;
im.header.fLow = 0.3e6;
im.header.fHigh = 3.8e6;  
im.header.pulsePattern = 'chirp'

%% Create object instances for controller and algorithms

transducerId = 1;
ctrl = Controller;

ctrl.config.SAMPLE_RATE = im.header.sampleRate;

callipAlg = CalliperAlgorithm(ctrl.config);
thicknessAlg = ThicknessAlgorithm(ctrl.config);

% Set configuration parameters
ctrl.config.FFT_LENGTH = 4096;%4096;
ctrl.config.D_MIN = 0.003;
ctrl.config.D_NOM = 0.010;

ctrl.config.NUMBER_OF_CHANNELS = 32;

noiseAlg = Noise(ctrl.config.NUMBER_OF_CHANNELS, ctrl.config.FFT_LENGTH, ctrl.config.SAMPLE_RATE, ctrl.config.TS_ARRAY);

%% Create transmitted pulse
%  Used by calliper algorithm to measure distance to pipewall
switch lower(im.header.pulsePattern)
    case 'chirp'
        [txPulse, tPulse] = generateChirp(im.header.sampleRate, im.header.pulseLength, im.header.fLow, im.header.fHigh);            
    case 'sinc'       
        [txPulse, tPulse] = generateSinc(im.header.sampleRate, im.header.pulseLength, im.header.fLow, im.header.fHigh);
    otherwise
        error('Signal pattern not supported')
end

%plot(tPulse, txPulse)
%grid on 

%% Read data file
% To specify a data file, set the following variable
im.dataFileIndex = 9;

tmArr = im.importDataFile();

%%
index = 16366;
close all
%%
%close all
tm = tmArr(index);

plot( tm.signal)
titleTxt = sprintf('Index %d, trId %d, grId %d',index,tm.transducerId, tm.groupId);
title(titleTxt)
ylim([-1 1])
grid on

% Increment to iterate through transducer recordings
index = index + ctrl.config.NUMBER_OF_CHANNELS;

% Increment with 1 to iterate through all transducers
index = index + 1;

%% Calculate Calliper
callipAlg.setTxPulse(txPulse);
delay = 0; % Start searching at index
%
% Calculate time in number of samples before recording is started
[distance, firstReflectionStartIndex, secondReflectionStartIndex, pitDept] = callipAlg.calculateDistance( delay, tm.signal, tm.startTimeRec);
callipAlg
%
% Second reflection is in this data
%callipAlg.secondReflectionIndex = 2000;
if(distance < 0)
    error('Outside pipe')
    return
end

    %% Noise calculation
% NOTE: Nor now: Need to verify that the start index for noise calculation is
% correct.


noiseSignal = tm.signal(1:firstReflectionStartIndex-20);
%noiseSignal = tm.signal(1000:firstReflectionStartIndex-20);

%
% Enable / Disable use of transducer sensitivity
enableTS = false;
enableTS_noise = false;

% Noise PSD calculation: Using pWelch or periodogram
[psdNoise, fNoise] = noiseAlg.calculatePsd(tm.transducerId, noiseSignal, enableTS_noise, 'periodogram', 'hanning', 400);

% Calculate mean and var for range [fLow, fHigh]
[meanValue, varValue] = noiseAlg.calculateMeanVarInRange(tm.transducerId, im.header.fLow , im.header.fHigh)

% Plot Noise PSD
fig = noiseAlg.plotPsd(tm.transducerId);
titleTxt = sprintf('Noise psd tr %d mean: %0.1f dB var: %0.1f dB ',tm.transducerId, round(meanValue,1), round(varValue,1));
title(titleTxt);
ylim([-160 -100]);
% filename = sprintf('tr %d noise psd',tm.transducerId);
% 
% filepath = 'C:\Users\Processing PC 01\Documents\MATLAB\matlab\figures\flowloop\TestWeek\Noise\25nov\group1\';
% filename = strcat(filepath, filename); 
% saveas(fig,filename)

%
%meanValueAll = -137
% 
% psdSubstract = 10*log10(psdNoise) - meanValue;
% 
% 
% psdSubstract(psdSubstract < 0) = 0;
%%
meanValue = -135.7


%% Calculate psdMain and psdResonance
pulseLength = length(txPulse);
ctrl.config.NOMINAL_DISTANCE_TO_WALL = 0.35;  % Can use result from calliper
ctrl.config.ADJUST_START_TIME_RESONANCE = 0;%100;
ctrl.config.ADJUST_STOP_TIME_RESONANCE =  0;
ctrl.config.WINDOW_RESONANCE = 'hanning';%'kaiser'; %'hanning';
ctrl.config.WINDOW_MAIN = 'rect'; 
ctrl.config.PERIODOGRAM_OVERLAP = 0.90;
ctrl.config.PERIODOGRAM_SEGMENT_LENGTH = 200;
ctrl.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;
ctrl.config.FFT_LENGTH = 4096;

thicknessAlg.fLow = tm.fLow;
thicknessAlg.fHigh = tm.fHigh;
% 
% if(false == thicknessAlg.calculateStartStopForAbsorptionAndResonance(tm.signal, callipAlg, 'plot'))
%     error('Error in calculating start and stop index for resonance')
% end

if(false == thicknessAlg.calculateStartStopForAbsorptionAndResonance(tm.signal, callipAlg))
    error('Error in calculating start and stop index for resonance')
end

%%
ctrl.config.TS_ADJUST_ENABLE = false;
ctrl.config.USE_PWELCH = true;
ctrl.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;
thicknessAlg.calculatePsd(tm.signal, 'plot');

%% Multi taper
% resSignal = tm.signal(thicknessAlg.beginResonance:thicknessAlg.endResonance);
% 
% pmtm(resSignal,2,length(resSignal),fs,'unity')
% %%
% nfft = 4096;
% fs = 15.5e6;
% x = tm.signal(thicknessAlg.beginResonance:thicknessAlg.endResonance);
% nwin = hanning(200);
% p = 2;
% noverlap = length(nwin) - 180;
% [S,f] = pmusic(x,p,nfft,fs,nwin,noverlap);
% figure
% plot(f,20*log10((S)))
% grid on
% thicknessAlg.psdResonance = (20*log10(abs(S))) -80;
%% Plot Periodogram segments
thicknessAlg.plotPeriodogramSegments(tm.signal);


%% Find peaks in the resonance spectrum
% Using mean level above noise floor in range [fLow, fHigh]. 
% Can consider using level above noisePsd(f).
thicknessAlg.meanNoiseFloor = meanValue;%noiseAlg.meanPsd(1);
% Override frequency range by setting fLow or fHigh.
fLow = 0.3e6;%tm.fLow;
fHigh = 4e6;%4.0e6%;tm.fHigh;
ctrl.config.Q_DB_ABOVE_NOISE = 15;
ctrl.config.Q_DB_MAX = 10;
ctrl.config.PROMINENCE = 7;

tic
% Find peaks
%
thicknessAlg.findPeaksInPsd(thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);
toc
%thicknessAlg.findPeaksInPsd(thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.MIN_PEAK_DISTANCE_AND_MIN_DB_ABOVE_NOISE);
%thicknessAlg.findPeaksInPsd(thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.TEST);
%thicknessAlg.findPeaksInPsd(thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.N_HIGEST_PROMINENCE, 3);

%thicknessAlg.findPeaksInPsd(thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.N_HIGEST_PROMINENCE, 8);

numHarmonics = thicknessAlg.findNumberOfHarmonics(fLow, fHigh);
if(numel(thicknessAlg.peakProminenceResonance) >= numHarmonics - 2)                                                                  
    disp('Peak reduce')  
    ctrl.thicknessAlg.peakReduction(ctrl.thicknessAlg.RESONANCE);        
end
 
%thicknessAlg.removeShearFrequency(2.483e6)


% Plot peaks
thicknessAlg.plotPsdPeaks(thicknessAlg.RESONANCE);
%ylim([-140 -80])

%% Resonance Part: Find all harmonic sets
%ctrl.config.DEVIATION_FACTOR = 9%;
%(obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH) * obj.config.DEVIATION_FACTOR; 
ctrl.config.DEVIATION_FACTOR = (ctrl.config.FFT_LENGTH/ctrl.config.SAMPLE_RATE) * (ctrl.config.SAMPLE_RATE/ctrl.config.PERIODOGRAM_SEGMENT_LENGTH) * 1;

requiredNumberOfHarmonicsInSet = 2;

% Find sets
thicknessAlg.findFrequencySets(thicknessAlg.RESONANCE, fLow, fHigh, requiredNumberOfHarmonicsInSet);
set = thicknessAlg.setResonance

%% set   
ctrl.config.D_MIN = 0.003;
ctrl.config.D_NOM = 0.01;

thicknessAlg.processSets(thicknessAlg.RESONANCE, fLow, fHigh, noiseAlg.psd(transducerId)) ;
set = thicknessAlg.setResonance

%[setC, setsWithMaxSize, setsWithEstimatedThickness] = thicknessAlg.findBestSetD(set, set);
%%
tic
[setC] = thicknessAlg.findBestSetE(set)
%[setC] = thicknessAlg.findBestSetD(set, set)
toc

%
%close all
thicknessAlg.plotAllSets('resonance', setC)


%%

close all
thicknessAlg.plotAllSets('resonance')


%% %%%%

fLow = 0.5e6;
fHigh = 3.8e6;
ctrl.config.PROMINENCE = 4;
thicknessAlg.config.WINDOW_MAIN = 'hamming';
%thicknessAlg.findPeaksInPsd(thicknessAlg.MAIN, fLow, fHigh, PeakMethod.N_HIGEST_PROMINENCE);
thicknessAlg.findPeaksInPsd(thicknessAlg.MAIN, fLow, fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);

% Plot peaks
thicknessAlg.plotPsdPeaks(thicknessAlg.MAIN);

% Find frequency sets
thicknessAlg.findFrequencySets(thicknessAlg.MAIN, fLow, fHigh, 2);


%% Process set data
thicknessAlg.processSets(thicknessAlg.MAIN, fLow, fHigh, meanValue); 

%%
% Find best set candidate
[setC] = thicknessAlg.findBestSetE(thicknessAlg.setMain);

% Get thickness
thickness = thicknessAlg.setMain(setC).thickness;

thicknessAlg.plotAllSets('absorption', setC)

%%

close all
thicknessAlg.plotAllSets('absorption')
