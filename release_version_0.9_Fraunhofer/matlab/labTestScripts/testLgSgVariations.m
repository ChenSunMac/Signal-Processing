%clear all
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
ctrlScan.fLow = 1.4e6;
ctrlScan.fHigh = 3.8e6;

ctrlScan.enableThicknessProcessing = true;

%psdMain = zeros(1,2049); 
%psdResonance = zeros(1,2049);
psdIndex = 1;
psdResonance = [];
psdMain = [];
psdResonance2 = [];
psdMain2 = [];
%%
close all
% pos 100
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg02_lg40\pipe_pos100_sg02_lg40_20160906_10402877_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg02_lg72\pipe_pos100_sg02_lg72_20160906_10451186_header');
%trlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg02_lg80\pipe_pos100_sg02_lg80_20160906_10353312_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg02_lg100\pipe_pos100_sg02_lg100_20160906_10491810_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg02_lg120\pipe_pos100_sg02_lg120_20160906_10543979_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg05_lg40\pipe_pos100_sg05_lg40_20160906_10405952_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg05_lg72\pipe_pos100_sg05_lg72_20160906_10453449_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg05_lg80\pipe_pos100_sg05_lg80_20160906_10355376_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg05_lg100\pipe_pos100_sg05_lg100_20160906_10493610_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg05_lg120\pipe_pos100_sg05_lg120_20160906_10550120_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg15_lg40\pipe_pos100_sg15_lg40_20160906_10414371_header')
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg15_lg72\pipe_pos100_sg15_lg72_20160906_10462123_header')
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg15_lg80\pipe_pos100_sg15_lg80_20160906_10363436_header')
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg15_lg100\pipe_pos100_sg15_lg100_20160906_10505816_header')
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg15_lg120\pipe_pos100_sg15_lg120_20160906_10554033_header')

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg10_lg40\pipe_pos100_sg10_lg40_20160906_10412341_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg10_lg72\pipe_pos100_sg10_lg72_20160906_10455720_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg10_lg80\pipe_pos100_sg10_lg80_20160906_10361404_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg10_lg100\pipe_pos100_sg10_lg100_20160906_10503438_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg10_lg120\pipe_pos100_sg10_lg120_20160906_10552025_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg18_lg40\pipe_pos100_sg18_lg40_20160906_10421566_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg18_lg72\pipe_pos100_sg18_lg72_20160906_10464391_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg18_lg80\pipe_pos100_sg18_lg80_20160906_10365669_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg18_lg100\pipe_pos100_sg18_lg100_20160906_10512074_header')
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg18_lg120\pipe_pos100_sg18_lg120_20160906_10560075_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg25_lg40\pipe_pos100_sg25_lg40_20160906_10424249_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg25_lg72\pipe_pos100_sg25_lg72_20160906_10471112_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg25_lg80\pipe_pos100_sg25_lg80_20160906_10371958_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg25_lg100\pipe_pos100_sg25_lg100_20160906_10514140_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos100_sg25_lg120\pipe_pos100_sg25_lg120_20160906_10562140_header');


