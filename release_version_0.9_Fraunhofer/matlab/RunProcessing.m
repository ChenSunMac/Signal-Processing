clear all
close all

% Import Post package files
import ppPkg.*


%% Configuration

% Get an instance of the Controller class
ctrlScan = Controller;

% Set configuration parameters
ctrlScan.config.V_PIPE = 5900;
ctrlScan.config.D_MIN = 0.006;
ctrlScan.config.D_NOM = 0.012;
ctrlScan.config.SAMPLE_RATE = 15.0e6  
ctrlScan.config.FFT_LENGTH = 4096;
ctrlScan.config.NUMBER_OF_CHANNELS = 255;
ctrlScan.config.NOMINAL_DISTANCE_TO_WALL = 0.35;
ctrlScan.config.ADJUST_START_TIME_RESONANCE = -6;
ctrlScan.config.ADJUST_STOP_TIME_RESONANCE =  0;
ctrlScan.config.WINDOW_RESONANCE = 'rect'; 
ctrlScan.config.WINDOW_MAIN = 'rect'; 
ctrlScan.config.USE_PWELCH = false; 
ctrlScan.config.MAX_WELCH_LENGTH = 1000;
ctrlScan.config.PERIODOGRAM_OVERLAP = 0.50;
ctrlScan.config.PERIODOGRAM_SEGMENT_LENGTH = 400;
ctrlScan.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;  
ctrlScan.config.REQUIRED_NO_HARMONICS = 4;
ctrlScan.config.Q_DB_ABOVE_NOISE = 10; 
ctrlScan.config.Q_DB_MAX = 10;
ctrlScan.config.PROMINENCE = 4; %(7)
ctrlScan.config.DEVIATION_FACTOR = (ctrlScan.config.FFT_LENGTH/ctrlScan.config.SAMPLE_RATE) * (ctrlScan.config.SAMPLE_RATE/ctrlScan.config.PERIODOGRAM_SEGMENT_LENGTH) * 1;
ctrlScan.config.DELTA_FREQUENCY_RANGE = 0; 
ctrlScan.config.DEBUG_INFO = false;
ctrlScan.config.TS_ADJUST_ENABLE = false;
ctrlScan.config.TS_ADJUST_NOISE_ENABLE = false;
ctrlScan.config.RESONANCE_PSD_SEARCH_FOR_PEAKS = false;

% Disable / enable thickness algorithm
ctrlScan.enableThicknessProcessing = true;
ctrlScan.calculateThicknessFromResonancePsd = true;
ctrlScan.calculateNoiseFloor = true;
ctrlScan.keepPsdArrays = false;

