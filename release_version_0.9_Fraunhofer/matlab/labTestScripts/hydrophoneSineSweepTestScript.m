% Hydrophone sine sweep

clear all
%%
close all
import ppPkg.*
im = ImportHandler

%%
% Common start 100k with 1k hz step
% Frequency go from 100kHz to 5000kHz
fileNamePxi = 'D:\scan\hydrophone_scans\hydrophone_sine_sweep_100k_4900k_distance_120mm_bluenose_01_pxi\hydrophone_sine_sweep_100k_4900k_distance_120mm_bluenose_01_pxi_20160816_13035269_header';
fileNameTxa = 'D:\scan\hydrophone_scans\hydrophone_sine_sweep_100k_4900k_distance_120mm_bluenose_01_txa\hydrophone_sine_sweep_100k_4900k_distance_120mm_bluenose_01_txa_20160816_13062572_header';
fileNameTxaTuned = 'D:\scan\hydrophone_scans\hydrophone_sine_sweep_100k_4900k_distance_120mm_bluenose_01_txa_tuned\hydrophone_sine_sweep_100k_4900k_distance_120mm_bluenose_01_txa_tuned_20160816_14141731_header';



%% Process data
% Assume start Frequency 100kHz with 1kHz step
startFrequency = 100e3;
stepFrequency = 1e3; 

peak2peakArrayPxi = hydrophoneDataProcessSineSweep(  fileNamePxi, startFrequency, stepFrequency );
peak2peakArrayTxa = hydrophoneDataProcessSineSweep(  fileNameTxa, startFrequency, stepFrequency );
peak2peakArrayTxaTuned = hydrophoneDataProcessSineSweep(  fileNameTxaTuned, startFrequency, stepFrequency );


%% Plot

freqArray = startFrequency:stepFrequency:5000e3-stepFrequency;
figure
plot(freqArray, 10*log10(peak2peakArrayPxi)) 
hold on
plot(freqArray, 10*log10(peak2peakArrayTxa)) 
hold on
plot(freqArray, 10*log10(peak2peakArrayTxaTuned)) 

legend('PXI', 'TXA', 'TXA TUNED')
xlabel('Frequency [Hz]')
ylabel('dB')
grid on
xlim([startFrequency 5000e3]) 








% Import data file
header = im.readHeader(fileNameTxa);    
tmArr = im.importDataFile();
tmIndex = 800;
N = 8;
b = (1/N)*ones(1, N);
a = 1
%%

tm = tmArr(tmIndex);
tmIndex = tmIndex + 1

    
signalFilt = filtfilt(b, a, tm.signal);  
plot(tm.signal)
hold on
plot(signalFilt)
grid on
hold off 

%%


fileName_100mm_0deg = 'D:\scan\hydrophone_scans\freq_sweep_100mm_0deg_210_01_018\freq_sweep_100mm_0deg_210_01_018_20161017_15195158_header';
fileName_100mm_0deg5 = 'D:\scan\hydrophone_scans\freq_sweep_100mm_0deg5_210_01_018\freq_sweep_100mm_0deg5_210_01_018_20161017_15210891_header';
fileName_100mm_0deg5m = 'D:\scan\hydrophone_scans\freq_sweep_100mm_0deg5m_210_01_018\freq_sweep_100mm_0deg5m_210_01_018_20161017_15244577_header';
fileName_100mm_1deg = 'D:\scan\hydrophone_scans\freq_sweep_100mm_1deg_210_01_018\freq_sweep_100mm_1deg_210_01_018_20161017_15222257_header';
fileName_100mm_1deg0m = 'D:\scan\hydrophone_scans\freq_sweep_100mm_1deg0m_210_01_018\freq_sweep_100mm_1deg0m_210_01_018_20161017_15255500_header';
fileName_100mm_2deg = 'D:\scan\hydrophone_scans\freq_sweep_100mm_2deg_210_01_018\freq_sweep_100mm_2deg_210_01_018_20161017_15233760_header';
fileName_100mm_2deg0m = 'D:\scan\hydrophone_scans\freq_sweep_100mm_2deg0m_210_01_018\freq_sweep_100mm_2deg0m_210_01_018_20161017_15270393_header';

