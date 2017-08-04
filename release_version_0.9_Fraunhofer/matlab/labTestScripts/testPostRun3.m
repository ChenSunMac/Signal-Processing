clear all
close all
import ppPkg.*
%%


ctrlScan = Controller;

% Set configuration
ctrlScan.config.D_MIN = 0.008;
ctrlScan.config.D_NOM = 0.013;            
ctrlScan.config.SAMPLE_RATE = 15e6; 
ctrlScan.config.FFT_LENGTH = 4096;
ctrlScan.config.NUMBER_OF_CHANNELS = 255;
ctrlScan.config.NOMINAL_DISTANCE_TO_WALL = 0.36;
ctrlScan.config.ADJUST_START_TIME_RESONANCE = 0;
ctrlScan.config.ADJUST_STOP_TIME_RESONANCE =  0;
ctrlScan.config.WINDOW_RESONANCE = 'hanning';
ctrlScan.config.WINDOW_MAIN = 'rect'; 
ctrlScan.config.PERIODOGRAM_OVERLAP = 0.90;
ctrlScan.config.PERIODOGRAM_SEGMENT_LENGTH = 500;
ctrlScan.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;           
ctrlScan.config.Q_DB_ABOVE_NOISE = 20; %20
ctrlScan.config.Q_DB_MAX = 10;
ctrlScan.config.PROMINENCE = 15; %15
ctrlScan.config.DEVIATION_FACTOR = 5;
ctrlScan.config.DELTA_FREQUENCY_RANGE = 0.2e6;
ctrlScan.config.DEBUG_INFO = false;
ctrlScan.config.TS_ADJUST_ENABLE = false;
ctrlScan.config.TS_ADJUST_NOISE_ENABLE = false;

%ctrlScan.config.FREQUENCY_REMOVE = [];
ctrlScan.keepPsdArrays = false

% Disable / enable thickness algorithm
ctrlScan.enableThicknessProcessing = true;

%%
% chirp
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z50mm/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z50mm_2_20160624_13444413_header');
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z80mm/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z80mm_2_20160624_13511972_header');
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z120mm/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z120mm_2_20160624_13565982_header');
% rect-chirp
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z50mm/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z50mm_2_20160624_13460167_header');
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z80mm/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z80mm_2_20160624_13523939_header');
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z120mm/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z120mm_2_20160624_13584176_header');
% sinc
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z50mm/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z50mm_2_20160624_13425177_header');
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z80mm/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z80mm_2_20160624_13494981_header');
%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z120mm/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z120mm_2_20160624_13553352_header');


%ctrlScan.start('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z80mm/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z80mm_2_20160624_13523939_header');

%ctrlScan.start('E:/LabSystem_Data/07062016/pipe_150mm_z90000_u2_dz1000_du1/pipe_150mm_z90000_u2_dz1000_du1_20160607_15002158_header');

% 30 us plate
%ctrlScan.start('E:/LabSystem_Data/Scan_Half_Plate_16mm_Chirp_300k_3800k_30u/Scan_Half_Plate_16mm_Chirp_300k_3800k_30u_20160620_12474370_header');
% 30 us plate, 8 cm
%ctrlScan.start('E:/LabSystem_Data/reScan_Half_Plate_16mm_Chirp_300k_3800k_30u_Z8cm/reScan_Half_Plate_16mm_Chirp_300k_3800k_30u_Z8cm_20160622_10143861_header');

% 60 us plate
%ctrlScan.start('E:/LabSystem_Data/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');

%ctrlScan.start('recording/31052016/Scan_Plate_16mm_Chirp_500k_3800K_20160531_12551842_header');
%ctrlScan.start('H:/LabSystem_Data/Scan_Pipe_10mm_Chirp_500k_3800k/Scan_Pipe_10mm_Chirp_500k_3800k_20160602_15084630_header')
%ctrlScan.start('H:/LabSystem_Data/Scan_Pipe_10mm_Chirp_500k_3800k/Scan_Pipe_10mm_Chirp_500k_3800k_20160602_15084630_header')

%ctrlScan.start('E:/LabSystem_Data/16062016/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_15M/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_15M_20160616_14052069_header');
%ctrlScan.start('E:/LabSystem_Data/16062016/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_10M/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_10M_20160616_14083448_header');

% Testing with or without DIO
%ctrlScan.start('recording/Dio_Test/B16_01_T130_T025_Line_Chirp_300k_3800k_30u/B16_01_T130_T025_Line_Chirp_300k_3800k_30u_20160705_11425049_header');
%ctrlScan.start('recording/Dio_Test/B16_01_T130_T025_Line_Chirp_300k_3800k_30u_SwitchGain/B16_01_T130_T025_Line_Chirp_300k_3800k_30u_SwitchGain_20160705_11405140_header');

%ctrlScan.start('E:/LabSystem_Data/B16_01_SEC01_Chirp_300k_3800k_30u_Z120mm_Back/B16_01_SEC01_Chirp_300k_3800k_30u_Z120mm_Back_20160701_08233889_header');

%ctrlScan.start('E:/LabSystem_Data/B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm/B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm_20160706_08241336_header');