msg = sprintf('Starting Post Processing application, version %s\n', ctrlScan.config.APPLICATION_VERSION);
disp(msg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Demonstration on how to run processing in parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get an instance of the Process class
p = Process;

% Set path to folder containing data

folderPath = ('E:\data\scan\DI16\DI16_machined_in_bn218_03_001_100mm_u359_du028_z100_dz1_chirp_500_4500_3us\DI18_machined_in_bn218_03_001_100mm_u359_du028_z100_dz1_chirp_500_4500_3us_20170611_12101497_header')

resultFolderPath = ('C:\Users\Processing PC 01\Documents\MATLAB\pureRelease\matlab\results\test1')

tic

% Start 4 Matlab workers for parallel processing.
% You can also process data in serial by skipping this call
% p.startWorkers(4)


% Example: process data lab from all transducers and from all data files. 
% ctrlScan.pr = p.runProcess(ctrlScan, folderPath,  'bluenoseRawEnabled', 0);

% Example: process data from all transducers and from all data files
%ctrlScan.pr = p.runProcess(ctrlScan, folderPath, 'transducerId', transducers, 'bluenoseRawEnabled',  1);

% Example: process data from one transducer but all files
%ctrlScan.pr = p.runProcess(ctrlScan, folderPath, 'transducerId', 14, 'bluenoseRawEnabled',  1);

% Example: Store processing data results to file. This can be usefull for
% longer runs.
%ctrlScan.pr = p.runProcess(ctrlScan, folderPath,  'bluenoseRawEnabled',  1, 'saveResultPath', resultFolderPath);


% Stop matlab workers
% p.stopWorkers()
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Demonstration on how to run processing in serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get an instance of the Process class
p = Process;

folderPath = ('E:\Jul18_36InchSteel_Fraunhofer_3us\Run4');

% ctrlScan.pr = p.runProcess(ctrlScan, folderPath, 'fileNumber', 5, 'bluenoseRawEnabled',  0);

% Example: process data from all transducers and from all data files
%ctrlScan.pr = p.runProcess(ctrlScan, folderPath, 'bluenoseRawEnabled',  1);

ctrlScan.header.pulseLength = 45;
% Example: process data from data file 9
ctrlScan.pr = p.runProcess(ctrlScan, folderPath, 'fileNumber', 3, 'bluenoseRawEnabled',  1);

% Example: process data from transducer 14 but from a set range [12878, 18638]
%ctrlScan.pr = p.runProcess(ctrlScan, folderPath, 'fileNumber', 8, 'transducerId', 14,'startIndex', 12878,'stopIndex',18638,  'bluenoseRawEnabled',  1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Demonstration of batch processing with different configuration parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Create base configuration
% 2. Create a number of configuration objects from the base
% 3. Edit each configuration
% 4. Run processing with each configuration

%% 1. Create base configuration
configBase = ctrlScan.config;
clear configArray

% 2. Create a number of configuration objects from the base
configArray = configBase.getArrayOfObjects(4);

%% 3.  Setting up configuration parameters
configArray(1).PERIODOGRAM_SEGMENT_LENGTH = 200;
configArray(2).PERIODOGRAM_SEGMENT_LENGTH = 300;
configArray(3).PERIODOGRAM_SEGMENT_LENGTH = 400;
configArray(4).PERIODOGRAM_SEGMENT_LENGTH = 500;

%% 4 Run processing with each configuration
% In this example the same data is processed 4 times with a different
% segment length for each processing.
% Result from each processing is stored to a file, given by the variable
% 'filenameResult'

% Path to folder containing data
folderPath = ('G:\data\fromBlueNoseFtp\Flowloop_Test\Jan05\Run1')

% Filename for each processing result
filenameResult = 'batch_test';

% Start processing with 3 Matlab workers
p = Process;

p.startWorkers(3)

p.runProcessBatch(ctrlScan, folderPath, configArray, filenameResult, 'transducerId', 7, 'bluenoseRawEnabled',  1);

p.stopWorkers()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Demonstration: View and investigate the Processing Results from Bluenose
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
import ppPkg.*
view = ViewBluenoseData(ctrlScan)

% As default I use the transducer layout we had for the
% tests nov 16. 
% To view the layout type:
% view.transducerLayout

% You need to change the layout for the nov 25 test


%% View calliper and thickness as an image

% First set the tool speed through the pipe, so that we get the correct
% alignment, as default tool speed is set to 0.1525 m/s
view.defaultToolSpeed = 0.36576;%0.1525;

% Before plotting the transducer measurements are aligned
[ fig ]= view.plotImage()


%% Plot calliper and thickness as a 3d surface plot
view.plotSurface()

%% Plotting a data from one transducer
% If you look at the plot done in the step above, we can investigate how
% the. Fo example for the "nov 16 test1 run2" its interesting to look at
% line 12, which because the remapping is actually transducer 14

% You can see that by using the dataTip, at line 12, and use the following
% function to get information about a point on the image.
pr = view.getPrFromImageCoordinate(2732, 13)

% You can see that this is data from transducer 14.

% We can plot callip and thickness data from this transducer as follows:
view.plotTransducer(pr.transducerId);
%% Plotting of pitch and roll ( from a transducer )
view.plotRollPitch(pr.transducerId)

%% Plotting of tool position at a point in the pipe
% We can use the calliper information from ring 1 and ring 6 to see how the
% tool is positioned in the pipe at a given shot index.
% Function assumes that transducer 18 has direction straight up.
shotIndex = 1000;

% Use the following function
view.calculateToolPositionAtIndex(shotIndex);

%% Plotting of tool position through the pipe

% Use the following function to do the calculations
view.calculateToolPositionThroughPipe()

%% 
% Then use the following function to plot the results:
view.plotToolPositionThroughPipe()

%% SNR 
groupId = 1;
view.plotGroupSNR(groupId)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reprocessing a selected area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Select region in image figure for reprocessing. 
[trLines, startStop] = view.selectRegionInImage()

dataAddress = view.getAddressOfArea(trLines, startStop);

% 1. set directly a transducer line or area to extract address for data points
% Example:
%dataAddress = view.getAddressOfArea([13:16], 2176, 2220);
%dataAddress = view.getAddressOfArea([13:16], 2179, 2216);
%dataAddress = view.getAddressOfArea([13], [2140 2180]);

%% 2. Reprocessing an area

% Set configuration
ctrlScan.config.D_NOM = 0.009;
%ctrlScan.config.PERIODOGRAM_SEGMENT_LENGTH = 500
%ctrlScan.config.USE_PWELCH = 0;
p = Process;
p.blueNoseRawData = 1;
p.reProcessArea(ctrlScan, dataAddress);

%% 3. Reprocessing an area

% Create a new view object to display processing result
view2 = ViewBluenoseData(ctrlScan)

%view2.transducerLayout = trLayout;
view2.defaultToolSpeed = 0.36576;
close all
[fig, im1] = view.plotImage()
title('Old')
[fig, im2] = view2.plotImage()
title('reprocessed')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Batch processing an area with different configuration parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
% 1. Create base configuration
% 2. Create a number of configuration objects from the base
% 3. Edit each configuration
% 4. Run processing with each configuration
configBase = ctrlScan.config;
clear configArray
configArray = configBase.getArrayOfObjects(2);

%% Edit each configuration
configArray(1).D_NOM = 0.01;
configArray(2).D_NOM = 0.005;

%% Run processing with each configuration
p = Process;
p.blueNoseRawData = 1;

filenameResults = 'batch';

p.reProcessAreaBatch(ctrlScan, configArray, dataAddress, filenameResults)

%% View the results, create a view object for each result. 
% 1. load the stored .mat file the batch result
% 2. create a view object for each result
view1 = ViewBluenoseData(ctrlBatch)
 
%%
view1.defaultToolSpeed = 0.36576;
view2.defaultToolSpeed = 0.36576;


%% Before plotting the transducer measurements are aligned
close all
view1.plotImage()
view2.plotImage()


