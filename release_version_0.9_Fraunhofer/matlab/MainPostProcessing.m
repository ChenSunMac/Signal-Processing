%% Import Post processing package files

clear all
%%

import ppPkg.*

%% Import data from Bluenose without headerfile. 
im = ImportHandler;
%im.readHeader('E:\16DI\DI16_machined_in_bn218_03_001_100mm_u359_du028_z100_dz1_chirp_500_4500_3us\DI18_header1')
im.readFolder('C:\Chen\Fraunhofer_3us_Run5')

%% Hardcoded configuration for blunenose data only, since header file is missing
% ONLY USE THIS FOR BLUENOSE DATA
im.header.sampleRate = 15.0e6;
im.header.pulseLength = (3e-6)*im.header.sampleRate;
im.header.fLow = 0.3e6;
im.header.fHigh = 3.8e6;  
im.header.pulsePattern = 'chirp'

%% Create object instances for controller and algorithms

transducerId = 1;
ctrl = Controller;

ctrl.config.SAMPLE_RATE = im.header.sampleRate;

% Set configuration parameters
ctrl.config.FFT_LENGTH = 4096;%4096;
ctrl.config.D_MIN = 0.009;
ctrl.config.D_NOM = 0.0123;
ctrl.config.NOMINAL_DISTANCE_TO_WALL = 0.100;
ctrl.config.NUMBER_OF_CHANNELS = 32;
ctrl.config.V_PIPE = 4980;


%% Create transmitted pulse
%  Used by calliper algorithm to measure distance to pipewall

s = SignalGenerator(lower(im.header.pulsePattern), ...
                    im.header.sampleRate, ...
                    im.header.pulseLength/im.header.sampleRate, ...
                    im.header.fLow, ...
                    im.header.fHigh)
txPulse = s.signal;
plot(s.time, s.signal)
grid on


%% Read data file
% To specify a data file, set the following variable
im.dataFileIndex = 1;

tmArr = im.importDataFile();
%%
index = 1;%40009; 10020
%close all
%%
%close all
tm = tmArr(index);
tm.transducerId = 1;

figure
plot( tm.signal)
titleTxt = sprintf('Index %d, trId %d, grId %d',index,tm.transducerId, tm.groupId);
title(titleTxt)
%ylim([-1 1])
grid on;grid minor

% Increment to iterate through transducer recordings
%index = index + ctrl.config.NUMBER_OF_CHANNELS;

% Increment with 1 to iterate through all transducers
index = index + 1;

%% Calculate Calliper
ctrl.callipAlg.setTxPulse(txPulse);
delay = 0; % Start searching at index
%
% Calculate time in number of samples before recording is started
[distance, firstReflectionStartIndex, secondReflectionStartIndex, pitDept] = ctrl.callipAlg.calculateDistance( delay, tm.signal, tm.startTimeRec);
ctrl.callipAlg
%
% Second reflection is in this data
%callipAlg.secondReflectionIndex = 2000;
if(distance < 0)
    error('Outside pipe')
    return
end

%% Noise calculation, calculate noise floor

% Extract noise signal from lab
noiseSignal = tm.signal(1000:firstReflectionStartIndex-20);

% Extract noise signal from bluenose 
%noiseSignal = tm.signal(length(txPulse)+20:firstReflectionStartIndex-20);

% Enable / Disable use of transducer sensitivity
enableTS = false;
enableTS_noise = false;

% Noise PSD calculation: Using pWelch or periodogram
[psdNoise, fNoise] = ctrl.noiseAlg.calculatePsd(tm.transducerId, noiseSignal, enableTS_noise, 'periodogram', 'hanning', 400);

% Calculate mean and var for range [fLow, fHigh]
[meanValue, varValue] = ctrl.noiseAlg.calculateMeanVarInRange(tm.transducerId, im.header.fLow , im.header.fHigh)

% Plot Noise PSD
fig = ctrl.noiseAlg.plotPsd(tm.transducerId);
titleTxt = sprintf('Noise psd tr %d mean: %0.1f dB var: %0.1f dB ',tm.transducerId, round(meanValue,1), round(varValue,1));
title(titleTxt);
ylim([-160 -100]);

%% Or set noise floor to fixed value
meanValue = -135.7

%% Calculate psdMain and psdResonance
pulseLength = length(txPulse);

ctrl.config.ADJUST_START_TIME_RESONANCE = -6;
ctrl.config.ADJUST_STOP_TIME_RESONANCE =  0;
ctrl.config.WINDOW_RESONANCE = 'rect';%'kaiser'; %'hanning';
ctrl.config.WINDOW_MAIN = 'rect'; %'hanning'; 
ctrl.config.PERIODOGRAM_OVERLAP = 0.50;
ctrl.config.PERIODOGRAM_SEGMENT_LENGTH = 400;
ctrl.config.USE_PWELCH = false;
ctrl.config.MAX_WELCH_LENGTH = 1000;
ctrl.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;
ctrl.config.FFT_LENGTH = 4096;

ctrl.thicknessAlg.fLow = tm.fLow;
ctrl.thicknessAlg.fHigh = tm.fHigh;

if(false == ctrl.thicknessAlg.calculateStartStopForAbsorptionAndResonance(tm.signal, ctrl.callipAlg, 'plot'))
    error('Error in calculating start and stop index for resonance')
end

% Calculate PSD for resonance and absoption part of the signal
ctrl.thicknessAlg.calculatePsd(tm.signal);

