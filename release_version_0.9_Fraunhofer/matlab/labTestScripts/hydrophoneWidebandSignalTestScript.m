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
ctrlScan.config.NUMBER_OF_CHANNELS = 1

ctrlScan.keepPsdArrays = true;
ctrlScan.keepPeakData = true;
ctrlScan.fLow = [];
ctrlScan.fHigh = [];

ctrlScan.enableThicknessProcessing = true;
ctrlScan.skipThicknessCalculation = true;

%psdMain = zeros(1,2049); 
%psdResonance = zeros(1,2049);
psdIndex = 1;
psdResonance = [];
psdMain = [];
psdResonance2 = [];
psdMain2 = [];
%%
close all

filename1 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN3_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN3_120MM_LG40_SG05_8TX0_TTF17_20170109_13295416_header';
filename2 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN218_01_014_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN218_01_014_120MM_LG40_SG05_8TX0_TTF17_20170109_12530428_header';
filename3 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN218_01_017_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN218_01_017_120MM_LG40_SG05_8TX0_TTF17_20170109_13122905_header';
filename4 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN218_02_001_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN218_02_001_120MM_LG40_SG05_8TX0_TTF17_20170109_11111093_header';
filename5 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN218_02_003_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN218_02_003_120MM_LG40_SG05_8TX0_TTF17_20170109_11521274_header';
filename6 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_TTF17_20170109_10375668_header';
filename7 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_TUNED\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_TUNED_20170109_10151824_header';
filename8 = 'G:\data\scan\hydrophone_scans\09012017\HYPH_BN218_03_003_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN218_03_003_120MM_LG40_SG05_8TX0_TTF17_20170109_10523836_header';

files = {filename1, filename2, filename3, filename4, filename5, filename6, filename7, filename8};

%%
close all

filename1 = 'G:\data\scan\hydrophone_scans\12012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L4\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L4_20170112_14190434_header';
filename2 = 'G:\data\scan\hydrophone_scans\12012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L5\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L5_20170112_14584799_header';
filename3 = 'G:\data\scan\hydrophone_scans\12012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L6\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L6_20170112_15391172_header';
filename4 = 'G:\data\scan\hydrophone_scans\12012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L7\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L7_20170112_16071912_header';
filename5 = 'G:\data\scan\hydrophone_scans\12012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L8\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L8_20170112_16331095_header';

files = {filename1, filename2, filename3, filename4, filename5};
names = {'L4','L5','L6','L7','L8'};

%%
warning('off','all')
batchCell = {};
for index = 1:numel(files)   
    index
    tic
    ctrlScan.start(files{index});
    toc
    
    %pMain(index, :) = mean([ctrlScan.pr(:).pMain]');
    psdMain(index, :) = ([ctrlScan.pr(1).psdMain]');
    
    %distance = char(distanceCell(1))
    %[tokens, matches] = regexp(fileName1M0,'_(0[0-9]{2})_','tokens','match');
    %transducerId = char(tokens{1}{1})    
end
warning('on','all')
warning('query','all')

%%
%psdMain = mean([ctrlScan.pr(:).psdMain]');
figure
transducer = 'BN218 03 003';
titleTxt = sprintf('%s LG40 SG05 8 TX TTF17', transducer);
plot(ctrlScan.pr(1).fMain, psdMain(1,:))
hold on
plot(ctrlScan.pr(1).fMain, psdMain(1,:))
grid on
legend(transducer, 'BN lab3 LG40 SG05')
title(titleTxt)
%%
figure
for index = 1:numel(files)   
    plot(ctrlScan.pr(1).fMain, pMain(index,(1:ctrlScan.config.FFT_LENGTH/2+1)))
    %plot(f,P(1:thicknessAlg.config.FFT_LENGTH/2+1))
    hold on
end
hold off
grid on
legend(names)
title('BN218 03 001 LG40 SG05 8TX0. Setting L4 to L8')
xlim([0.5e6 4e6])