% pos 140
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg02_lg40\pipe_pos140_sg02_lg40_20160906_13452902_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg02_lg72\pipe_pos140_sg02_lg72_20160906_13530697_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg02_lg80\pipe_pos140_sg02_lg80_20160906_13573484_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg02_lg100\pipe_pos140_sg02_lg100_20160906_14022949_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg02_lg120\pipe_pos140_sg02_lg120_20160906_14084730_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg05_lg40\pipe_pos140_sg05_lg40_20160906_13455559_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg05_lg72\pipe_pos140_sg05_lg72_20160906_13532512_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg05_lg80\pipe_pos140_sg05_lg80_20160906_13575560_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg05_lg100\pipe_pos140_sg05_lg100_20160906_14025490_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg05_lg120\pipe_pos140_sg05_lg120_20160906_14090634_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg10_lg40\pipe_pos140_sg10_lg40_20160906_13470355_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg10_lg72\pipe_pos140_sg10_lg72_20160906_13534556_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg10_lg80\pipe_pos140_sg10_lg80_20160906_13581553_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg10_lg100\pipe_pos140_sg10_lg100_20160906_14031602_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg10_lg120\pipe_pos140_sg10_lg120_20160906_14092549_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg15_lg40\pipe_pos140_sg15_lg40_20160906_13472934_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg15_lg72\pipe_pos140_sg15_lg72_20160906_13540812_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg15_lg80\pipe_pos140_sg15_lg80_20160906_13583760_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg15_lg100\pipe_pos140_sg15_lg100_20160906_14033787_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg15_lg120\pipe_pos140_sg15_lg120_20160906_14094699_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg18_lg40\pipe_pos140_sg18_lg40_20160906_13475254_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg18_lg72\pipe_pos140_sg18_lg72_20160906_13542818_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg18_lg80\pipe_pos140_sg18_lg80_20160906_13585844_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg18_lg100\pipe_pos140_sg18_lg100_20160906_14043063_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg18_lg120\pipe_pos140_sg18_lg120_20160906_14100626_header')

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg25_lg40\pipe_pos140_sg25_lg40_20160906_13481389_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg25_lg72\pipe_pos140_sg25_lg72_20160906_13544938_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg25_lg80\pipe_pos140_sg25_lg80_20160906_13592311_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg25_lg100\pipe_pos140_sg25_lg100_20160906_14045200_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos140_sg25_lg120\pipe_pos140_sg25_lg120_20160906_14102793_header');

% pos 320
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg02_lg40\pipe_pos320_sg02_lg40_20160906_11360826_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg02_lg72\pipe_pos320_sg02_lg72_20160906_11300962_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg02_lg80\pipe_pos320_sg02_lg80_20160906_11253877_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg02_lg100\pipe_pos320_sg02_lg100_20160906_11202948_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg02_lg120\pipe_pos320_sg02_lg120_20160906_11160778_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg05_lg40\pipe_pos320_sg05_lg40_20160906_11362573_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg05_lg72\pipe_pos320_sg05_lg72_20160906_11303514_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg05_lg80\pipe_pos320_sg05_lg80_20160906_11255616_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg05_lg100\pipe_pos320_sg05_lg100_20160906_11204930_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg05_lg120\pipe_pos320_sg05_lg120_20160906_11163616_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg10_lg40\pipe_pos320_sg10_lg40_20160906_11364499_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg10_lg72\pipe_pos320_sg10_lg72_20160906_11305731_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg10_lg80\pipe_pos320_sg10_lg80_20160906_11261945_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg10_lg100\pipe_pos320_sg10_lg100_20160906_11210993_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg10_lg120\pipe_pos320_sg10_lg120_20160906_11165581_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg15_lg40\pipe_pos320_sg15_lg40_20160906_11370590_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg15_lg72\pipe_pos320_sg15_lg72_20160906_11315854_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg15_lg80\pipe_pos320_sg15_lg80_20160906_11263758_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg15_lg100\pipe_pos320_sg15_lg100_20160906_11213178_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg15_lg120\pipe_pos320_sg15_lg120_20160906_11171653_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg18_lg40\pipe_pos320_sg18_lg40_20160906_11372410_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg18_lg72\pipe_pos320_sg18_lg72_20160906_11321779_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg18_lg80\pipe_pos320_sg18_lg80_20160906_11265757_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg18_lg100\pipe_pos320_sg18_lg100_20160906_11215224_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg18_lg120\pipe_pos320_sg18_lg120_20160906_11173724_header');