%ctrlScan.start('D:\scan\22072016\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z50mm\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z50mm_20160722_07101103_header');
%ctrlScan.start('D:\scan\21072016\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z120mm\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z120mm_20160721_10102196_header')

%ctrlScan.start('D:\scan\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm_20160706_08241336_header');

%ctrlScan.start('D:\scan\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_20160804_15250327_header');

%ctrlScan.start('D:\scan\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SLOW_8MM_PITTING\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SLOW_8MM_PITTING_20160805_11283763_header');

%ctrlScan.start('D:\scan\B10_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SPEED_2000\B10_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SPEED_2000_20160805_13230479_header');%%

%ctrlScan.start('D:\scan\31052016\Scan_Plate_16mm_Chirp_500k_3800K_20160531_12551842_header')
%ctrlScan.start('D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header')

% PIPE
%ctrlScan.start('H:/LabSystem_Data/Scan_Pipe_10mm_Chirp_500k_3800k/Scan_Pipe_10mm_Chirp_500k_3800k_20160602_15084630_header');
%ctrlScan.start('H:/LabSystem_Data/06062016/pipe_chirp_z5000_u1850_grounded_rod/pipe_chirp_z5000_u1850_grounded_rod_20160606_10140766_header');
%ctrlScan.start('H:/LabSystem_Data/06062016/pipe_sinc_1M_3M7_z5000_u1850_rod_grounded/pipe_sinc_1M_3M7_z5000_u1850_rod_grounded_20160606_12330547_header');
%ctrlScan.start('H:/LabSystem_Data/06062016/pipe_chirp_z5000_u1850_nylon_rod/pipe_chirp_nylon_rod_z5000_u1850_20160606_14070704_header');

warning('off','all')
%ctrlScan.start('H:\LabSystem_Data\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm_20160629_15454786_header');
%ctrlScan.start('H:/LabSystem_Data/07062016/pipe_rotated_z30000_u200000_dz1000_du370/pipe_rotated_z30000_u200000_dz1000_du370_20160607_09161087_header');

%ctrlScan.start('D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000_20160819_14365710_header',107);
%ctrlScan.start('D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000_20160820_22593037_header',102);

%ctrlScan.start('D:\scan\pipe_sec01_RX1A_TX1A_z100_u100_dz1_du037_wd_70mm\pipe_sec01_RX1A_TX1A_z100_u100_dz1_du037_wd_70mm_20160822_10013506_header', 64)

%ctrlScan.start('D:\scan\pipe\26082016\pipe_sec01_8chRXCH0_LG40_SG18_TX1A_z100_u200_dz1_du037_wd_70mm\pipe_sec01_8chRXCH0_LG40_SG18_TX1A_z100_u200_dz1_du037_wd_70mm_20160826_13321604_header', 50);
%ctrlScan.start('D:\scan\pipe\pipe_sec01_8chRXCH0_LG120_SG18_TX1A_z100_u200_dz1_du037_wd_70mm\pipe_sec01_8chRXCH0_LG120_SG18_TX1A_z100_u200_dz1_du037_wd_70mm_20160830_15471855_header', 50 )

%ctrlScan.start('D:\scan\B16\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm_20160629_15454786_header', 50);               
%ctrlScan.start('D:\scan\B16\B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm_20160629_09485329_header', 110)

%ctrlScan.start('D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000_20160820_22593037_header', 50);
%ctrlScan.start('../recording/B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm_20160629_15454786_header', 109);
%ctrlScan.start('../recording/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');
%ctrlScan.start('../recording/31052016/Scan_Plate_16mm_Chirp_500k_3800K_20160531_12551842_header');
%ctrlScan.start('../recording/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm_20160629_09485329_header', 111, 73);

%ctrlScan.start('D:\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4_20161019_14345389_header', 44);
%ctrlScan.start('D:\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10_20161020_15202104_header', 34);
ctrlScan.start('D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header',102);

warning('on','all')
warning('query','all')

%% Plot thickness


%close all
figure

plot([ctrlScan.pr(1:end).thickness])

hold on
plot([ctrlScan.pr(1:end).calliper])
%plot([ctrlScan0.pr(1:end).thickness] +0.01)
%plot([ctrlScan.pr(1:end).thicknessMain])
%hold on
%plot([ctrlScan.pr(1:end).calliper])
hold on
%plot([ctrlScan.pr(1:end).thicknessFromHighestAverage])
%plot([ctrlScan.pr(1:end).calliperPitDetect])
%plot([ctrlScan.pr(1:end).thicknessCombined], 'black')

%hold on
%plot([ctrlScan.pr(1:end).debug],'black')
%plot([scanUtenTs.pr(1:400).thickness])


%hold on 
%plot(-[ctrlScan.pr(:).calliper])
%plot(-[ctrlScan.pr(1:400).calliper]+0.1340)
grid on

%% Parallel processing
% This is just an example how we can do parallel processing on several
% files at the same time. I have used the SPMD function. There might be
% other metods we could also use. 

% Create parallel pool with 4 workers.
% You can try 7 for faster processing if you have 4 cores, but you might
% have to edit the Cluster Profile Manager to allow that. 
%
numWorkers = 1;
poolobj = parpool('local', numWorkers)