% Plot PSD for resonance and absoption part of the signal
ctrl.thicknessAlg.plotPsd(tm.signal);

SNR = ctrl.thicknessAlg.calculateSNR(tm.signal, noiseSignal)

%% Plot Periodogram segments
ctrl.thicknessAlg.plotPeriodogramSegments(tm.signal);

%% Find peaks in the RESONANCE spectrum
% Using mean level above noise floor in range [fLow, fHigh]. 
% Can consider using level above noisePsd(f).
ctrl.thicknessAlg.meanNoiseFloor = meanValue;%noiseAlg.meanPsd(1);
% Override frequency range by setting fLow or fHigh.
fLow = 1e6;
fHigh = 3.8e6%tm.fHigh;
ctrl.config.Q_DB_ABOVE_NOISE = 10;
ctrl.config.Q_DB_MAX = 10;
ctrl.config.PROMINENCE = 15;
ctrl.config.V_PIPE = 5900;
tic
% Find peaks
ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);
toc

% Plot peaks
ctrl.thicknessAlg.plotPsdPeaks(ctrl.thicknessAlg.RESONANCE);

%% Find troughs in the RESONANCE spectrum
ctrl.thicknessAlg.meanNoiseFloor = 0
ctrl.thicknessAlg.psdResonance = -ctrl.thicknessAlg.psdResonance;
% Override frequency range by setting fLow or fHigh.
fLow = 0.3e6;
fHigh = 4.5e6%tm.fHigh;
ctrl.config.Q_DB_ABOVE_NOISE = 10;
ctrl.config.Q_DB_MAX = 10;
ctrl.config.PROMINENCE = 4;
ctrl.config.V_PIPE = 5900

% Find peaks
ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);
toc

% Plot peaks
ctrl.thicknessAlg.plotPsdPeaks(ctrl.thicknessAlg.RESONANCE);


%% Resonance Part: Find all harmonic sets
ctrl.config.DEVIATION_FACTOR = (ctrl.config.FFT_LENGTH/ctrl.config.SAMPLE_RATE) * (ctrl.config.SAMPLE_RATE/ctrl.config.PERIODOGRAM_SEGMENT_LENGTH) * 1.5;
    
requiredNumberOfHarmonicsInSet = 3;

% Find sets
ctrl.thicknessAlg.findFrequencySets(ctrl.thicknessAlg.RESONANCE, fLow, fHigh, requiredNumberOfHarmonicsInSet);
set = ctrl.thicknessAlg.setResonance

%% Find resonance sets
ctrl.config.D_MIN = 0.009;
ctrl.config.D_NOM = 0.013;
ctrl.thicknessAlg.processSets(ctrl.thicknessAlg.RESONANCE, ctrl.noiseAlg.psd(transducerId)) ;
set = ctrl.thicknessAlg.setResonance

%% Find the 'best' set
tic
[setC] = ctrl.thicknessAlg.findBestSetE(set)
toc

% Plot the set candidate
close all
ctrl.thicknessAlg.plotAllSets('resonance', setC)
titleTxtPart = strrep(im.header.projectId, '_', ' '); 
%filenameFig = strcat('Psd_Resonance_', res.title); 

titleTxt = sprintf('Resonance PSD, %s ', titleTxtPart);
%titleTxt = sprintf('Resonance PSD, %s F %2.2d %2.2e Hz, t: %1.2e s', im.header.pulsePattern, im.header.fLow, im.header.fHigh, im.header.pulseLength/im.header.sampleRate);
title(titleTxt)


%% Plot all sets
close all
ctrl.thicknessAlg.plotAllSets('resonance')

%% Main


ctrl.thicknessAlg.meanNoiseFloor = 0;%noiseAlg.meanPsd(1);
% Override frequency range by setting fLow or fHigh.
fLowMain = 0.3e6;%tm.fLow;
fHighMain = 5.5e6;
ctrl.config.Q_DB_ABOVE_NOISE = 10;
ctrl.config.Q_DB_MAX = 10;
ctrl.config.PROMINENCE = 4;
ctrl.config.V_PIPE = 5900;%3690;



% Find peaks
ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.MAIN, fLowMain, fHighMain, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);


% Plot peaks
ctrl.thicknessAlg.plotPsdPeaks(ctrl.thicknessAlg.MAIN);

ctrl.config.DEVIATION_FACTOR = (ctrl.config.FFT_LENGTH/ctrl.config.SAMPLE_RATE) * (ctrl.config.SAMPLE_RATE/ctrl.config.PERIODOGRAM_SEGMENT_LENGTH) * 1.5;
requiredNumberOfHarmonicsInSet = 2;
% Find sets
ctrl.thicknessAlg.findFrequencySets(ctrl.thicknessAlg.MAIN, fLowMain, fHighMain, requiredNumberOfHarmonicsInSet);
set = ctrl.thicknessAlg.setMain
%%
ctrl.config.D_MIN = 0.009;
ctrl.config.D_NOM = 0.014;
%ctrl.config.V_PIPE = 5900;
ctrl.thicknessAlg.processSets(ctrl.thicknessAlg.MAIN, ctrl.noiseAlg.psd(transducerId)) ;
set = ctrl.thicknessAlg.setMain
%%
[setC] = ctrl.thicknessAlg.findBestSetE(set)
%%
close all
ctrl.thicknessAlg.plotAllSets('absorption', setC)
%ctrl.thicknessAlg.plotAllSets('absorption')
%% Plot all
close all
ctrl.thicknessAlg.plotAllSets('absorption')