%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg25_lg40\pipe_pos320_sg25_lg40_20160906_11374651_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg25_lg72\pipe_pos320_sg25_lg72_20160906_11323710_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg25_lg80\pipe_pos320_sg25_lg80_20160906_11271699_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg25_lg100\pipe_pos320_sg25_lg100_20160906_11221454_header');
%ctrlScan.start('D:\scan\pipe\06092016\pipe_pos320_sg25_lg120\pipe_pos320_sg25_lg120_20160906_11180232_header');
%ctrlScan.start('D:\scan\transducer\B14_BN218_01_012_120MM_LG40_SG10\B14_BN218_01_012_120MM_LG40_SG10_20160923_10525647_header');
%ctrlScan.start('D:\scan\transducer\B14_BN218_01_006_120MM_LG40_SG10\B14_BN218_01_006_120MM_LG40_SG10_20160923_11111174_header');
%ctrlScan.start('D:\scan\B14\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm_20160706_08241336_header',50)
%ctrlScan.start('D:\scan\transducer\B14_BN218_01_003_120MM_LG40_SG10\B14_BN218_01_003_120MM_LG40_SG10_20160923_15233113_header');
%ctrlScan.start('D:\scan\transducer\B14_BN218_01_009_120MM_LG40_SG10\B14_BN218_01_009_120MM_LG40_SG10_20160923_15443550_header');
%ctrlScan.start('D:\scan\transducer\B14_BN218_01_018_120MM_LG40_SG10\B14_BN218_01_018_120MM_LG40_SG10_20160923_15101971_header');
%ctrlScan.start('D:\scan\transducer\B14_BN218_01_025_120MM_LG40_SG10\B14_BN218_01_025_120MM_LG40_SG10_20160923_14562405_header');
%ctrlScan.start('D:\scan\transducer\B14_BN218_01_032_120MM_LG40_SG10\B14_BN218_01_032_120MM_LG40_SG10_20160923_15354462_header')

%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_019_120MM_LG40_SG10\B12_BN218_01_019_120MM_LG40_SG10_20160926_16593615_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_019_120MM_LG40_SG10_RX_TX_SWITCHED\B12_BN218_01_019_120MM_LG40_SG10_RX_TX_SWITCHED_20160926_17050715_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_019_120MM_LG40_SG10_RX_TX_SWITCHED_SCOPE_5\B12_BN218_01_019_120MM_LG40_SG10_RX_TX_SWITCHED_SCOPE_5_20160926_17053876_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_020_120MM_LG40_SG10\B12_BN218_01_020_120MM_LG40_SG10_20160926_13000091_header')

%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_001_120MM_LG40_SG10\B12_BN218_01_001_120MM_LG40_SG10_20160926_14284838_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_002_120MM_LG40_SG10\B12_BN218_01_002_120MM_LG40_SG10_20160926_14485849_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_004_120MM_LG40_SG10\B12_BN218_01_004_120MM_LG40_SG10_20160926_13095690_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_005_120MM_LG40_SG10\B12_BN218_01_005_120MM_LG40_SG10_20160926_16475448_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_007_120MM_LG40_SG10\B12_BN218_01_007_120MM_LG40_SG10_20160926_11052645_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_008_120MM_LG40_SG10\B12_BN218_01_008_120MM_LG40_SG10_20160926_12371523_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_010_120MM_LG40_SG10\B12_BN218_01_010_120MM_LG40_SG10_20160926_15464313_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_011_120MM_LG40_SG10\B12_BN218_01_011_120MM_LG40_SG10_20160926_16322536_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_013_120MM_LG40_SG10\B12_BN218_01_013_120MM_LG40_SG10_20160926_14391268_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_014_120MM_LG40_SG10\B12_BN218_01_014_120MM_LG40_SG10_20160926_13421163_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_015_120MM_LG40_SG10\B12_BN218_01_015_120MM_LG40_SG10_20160926_15353846_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_016_120MM_LG40_SG10\B12_BN218_01_016_120MM_LG40_SG10_20160926_15165893_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_017_120MM_LG40_SG10\B12_BN218_01_017_120MM_LG40_SG10_20160926_12511418_header')
% 
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_021_120MM_LG40_SG10\B12_BN218_01_021_120MM_LG40_SG10_20160926_15264866_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_022_120MM_LG40_SG10\B12_BN218_01_022_120MM_LG40_SG10_20160926_16140982_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_023_120MM_LG40_SG10\B12_BN218_01_023_120MM_LG40_SG10_20160926_13305773_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_024_120MM_LG40_SG10\B12_BN218_01_024_120MM_LG40_SG10_20160926_11231805_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_026_120MM_LG40_SG10\B12_BN218_01_026_120MM_LG40_SG10_20160926_11135448_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_027_120MM_LG40_SG10\B12_BN218_01_027_120MM_LG40_SG10_20160926_13182421_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_028_120MM_LG40_SG10\B12_BN218_01_028_120MM_LG40_SG10_20160926_16224616_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_029_120MM_LG40_SG10\B12_BN218_01_029_120MM_LG40_SG10_20160926_10574514_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_030_120MM_LG40_SG10\B12_BN218_01_030_120MM_LG40_SG10_20160926_14091061_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_031_120MM_LG40_SG10\B12_BN218_01_031_120MM_LG40_SG10_20160926_11322424_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_034_120MM_LG40_SG10\B12_BN218_01_034_120MM_LG40_SG10_20160926_14184075_header')
%ctrlScan.start('D:\scan\transducer\26092016\B12_BN218_01_035_120MM_LG40_SG10\B12_BN218_01_035_120MM_LG40_SG10_20160926_15562904_header')
% 
close all
% B12 BN218 02 0
%ctrlScan.start('G:\218_02\B12_BN218_02_001_120mm_LG40_SG05_8TX0\B12_BN218_02_001_120mm_LG40_SG05_8TX0_20161212_13444190_header')
%ctrlScan.start('G:\218_02\B12_BN218_02_001_120mm_LG40_SG10_8TX0\B12_BN218_02_001_120mm_LG40_SG10_8TX0_20161212_13441876_header')
%ctrlScan.start('G:\218_02\B12_BN218_02_003_120mm_LG40_SG05_8TX0\B12_BN218_02_003_120mm_LG40_SG05_8TX0_20161212_13582799_header')
%ctrlScan.start('G:\218_02\B12_BN218_02_003_120mm_LG40_SG10_8TX0\B12_BN218_02_003_120mm_LG40_SG10_8TX0_20161212_13575831_header')