%%
addpath('C:\Users\Processing PC 01\Documents\MATLAB\matlab\+ppPkg');
addpath('C:\Users\Processing PC 01\Documents\MATLAB\matlab\+ppPkg\@ThicknessAlgorithm');
addpath('C:\Users\Processing PC 01\Documents\MATLAB\matlab\+ppPkg\@TransducerMeasurement');

%% Disable / enable thickness algorithm
ctrlScan.enableThicknessProcessing = true;

%headerFile = 'D:\scan\pipe\pipe_sec01_8chRXCH0_LG120_SG18_TX1A_z100_u200_dz1_du037_wd_70mm\pipe_sec01_8chRXCH0_LG120_SG18_TX1A_z100_u200_dz1_du037_wd_70mm_20160830_15471855_header';
%headerFile =  'D:\scan\B16\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm_20160629_15454786_header';
%headerFile =  'D:\scan\B16\B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm_20160629_09485329_header';
%headerFile = 'D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000_20160819_14365710_header';
%headerFile = 'D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header';
%headerFile = 'D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000_20160820_22593037_header';
%headerFile =  '../recording/B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm_20160629_15454786_header';
%headerFile =  '\\DESKTOP-T2EO66V\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4_20161019_14345389_header'
%headerFile =  'D:\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4_20161019_14345389_header'
%headerFile = 'D:\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10_20161020_15202104_header';
headerFile = 'D:\fromBlueNoseFtp\Flowloop_Test\24D_test'

tic
ctrlScan.pr = RunParallelProcessing(ctrlScan, headerFile,'fileNumber', 1, 'transducerId',[8], 'bluenoseRawEnabled', 1);
toc
 

% Close parallel pool
delete(poolobj) 

%%
% Disable / enable thickness algorithm
ctrlScan.enableThicknessProcessing = false;

headerFile = 'D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header';

ctrlScan.startParallel(headerFile);

%% Start calliper and thickness processing 
% Example: Processing data from a specific file
fileNumber = 189;
ctrlScan.start(headerFile, fileNumber) ;


%%
for index = 1:length(ctrlScan.pr)
    if(isempty(ctrlScan.pr(index).thicknessMain))
        ctrlScan.pr(index).thicknessMain = 0;
        index
    end
    
end

%% figure

figure




%%
figure
plot([ctrlScan.pr(1:end).thicknessMain])
grid on
title('Thickness from Main')
%%
figure
plot([scan1.pr(1:end).noiseMean])
hold on
plot([scan2.pr(1:end).noiseMean])

%%

figure
plot(-[scanUten.pr(:).calliper])
hold on
plot(-[scanMed.pr(:).calliper])

%%
figure
plot([chirp_50mm.pr(:).thickness])
hold on
plot([chirp_80mm.pr(:).thickness])
hold on
plot([chirp_120mm.pr(:).thickness])
hold on
%plot([scanAverage_5p.pr(:).thickness])
grid on
%%
plot([scanUten.pr(1).psdResonance])
hold on
plot([ctrlScan.pr(1).psdResonance])
%%

vp_1 = [''];
for index = 1:length(ctrlScan.pr)
    
    vp_1(end+1) = ctrlScan.pr(index).class; 
end

%%

array = [];
for index = 1:length(setWithClassA)
    array(end+1) = set(setWithClassA(index)).validationParameter(3)   
end

%%
X=[ctrlScan.pr(:).xPos];
Y=[ctrlScan.pr(:).yPos];
Z=[ctrlScan.pr(:).zPos];
U=[ctrlScan.pr(:).uPos];
%%
figure
plot3(Z(1:end),x1(1:end),[ctrlScan.pr(:).thicknessMain],'.')

%%
R = 1500
x1 = ((2*pi*R/360) .* U);

%%
[zi,xi] = meshgrid(min(Z):300:max(Z), min(x1):300:max(x1));

yi = griddata(Z,x1,tMain,zi,xi);
figure
surf(zi,xi,yi);

%% Demonstrate scattered data
load('results/B16_calliper_and_thickness')
%% Create scattered data
index = 1:length(ctrlScan.pr);
% every other sample 
la1 = (mod(index,3) == 0);

% Random scattered data
la2 = rand(1,length(index))>0.9;

subset1 = ctrlScan.pr(la1);

length(subset1)
%% Scattered data plot as dots 
subset = ctrlScan.pr;
x = [subset(:).xPos];
y = [subset(:).yPos];
thickness = [subset(:).thickness];
figure
plot3(x,y, thickness,'.')
%% Interpolating scattered data and place in grid
subset = subset1;
x = [subset(:).xPos];
y = [subset(:).yPos];
thickness = [subset(:).thickness];
min_x = min(x);
min_y = min(y);
max_x = max(x);
max_y = max(y);

gridResolutionUm = 3000; % default 1000 ?m

[xi,yi] = meshgrid(min_x:gridResolutionUm:max_x, min_y:gridResolutionUm:max_y);  
zi = griddata(x,y,thickness,xi,yi);
figure
surf(xi,yi,zi); 
