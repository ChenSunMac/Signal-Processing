clear all
close all
import ppPkg.*
%%


ctrlScan = Controller;

% Set configuration
ctrlScan.config.D_MIN = 0.004;
ctrlScan.config.D_NOM = 0.0121;            
ctrlScan.config.SAMPLE_RATE = 15e6; 
ctrlScan.config.FFT_LENGTH = 4096;
ctrlScan.config.NOMINAL_DISTANCE_TO_WALL = 0.12;  
ctrlScan.config.ADJUST_START_TIME_RESONANCE = 0;
ctrlScan.config.ADJUST_STOP_TIME_RESONANCE =  0;
ctrlScan.config.WINDOW_RESONANCE = 'hanning';
ctrlScan.config.WINDOW_MAIN = 'rect'; 
ctrlScan.config.PERIODOGRAM_OVERLAP = 0.90;
ctrlScan.config.PERIODOGRAM_SEGMENT_LENGTH = 500;
ctrlScan.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;           
ctrlScan.config.Q_DB_ABOVE_NOISE = 30;
ctrlScan.config.Q_DB_MAX = 10;
ctrlScan.config.PROMINENCE = 22;
ctrlScan.config.DEVIATION_FACTOR = 5;
ctrlScan.config.DELTA_FREQUENCY_RANGE = 0.2e6;
ctrlScan.config.DEBUG_INFO = false;
ctrlScan.config.NUMBER_OF_CHANNELS = 1;

ctrlScan.keepPsdArrays = true;
ctrlScan.keepPeakData = true;
ctrlScan.fLow = 1.4e6;
ctrlScan.fHigh = 3.8e6;

ctrlScan.enableThicknessProcessing = true;


%% Testing transducerTestScript

load('psdMainBNLab03Latest_LG40_SG05.mat')

folderWithTransducerMeasurments = 'G:\data\scan\transducer\04012017';
folderToSaveFigures = 'C:\Users\Processing PC 01\Documents\MATLAB\matlab\figures\transducer measurment\batch 5';

res = transducerTest(ctrlScan, folderWithTransducerMeasurments, psdMainBNLab03Latest_LG40_SG05, folderToSaveFigures);