% B12 BN218 03 
%ctrlScan.start('G:\data\scan\transducer\218_03\B12_BN218_03_001_120MM_LG40_SG05_8TX0\B12_BN218_03_001_120MM_LG40_SG05_8TX0_20161221_12250488_header')
%ctrlScan.start('G:\218_03\B12_BN218_03_001_120MM_LG40_SG10_8TX0\B12_BN218_03_001_120MM_LG40_SG10_8TX0_20161221_12243558_header')
%ctrlScan.start('G:\218_03\B12_Bn218_03_003_120MM_LG40_SG05_8TX0\B12_Bn218_03_003_120MM_LG40_SG05_8TX0_20161221_12404869_header')
%ctrlScan.start('G:\218_03\B12_Bn218_03_003_120MM_LG40_SG10_8TX0\B12_Bn218_03_003_120MM_LG40_SG10_8TX0_20161221_12392047_header')
 
% % B12 BN218 04
%ctrlScan.start('G:\218_04\B12_BN218_04_001_120MM_LG40_SG05_8TX0\B12_BN218_04_001_120MM_LG40_SG05_8TX0_20161221_13091706_header')
%ctrlScan.start('G:\218_04\B12_BN218_04_001_120MM_LG40_SG10_8TX0\B12_BN218_04_001_120MM_LG40_SG10_8TX0_20161221_13070320_header')
%ctrlScan.start('G:\218_04\B12_BN218_04_002_120MM_LG40_SG05_8TX0\B12_BN218_04_002_120MM_LG40_SG05_8TX0_20161221_13232354_header')
%ctrlScan.start('G:\218_04\B12_BN218_04_002_120MM_LG40_SG10_8TX0/B12_BN218_04_002_120MM_LG40_SG10_8TX0_20161221_13215671_header')
%ctrlScan.start('G:\218_04\B12_BN218_04_003_120MM_LG40_SG05_8TX0/B12_BN218_04_003_120MM_LG40_SG05_8TX0_20161221_13391597_header')
%ctrlScan.start('G:\218_04\B12_BN218_04_003_120MM_LG40_SG10_8TX0/B12_BN218_04_003_120MM_LG40_SG10_8TX0_20161221_13374862_header')

% BN3
%ctrlScan.start('G:\B12_BN3\B12_BN3_120MM_LG40_SG05_8TX0_20170103_14585761_header');