fileName_346mm_0deg = 'D:\scan\hydrophone_scans\freq_sweep_346mm_0deg_210_01_018\freq_sweep_346mm_0deg_210_01_018_20161017_12572352_header';
fileName_346mm_0deg5 = 'D:\scan\hydrophone_scans\freq_sweep_346mm_0deg5_210_01_018\freq_sweep_346mm_0deg5_210_01_018_20161017_12583668_header';
fileName_346mm_0deg5m = 'D:\scan\hydrophone_scans\freq_sweep_346mm_0deg5m_210_01_018\freq_sweep_346mm_0deg5m_210_01_018_20161017_13010961_header';
fileName_346mm_1deg0 = 'D:\scan\hydrophone_scans\freq_sweep_346mm_1deg0_210_01_018\freq_sweep_346mm_1deg0_210_01_018_20161017_12595808_header';
fileName_346mm_1deg0m = 'D:\scan\hydrophone_scans\freq_sweep_346mm_1deg0m_210_01_018\freq_sweep_346mm_1deg0m_210_01_018_20161017_13021424_header';

fileName_346mm_LC_in = 'D:\scan\hydrophone_scans\freq_sweep_hydrophone_346mm_0deg0_bn218_01_018_LC_in\freq_sweep_hydrophone_346mm_0deg0_bn218_01_018_LC_in_20161019_09524318_header';
fileName_346mm_LC_out = 'D:\scan\hydrophone_scans\freq_sweep_hydrophone_346mm_0deg0_bn218_01_018_LC_out\freq_sweep_hydrophone_346mm_0deg0_bn218_01_018_LC_out_20161019_09544993_header';

fileName_346mm_B16_LC_in = 'D:\scan\hydrophone_scans\freq_sweep_B016_346mm_0deg0_bn218_01_018_LC_in\freq_sweep_B016_346mm_0deg0_bn218_01_018_LC_in_20161019_13275014_header';
fileName_346mm_B16_LC_out = 'D:\scan\hydrophone_scans\freq_sweep_B016_346mm_0deg0_bn218_01_018_LC_out\freq_sweep_B016_346mm_0deg0_bn218_01_018_LC_out_20161019_13260834_header';

files_100mm = {fileName_100mm_0deg, fileName_100mm_0deg5, fileName_100mm_0deg5m, fileName_100mm_1deg, fileName_100mm_1deg0m, fileName_100mm_2deg, fileName_100mm_2deg0m};
files_346mm = {fileName_346mm_0deg, fileName_346mm_0deg5, fileName_346mm_0deg5m, fileName_346mm_1deg0, fileName_346mm_1deg0m};
files_LC_test = {fileName_346mm_LC_in, fileName_346mm_LC_out};
files_LC_B16_test = {fileName_346mm_B16_LC_in, fileName_346mm_B16_LC_out};

%files_LC_test = {fileName_346mm_LC_out};
%% Process data
% Assume start Frequency 100kHz with 1kHz step
peak2peakArray = [];
startFrequency = 500e3;
stepFrequency = 10e3; 
for index = 1:numel(files_LC_B16_test)
    peak2peakArray(index,:) = hydrophoneDataProcessSineSweep(  files_LC_B16_test{index}, startFrequency, stepFrequency );
end


%%
freqArray = startFrequency:stepFrequency:5000e3-stepFrequency;
figure
plot(freqArray, 10*log10(peak2peakArray(:,:)))
grid on
%title('100mm frequency sweep 0.5-4.0MHz BN218 018')
%legend('0 deg','0.5 deg','-0.5 deg','1.0 deg','-1.0 deg','2.0 deg','-2.0 deg')
%title('346mm frequency sweep 0.5-4.0MHz BN218 018')
%legend('0 deg','0.5 deg','-0.5 deg','1.0 deg','-1.0 deg')
title('346mm frequency sweep 0.5-5.0MHz at B16 BN218 018, transducer only ')
legend('LC in', 'LC out')