% B12 BN218 03
%ctrlScan.start('G:\data\scan\transducer\04012017\B12_BN218_03_001_120MM_LG40_SG05_8TX0\B12_BN218_03_001_120MM_LG40_SG05_8TX0_20170103_15524240_header')
%ctrlScan.start('G:\data\scan\transducer\04012017\B12_BN218_03_003_120MM_LG40_SG05_8TX0\B12_BN218_03_003_120MM_LG40_SG05_8TX0_20170104_09253575_header')
% B12 BN218 02 
%ctrlScan.start('G:\data\scan\transducer\04012017\B12_BN218_02_001_120MM_LG40_SG05_8TX0\B12_BN218_02_001_120MM_LG40_SG05_8TX0_20170104_11232504_header')
%ctrlScan.start('G:\data\scan\transducer\04012017\B12_BN218_02_003_120MM_LG40_SG05_8TX0\B12_BN218_02_003_120MM_LG40_SG05_8TX0_20170104_13131014_header')
% B12 BN218 01
%ctrlScan.start('G:\data\scan\transducer\04012017\B12_BN218_01_014_120MM_LG40_SG05_8TX0\B12_BN218_01_014_120MM_LG40_SG05_8TX0_20170104_13263048_header')
%ctrlScan.start('G:\data\scan\transducer\04012017\B12_BN218_01_017_120MM_LG40_SG05_8TX0\B12_BN218_01_017_120MM_LG40_SG05_8TX0_20170104_13405540_header')

%file 40 index 45
%%
ctrlScan.pr(11:end) = [];
medianNoise = median([ctrlScan.pr(:).noiseMean])
meanNoise = mean([ctrlScan.pr(:).noiseMean])
%%
dbAboveNoise = zeros(1, length(ctrlScan.pr));

for index = 1:length(ctrlScan.pr)
    dbAboveNoise(index) = mean(ctrlScan.pr(index).peakDB) - medianNoise;
end

%
[dbAboveNoise]'
medianDbAboveNoise = median(dbAboveNoise)
meanDbAboveNoise = mean(dbAboveNoise)
%

%psdMain(psdIndex,:) = mean([ctrlScan.pr(:).psdMain]');
%psdResonance(psdIndex,:) = mean([ctrlScan.pr(:).psdResonance]');

%psdMain2(psdIndex,:) = ctrlScan.pr(1).psdMain;
%psdResonance2(psdIndex,:) = ctrlScan.pr(1).psdResonance;

psdMain = mean([ctrlScan.pr(:).psdMain]');
psdMain2 = ctrlScan.pr(1).psdMain;
psdResonance = mean([ctrlScan.pr(:).psdResonance]');



%%
figure
plot(ctrlScan.pr(1).fMain,[psdMain])
hold on
plot(ctrlScan.pr(1).fMain,[psdMainBNLab03Latest_LG40_SG05])
title('Psd Main')
grid on
legend('BN218 01 017','BN lab 3 LG40 SG05 latest')
title('BN218 01 017 LG40 SG05')


%psdIndex = psdIndex + 1
%plot(mean([ctrlScan.pr(:).psdResonance]'))
%%
figure
mesh([psdResonance])
figure
%mesh([psdResonance2])
mesh([psdMain])

%%
figure
SG_axis = [0.2 0.5 1.0 1.5 1.8 2.5];
LG_legend = {'LG 4.0', 'LG 7.2', 'LG 8.0', 'LG 10.0', 'LG 12.0','Location','northwest'}; 
for index = 1:5;%length(SGLG_320);
    plot(SG_axis, SGLG_100_mean_fized_res_start(:,index))
    hold on    
end
grid on
legend('LG 4.0', 'LG 7.2', 'LG 8.0', 'LG 10.0', 'LG 12.0','Location','northwest'); 
xlabel('SG setting')
ylabel('dB')
title('Position 100 intact, median over 10 shots. Res fixed pos')

%legend(LG_axis)
%% Testing transducerTestScript

folder = 'G:\data\scan\transducer\04012017';
folderToSaveFig = 'C:\Users\Processing PC 01\Documents\MATLAB\matlab\figures\transducer measurment\batch 5';

res = transducerTest(ctrlScan, folder, psdMainBNLab03Latest_LG40_SG05, folderToSaveFig);





