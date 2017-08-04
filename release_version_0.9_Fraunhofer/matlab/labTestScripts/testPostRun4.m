clear all
%%
%close all
import ppPkg.*
im = ImportHandler

%%


%header = im.readHeader('E:/LabSystem_Data/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm_20160629_09485329_header');


% Comparing signal, sinc, chirp and rect-chirp at z: 83
%header = im.readHeader('recording/Wfm_Calliper_Analysis/SingleShot_Plate_16mm_sinc_300k_3500k_Z83cm/SingleShot_Plate_16mm_sinc_300k_3500k_Z83cm_20160628_10043126_header');
%header = im.readHeader('recording/Wfm_Calliper_Analysis/SingleShot_Plate_16mm_chirp_300k_3800k_30us_Z83cm/SingleShot_Plate_16mm_chirp_300k_3800k_30us_Z83cm_20160628_10051246_header');
%header = im.readHeader('recording/Wfm_Calliper_Analysis/SingleShot_Plate_16mm_rectchirp_300k_3800k_30us_Z83cm/SingleShot_Plate_16mm_rectchirp_300k_3800k_30us_Z83cm_20160628_10055529_header');

% Comparing signal, sinc, chirp and rect-chirp at z: 50, 80, 120
% chirp
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Chirp_300k_3800k_26_7u_Z50mm/B16_01_SEC01_Chirp_300k_3800k_26_7u_Z50mm_20160624_09440649_header');
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Chirp_300k_3800k_26_7u_Z80mm/B16_01_SEC01_Chirp_300k_3800k_26_7u_Z80mm_20160624_10055079_header');
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Chirp_300k_3800k_26_7u_Z120mm/B16_01_SEC01_Chirp_300k_3800k_26_7u_Z120mm_20160624_10182008_header');
% rect-chirp
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Rect_Chirp_300k_3800k_26_7u_Z50mm/B16_01_SEC01_Rect_Chirp_300k_3800k_26_7u_Z50mm_20160624_09533532_header');
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Rect_Chirp_300k_3800k_26_7u_Z80mm/B16_01_SEC01_Rect_Chirp_300k_3800k_26_7u_Z80mm_20160624_10081696_header');
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Rect_Chirp_300k_3800k_26_7u_Z120mm/B16_01_SEC01_Rect_Chirp_300k_3800k_26_7u_Z120mm_20160624_10205312_header');
% sinc
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Sinc_300k_3700k_26_7u_Z50mm/B16_01_SEC01_Sinc_300k_3700k_26_7u_Z50mm_20160624_09411320_header');
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Sinc_300k_3700k_26_7u_Z80mm/B16_01_SEC01_Sinc_300k_3700k_26_7u_Z80mm_20160624_10021708_header');
%header = im.readHeader('recording/B16_01_SEC01_variable_pulse_distance/B16_01_SEC01_Sinc_300k_3700k_26_7u_Z120mm/B16_01_SEC01_Sinc_300k_3700k_26_7u_Z120mm_20160624_10141900_header');

% Comparing signal in pipe
% chirp
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z50mm/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z50mm_2_20160624_13444413_header');
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z80mm/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z80mm_2_20160624_13511972_header');
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z120mm/PIPE_SEC_center_line_scan_130mm_chirp_300k_3800k_26_7u_Z120mm_2_20160624_13565982_header');
% rect-chirp
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z50mm/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z50mm_2_20160624_13460167_header');
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z80mm/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z80mm_2_20160624_13523939_header');
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z120mm/PIPE_SEC_center_line_scan_130mm_rect_chirp_300k_3800k_26_7u_Z120mm_2_20160624_13584176_header');
% sinc
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z50mm/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z50mm_2_20160624_13425177_header');
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z80mm/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z80mm_2_20160624_13494981_header');
%header = im.readHeader('E:/LabSystem_Data/PIPE_SEC/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z120mm/PIPE_SEC_center_line_scan_130mm_sinc_300k_3700k_26_7u_Z120mm_2_20160624_13553352_header');


% Analyzing square waves
%header = im.readHeader('E:/LabSystem_Data/Square_Analysis/rect_chirp_300k_3800k/SquareAnalysis_rect_chirp_300k_3800k_20160623_12523372_header');
%header = im.readHeader('E:/LabSystem_Data/Square_Analysis/rect_0_5us_400L.txt/rect_0_5us_400L.txt_20160623_12311355_header');
%header = im.readHeader('E:/LabSystem_Data/Square_Analysis/rect_1us_400L.txt/rect_1us_400L.txt_20160623_12315542_header');
%header = im.readHeader('E:/LabSystem_Data/Square_Analysis/rect_2us_400L.txt/rect_2us_400L.txt_20160623_12320779_header');
%header = im.readHeader('E:/LabSystem_Data/Square_Analysis/rect_4us_400L.txt/rect_4us_400L.txt_20160623_12322024_header');
%header = im.readHeader('E:/LabSystem_Data/Square_Analysis/rect_5us_400L.txt/rect_5us_400L.txt_20160623_12323157_header');
%header = im.readHeader('E:/LabSystem_Data/Square_Analysis/rect_10us_400L.txt/rect_10us_400L.txt_20160623_12324182_header');

% Single shot plate
%header = im.readHeader('recording/SingleShot_Plate_2mm_Chirp_300k_3800k_60u/SingleShot_Plate_2mm_Chirp_300k_3800k_60u_20160620_12330115_header');
%header = im.readHeader('recording/SingleShot_Plate_2mm_Chirp_300k_3800k_30u/SingleShot_Plate_2mm_Chirp_300k_3800k_30u_20160620_12341420_header');
%header = im.readHeader('recording/SingleShot_Plate_2mm_Chirp_300k_3800k_20u/SingleShot_Plate_2mm_Chirp_300k_3800k_20u_20160620_12343631_header');
%header = im.readHeader('recording/SingleShot_Plate_2mm_Chirp_300k_3800k_10u/SingleShot_Plate_2mm_Chirp_300k_3800k_10u_20160620_12350093_header');

% Testing with 30us chirp on half plate
%header = im.readHeader('E:/LabSystem_Data/Scan_Half_Plate_16mm_Chirp_300k_3800k_30u/Scan_Half_Plate_16mm_Chirp_300k_3800k_30u_20160620_12474370_header');
% 30 us with 8 cm Z
%header = im.readHeader('E:/LabSystem_Data/reScan_Half_Plate_16mm_Chirp_300k_3800k_30u_Z8cm/reScan_Half_Plate_16mm_Chirp_300k_3800k_30u_Z8cm_20160622_10143861_header');

% Testing with 60us chirp on half plate
%header = im.readHeader('E:/LabSystem_Data/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');

% Testing rect pulse train
%header = im.readHeader('recording/SingleShot_rect_1w_400L_Z8cm/SingleShot_rect_1w_400L_Z8cm_20160623_09501972_header');
%header = im.readHeader('recording/SingleShot_rect_2w_400L_Z8cm/SingleShot_rect_2w_400L_Z8cm_20160623_09503628_header');

% Testing different sampling rate
%header = im.readHeader('E:/LabSystem_Data/16062016/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_15M/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_15M_20160616_14052069_header');
%header = im.readHeader('E:/LabSystem_Data/16062016/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_10M/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_10M_20160616_14083448_header');
%header = im.readHeader('E:/LabSystem_Data/16062016/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_5M/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_5M_20160616_14113862_header');


%header = im.readHeader('recording/sinc_scan/sinc_scan_20160530_13200335_header');

%header = im.readHeader('recording/31052016/Scan_Plate_16mm_Chirp_500k_3800K_20160531_12551842_header');

%header = im.readHeader('E:/LabSystem_Data/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');

%header = im.readHeader('E:/LabSystem_Data/16062016/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_15M/LineScan_Plate_16mm_Chirp_300k_3800k_SamplingRate_15M_20160616_14052069_header');

%header = im.readHeader('H:/LabSystem_Data/Scan_Pipe_10mm_Chirp_500k_3800k/Scan_Pipe_10mm_Chirp_500k_3800k_20160602_15084630_header');
%header = im.readHeader('H:/LabSystem_Data/06062016/pipe_chirp_z5000_u1850_grounded_rod/pipe_chirp_z5000_u1850_grounded_rod_20160606_10140766_header');
%header = im.readHeader('H:/LabSystem_Data/06062016/pipe_sinc_1M_3M7_z5000_u1850_rod_grounded/pipe_sinc_1M_3M7_z5000_u1850_rod_grounded_20160606_12330547_header');
%header = im.readHeader('H:/LabSystem_Data/06062016/pipe_chirp_z5000_u1850_nylon_rod/pipe_chirp_nylon_rod_z5000_u1850_20160606_14070704_header');
%header = im.readHeader('H:/LabSystem_Data/07062016/pipe_rotated_z30000_u200000_dz1000_du370/pipe_rotated_z30000_u200000_dz1000_du370_20160607_09161087_header');

%header = im.readHeader('E:/LabSystem_Data/07062016/pipe_50mm_z90000_u2_dz1000_du1/pipe_50mm_z90000_u2_dz1000_du1_20160607_14393424_header');
%header = im.readHeader('E:/LabSystem_Data/07062016/pipe_75mm_z90000_u2_dz1000_du1/pipe_75mm_z90000_u2_dz1000_du1_20160607_14423568_header');
%header = im.readHeader('E:/LabSystem_Data/07062016/pipe_100mm_z90000_u2_dz1000_du1/pipe_100mm_z90000_u2_dz1000_du1_20160607_14452891_header');
%header = im.readHeader('E:/LabSystem_Data/07062016/pipe_125mm_z90000_u2_dz1000_du1/pipe_125mm_z90000_u2_dz1000_du1_20160607_14550809_header');
%header = im.readHeader('E:/LabSystem_Data/07062016/pipe_150mm_z90000_u2_dz1000_du1/pipe_150mm_z90000_u2_dz1000_du1_20160607_15002158_header');

% DIO test
%header = im.readHeader('recording/Dio_Test/B16_01_T130_T025_Line_Chirp_300k_3800k_30u/B16_01_T130_T025_Line_Chirp_300k_3800k_30u_20160705_11425049_header');
%header = im.readHeader('recording/Dio_Test/B16_01_T130_T025_Line_Chirp_300k_3800k_30u_SwitchGain/B16_01_T130_T025_Line_Chirp_300k_3800k_30u_SwitchGain_20160705_11405140_header');

% Improved noise reduction
%header = im.readHeader('E:/LabSystem_Data/B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm/B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm_20160706_08241336_header');

% Single shot on 2 mm plate
%header = im.readHeader('E:/LabSystem_Data/SingleShot_Plate_2mm_Chirp_300k_3800k_60u/SingleShot_Plate_2mm_Chirp_300k_3800k_60u_20160620_12330115_header')
%header = im.readHeader('E:/LabSystem_Data/SingleShot_Plate_2mm_Chirp_300k_3800k_30u/SingleShot_Plate_2mm_Chirp_300k_3800k_30u_20160620_12341420_header')
%header = im.readHeader('E:/LabSystem_Data/SingleShot_Plate_2mm_Chirp_300k_3800k_20u/SingleShot_Plate_2mm_Chirp_300k_3800k_20u_20160620_12343631_header')
%header = im.readHeader('E:/LabSystem_Data/SingleShot_Plate_2mm_Chirp_300k_3800k_10u/SingleShot_Plate_2mm_Chirp_300k_3800k_10u_20160620_12350093_header')

%header = im.readHeader('E:/LabSystem_Data/B16_01_SEC01_Chirp_300k_3800k_30u_Z120mm_Back/B16_01_SEC01_Chirp_300k_3800k_30u_Z120mm_Back_20160701_08233889_header')
% High Gain
%header = im.readHeader('D:\scan\12072016\B16_01_SEC01_Chirp_300k_3800k_30u_z120_RX_REV2_MATCH2_50u_HighGain20dB_20160712_15592207/B16_01_SEC01_Chirp_300k_3800k_30u_z120_RX_REV2_MATCH2_50u_HighGain20dB_20160712_15351921_header')
%header = im.readHeader('D:\scan\22072016\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z50mm\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z50mm_20160722_07101103_header')
%header = im.readHeader('D:\scan\21072016\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z120mm\B12_01_SEC01_Chirp_ 300k_3800k_30us-pulse_RX_REV2A_M2_30u_HighGain_20db_Z120mm_20160721_10102196_header')

%header = im.readHeader('D:\scan\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm_20160706_08241336_header')
%header = im.readHeader('D:\scan\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_20160804_15250327_header')
%header = im.readHeader('D:\scan\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SLOW_8MM_PITTING\B12_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SLOW_8MM_PITTING_20160805_11283763_header');

%header = im.readHeader('D:\scan\B10_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SPEED_2000\B10_01_Chirp_ 300k_3800k_30us_RX_REV1B_Z80_SPEED_2000_20160805_13230479_header');

%header = im.readHeader('D:\scan\31052016\Scan_Plate_16mm_Chirp_500k_3800K_20160531_12551842_header');

%header = im.readHeader('D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');
% Compare shots with new electronics 15.8
%header = im.readHeader('D:\scan\Test_scan_TR1_with_RXA_and_TXA_at_16mm_plate_120mm_distance\B16_01_Chirp_ 300k_3800k_30us_TXA_RXA_REV1_TR1_SCAN_TEST_20160815_14025216_header')
%header = im.readHeader('D:\scan\B16_01_SEC01_Chirp_300k_3800k_30u_Z120mm_Back\B16_01_SEC01_Chirp_300k_3800k_30u_Z120mm_Back_20160701_08233889_header')

%header = im.readHeader('D:\scan\Scan_Half_Plate_16mm_Chirp_300k_3800k_30u_Z12cm\Scan_Half_Plate_16mm_Chirp_300k_3800k_30u\Scan_Half_Plate_16mm_Chirp_300k_3800k_30u_20160620_12474370_header');


%header = im.readHeader('D:\scan\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000_20160819_14365710_header')
%header = im.readHeader('D:\scan\pipe_sec01_RX1A_TX1A_z100_u100_dz1_du037_wd_70mm\pipe_sec01_RX1A_TX1A_z100_u100_dz1_du037_wd_70mm_20160822_10013506_header');
%header = im.readHeader('D:\scan\pipe\26082016\pipe_sec01_8chRXCH0_LG40_SG18_TX1A_z100_u200_dz1_du037_wd_70mm\pipe_sec01_8chRXCH0_LG40_SG18_TX1A_z100_u200_dz1_du037_wd_70mm_20160826_13321604_header');
%header = im.readHeader('D:\scan\pipe\26082016\pipe_sec01_8chRXCH0_LG40_SG18_TX1A_z100_u200_dz1_du037_wd_70mm\pipe_sec01_8chRXCH0_LG40_SG18_TX1A_z100_u200_dz1_du037_wd_70mm_20160826_13321604_header');

%header = im.readHeader('D:\scan\B14_01_vertical_sec1_8chRXCH0_LG80_SG18_TX1A_z100_y350_dz1_dy1_dist600\B14_01_vertical_sec1_8chRXCH0_LG80_SG18_TX1A_z100_y350_dz1_dy1_dist600_20160831_15240833_header');

%header = im.readHeader('D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000_20160819_14365710_header');

%header = im.readHeader('D:\scan\pipe\06092016\pipe_pos100_sg10_lg80\pipe_pos100_sg10_lg80_20160906_10361404_header');
%header = im.readHeader('D:\scan\pipe\06092016\pipe_pos100_sg15_lg40\pipe_pos100_sg15_lg40_20160906_10414371_header')
%header = im.readHeader('D:\scan\pipe\06092016\pipe_pos100_sg15_lg72\pipe_pos100_sg15_lg72_20160906_10462123_header')
%header = im.readHeader('D:\scan\pipe\06092016\pipe_pos100_sg15_lg80\pipe_pos100_sg15_lg80_20160906_10363436_header')
%header = im.readHeader('D:\scan\pipe\06092016\pipe_pos100_sg15_lg100\pipe_pos100_sg15_lg100_20160906_10505816_header')
%header = im.readHeader('D:\scan\pipe\06092016\pipe_pos100_sg15_lg120\pipe_pos100_sg15_lg120_20160906_10554033_header')

%header = im.readHeader('D:\scan\pipe\pipe_sec01_8chRXCH0_LG120_SG18_TX1A_z100_u200_dz1_du037_wd_70mm\pipe_sec01_8chRXCH0_LG120_SG18_TX1A_z100_u200_dz1_du037_wd_70mm_20160830_15471855_header');

%header = im.readHeader('D:\scan\transducer\BN218_01_012_14MM_100MM_RXGAIN_4_SG1\BN218_01_012_14MM_100MM_RXGAIN_4_SG1_20160923_10373993_header')

%header = im.readHeader('D:\scan\transducer\B14_BN218_01_012_120MM_LG40_SG10\B14_BN218_01_012_120MM_LG40_SG10_20160923_10525647_header');
%header = im.readHeader('D:\scan\B14\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm\B14_01_SEC01_Chirp_300k_3800k_30u_Z120mm_20160706_08241336_header');
%header = im.readHeader('D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000_20160819_14365710_header');

%header = im.readHeader('D:\scan\transducer\26092016\B12_BN218_01_017_120MM_LG40_SG10\B12_BN218_01_017_120MM_LG40_SG10_20160926_12511418_header')
%header = im.readHeader('D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header')

%header = im.readHeader('D:\scan\B16\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm\B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm_20160629_15454786_header')

%header = im.readHeader('D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');
%header = im.readHeader('D:\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z200_SPEED_2000_20160820_22593037_header');
%header = im.readHeader('../recording/B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z240mm_20160629_15454786_header');

%header = im.readHeader('../recording/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1/Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header', );
%header = im.readHeader('../recording/31052016/Scan_Plate_16mm_Chirp_500k_3800K_20160531_12551842_header');
%header = im.readHeader('../recording/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm/B16_01_SEC01_Chirp_300k_3800k_30u_Z300mm_20160629_09485329_header');

%header = im.readHeader('D:\scan\hydrophone_scans\freq_sweep_B016_346mm_0deg0_bn218_01_018_LC_out\freq_sweep_B016_346mm_0deg0_bn218_01_018_LC_out_20161019_13260834_header');
%header = im.readHeader('D:\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4_20161019_14345389_header');
%header = im.readHeader('D:\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10_20161020_15202104_header');
%header = im.readHeader('D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');

%header = im.readHeader('../dataFromLab/B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4/B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_8rx_lg4_20161019_14345389_header');

%header = im.readHeader('D:\scan\B16\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1\Scan_Plate_16mm_Chirp_300k_3800k_x470_y320_dx1_dy1_20160615_08203626_header');
%header = im.readHeader('/Volumes/Samsung_T3/218_02/B12_BN218_02_001_120mm_LG40_SG05_8TX0/B12_BN218_02_001_120mm_LG40_SG05_8TX0_20161212_13444190_header');


%batch 2
%header = im.readHeader('G:\218_02\B12_BN218_02_001_120mm_LG40_SG05_8TX0\B12_BN218_02_001_120mm_LG40_SG05_8TX0_20161212_13444190_header')
%header = im.readHeader('G:\218_02\B12_BN218_02_001_120mm_LG40_SG10_8TX0\B12_BN218_02_001_120mm_LG40_SG10_8TX0_20161212_13441876_header')
%header = im.readHeader('G:\218_02\B12_BN218_02_003_120mm_LG40_SG05_8TX0\B12_BN218_02_003_120mm_LG40_SG05_8TX0_20161212_13582799_header')
%header = im.readHeader('G:\218_02\B12_BN218_02_003_120mm_LG40_SG10_8TX0\B12_BN218_02_003_120mm_LG40_SG10_8TX0_20161212_13575831_header')

% batch 4
%header = im.readHeader('G:\218_04\B12_BN218_04_001_120MM_LG40_SG05_8TX0\B12_BN218_04_001_120MM_LG40_SG05_8TX0_20161221_13091706_header');

%header = im.readHeader('G:\data\scan\hydrophone_scans\09012017\HYPH_BN3_120MM_LG40_SG05_8TX0_TTF17\HYPH_BN3_120MM_LG40_SG05_8TX0_TTF17_20170109_13295416_header');
%header = im.readHeader('G:\data\scan\hydrophone_scans\12012017\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L4\HYPH_BN218_03_001_120MM_LG40_SG05_8TX0_L4_20170112_14190434_header');

%header = im.readHeader('D:\scan\transducer\26092016\B12_BN218_01_034_120MM_LG40_SG10\B12_BN218_01_034_120MM_LG40_SG10_20160926_14184075_header');
%header = im.readHeader('G:\data\scan\B16\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10\B16_01_SEC01_vert_chirp_d346_y340_z100_dy1_dz1_bn218_01_18_8tx_lc_out_lg4_sg10_20161021_10010297_header');
header = im.readHeader('G:\data\scan\pipe\pipe_sec01_out_8chRXCH0_LG80_SG18_TX1A_z100_u115_dz1_du0370_wd_70mm/pipe_sec01_out_8chRXCH0_LG80_SG18_TX1A_z100_u115_dz1_du0370_wd_70mm_20160905_10284244_header');
%header = im.readHeader('G:\data\scan\B14\B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000/B14_Chirp_ 300k_3800k_30us_TXA_TUNED_RX_REV1A_Z80_SPEED_2000_20160819_14365710_header');

%im.readFolder('D:\fromBlueNoseFtp\Flowloop_Test\24D_test')
        

%% Create object instances for controller and algorithms


transducerId = 1;
ctrl = Controller;

ctrl.config.SAMPLE_RATE = header.sampleRate;

%callipAlg = CalliperAlgorithm(ctrl.config);
%thicknessAlg = ThicknessAlgorithm(ctrl.config);

% Set configuration parameters
ctrl.config.FFT_LENGTH = 4096;

ctrl.config.D_MIN = 0.0018;
ctrl.config.D_NOM = 0.0145;
ctrl.config.NUMBER_OF_CHANNELS = 96;

%noiseAlg = Noise(ctrl.config);

%% Create tx pulse
%
s = SignalGenerator(lower(im.header.pulsePattern), ...
                    im.header.sampleRate, ...
                    im.header.pulseLength/im.header.sampleRate, ...
                    im.header.fLow, ...
                    im.header.fHigh)
txPulse = s.signal;
plot(s.time, s.signal)
grid on



%%
%  dataFileIndex = 475 for plate line plot
% Select file to read from 

im.dataFileIndex = 50;
tmIndex = 23%397%128;
%tic
tmArr = im.importDataFile();
%toc
im.dataFileIndex
%%


tm = tmArr(tmIndex);
tmIndex = tmIndex +1;


recordedSignal = tm.signal;

%figure
plot(recordedSignal)
grid on
% subplot(2,1,1)
% plot(recordedSignal)
% grid on
% subplot(2,1,2)
% plot(recordedSignalFilt)
% grid on

%
    
%% Calculate Calliper
% Set transmitted pulse
ctrl.callipAlg.setTxPulse(txPulse);

% Start searching at index 1000, after leak from transducer
delay = 0;

% Calculate time in number of samples before recording is started
deltaTimeBeforeRecordingIsStarted = (tm.startTimeRec)% *tm.sampleRate;
[distance, firstReflectionStartIndex, secondReflectionStartIndex, pitDept] = ctrl.callipAlg.calculateDistance( delay, recordedSignal, double(deltaTimeBeforeRecordingIsStarted));
pitDept                                   
%
% Distance based on measuring time between 1. and 2. reflection
%distance2 = ((secondReflectionStartIndex - firstReflectionStartIndex)*ctrl.config.V_WATER)/(2*tm.sampleRate);

if(distance < 0)
    error('Outside plate')
    return
end

%% Noise calculation
% NOTE: Nor now: Need to verify that the start index for noise calculation is
% correct.
noiseSignal = tm.signal((length(txPulse)*2+100):firstReflectionStartIndex-200);

%
% Enable / Disable use of transducer sensitivity
enableTS = false;
enableTS_noise = false;

% Noise PSD calculation: Using pWelch or periodogram
[psdNoise, fNoise] = ctrl.noiseAlg.calculatePsd(transducerId, noiseSignal, enableTS_noise, 'periodogram', 'hanning', 400);

% Plot Noise PSD
ctrl.noiseAlg.plotPsd(transducerId);
%
% Calculate mean and var for range [fLow, fHigh]
[meanValue, varValue] = ctrl.noiseAlg.calculateMeanVarInRange(transducerId, tm.fLow, tm.fHigh)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanValue = -141;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% Calculate psdMain and psdResonance
pulseLength = length(txPulse);
ctrl.config.NOMINAL_DISTANCE_TO_WALL = 0.35;  % Can use result from calliper
ctrl.config.ADJUST_START_TIME_RESONANCE = 0;
ctrl.config.ADJUST_STOP_TIME_RESONANCE =  0;
ctrl.config.WINDOW_RESONANCE = 'hanning';
ctrl.config.WINDOW_MAIN = 'rect'; 
ctrl.config.USE_PWELCH = true
ctrl.config.MAX_WELCH_LENGTH = 800;
ctrl.config.PERIODOGRAM_OVERLAP = 0.50;
ctrl.config.PERIODOGRAM_SEGMENT_LENGTH = 500;
ctrl.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;

ctrl.thicknessAlg.fLow = tm.fLow;
ctrl.thicknessAlg.fHigh = tm.fHigh;

if(false == ctrl.thicknessAlg.calculateStartStopForAbsorptionAndResonance(recordedSignal, ctrl.callipAlg))
    error('Error in calculating start and stop index for resonance')
end

%
ctrl.config.TS_ADJUST_ENABLE = false;
ctrl.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;

ctrl.thicknessAlg.calculatePsd(recordedSignal);
% Plot psd
ctrl.thicknessAlg.plotPsd(recordedSignal);

%% Plot Periodogram segments
thicknessAlg.plotPeriodogramSegments(recordedSignal);

%%
% Using mean level above noise floor in range [fLow, fHigh]. 
% Can consider using level above noisePsd(f).
ctrl.thicknessAlg.meanNoiseFloor = meanValue;%noiseAlg.meanPsd(1);
% Override frequency range by setting fLow or fHigh.
fLow = 0.8e6%tm.fLow;
fHigh = 4e6%;tm.fHigh;
ctrl.config.Q_DB_ABOVE_NOISE = 20;
ctrl.config.Q_DB_MAX = 10;
ctrl.config.PROMINENCE = 7;

tic
% Find peaks
ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, fLow, fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);
toc

% Plot peaks
ctrl.thicknessAlg.plotPsdPeaks(ctrl.thicknessAlg.RESONANCE);

%% Resonance Part: Find all harmonic sets
ctrl.config.DEVIATION_FACTOR = (ctrl.config.FFT_LENGTH/ctrl.config.SAMPLE_RATE) * (ctrl.config.SAMPLE_RATE/ctrl.config.PERIODOGRAM_SEGMENT_LENGTH) * 1;
requiredNumberOfHarmonicsInSet = 2;

% Find sets
tic
ctrl.thicknessAlg.findFrequencySets(ctrl.thicknessAlg.RESONANCE, fLow, fHigh, requiredNumberOfHarmonicsInSet);
%

set = ctrl.thicknessAlg.setResonance
toc
%% Process sets   

ctrl.thicknessAlg.processSets(ctrl.thicknessAlg.RESONANCE, ctrl.noiseAlg.psd(transducerId)) ;
set = ctrl.thicknessAlg.setResonance


%% Find set with probably correct thickness

tic
[setC] = ctrl.thicknessAlg.findBestSetE(set)
toc
close all
ctrl.thicknessAlg.plotAllSets('resonance', setC)

%% If setC is of class D check if there is a set that have a better class A
tic
 
  setsWithMaxSize = thicknessAlg.findSetWithMostHarmonics( set);  
  %[setWithHighestPeakEnergy] = thicknessAlg.findSetWithHighestAveragePeakEnergy(set)
toc
%%
[setsWithMaxSubsetScore, setIndex] = thicknessAlg.findSetWithHighestSubsetScore(set)

%%
%close all
thicknessAlg.plotAllSets('resonance', setC)


%%

close all
thicknessAlg.plotAllSets('resonance')

%% Notes
find([ctrlScan.pr(30:503).class] == 'B')

%%
tic
setClass = thicknessAlg.findSetClass( 'A', set )
toc

%%
tic
remainSet = thicknessAlg.removeAllSubsets(set)
toc


%%
if(1)
% Try alternative method, find set based on highest peak average energy
    remainSet = thicknessAlg.removeAllSubsets(set);                        
    setCandidate = thicknessAlg.findSetWithHighestAveragePeakEnergy(remainSet);    
    thicknessAlg.resonanceSet = remainSet;
end
%%
thicknessAlg.resonanceSet = remainSet;
% Find the best set
[setC, setsWithMaxSize,setsWithEstimatedThickness] = thicknessAlg.findBestSetD(remainSet, set);

%% DONT USE: Remove subsets
set = thicknessAlg.removeAllSubsets(set);
thicknessAlg.set = allSet;
RemainingSets = length(set)
set

%%
%%
[count, setIndex] = thicknessAlg.findNumberOfSetsWithThickness( 0.004929, set, 5)
%%
classArray = [set(:).class];
setsWithClassA = find(classArray == 'A')
%thicknessAlg.set = set
%%
close all
thicknessAlg.plotAllSets('resonance', setIndex)

%% Return location for all peaks
locsToRemove = unique([set([setIndex]).psdIndexArray]);
% Remove locsToRemove from locs
locsToSeach = setxor(locs, locsToRemove');
%% Resonance Part: Find all harmonic sets 
ctrl.config.DEVIATION_FACTOR = 4;

% Find sets
thicknessAlg.findFrequencySetsFromHighAndLow('resonance', psdResonance, locsToSeach, fLow, fHigh);

% Calculate validation parameters
set = thicknessAlg.calculateSetThickness(thicknessAlg.resonanceSet);
set = thicknessAlg.calculateSetValidationParameters(thicknessAlg.resonanceSet, fLow, fHigh, noiseAlg.psd(transducerId) );
%%
set = thicknessAlg.removeInvalidSets(thicknessAlg.resonanceSet, ctrl.config.D_MIN, ctrl.config.D_NOM*1.1);
%set = thicknessAlg.removeInvalidSets(thicknessAlg.resonanceSet, 0.0055, 0.0065);
thicknessAlg.resonanceSet = set;
allSet = set
%%
[count, setIndex] = thicknessAlg.findNumberOfSetsWithThickness( (ctrl.config.D_NOM-pitDept), set, 10)
%% Plotting functions

close all

% Plot all sets
thicknessAlg.plotAllSets('resonance', setIndex)

% Plot all sets with a given class
%thicknessAlg.plotAllSets('resonance')

% Plot given sets, based on index
%thicknessAlg.plotAllSets('resonance')

%% PSD MAIN version 2
% Using mean level above noise floor in range [fLow, fHigh]. 
% Can consider using level above noisePsd(f).

thicknessAlg.meanNoiseFloor = 0;%noiseAlg.meanPsd(1);
% Override frequency range by setting fLow or fHigh.
fLowMain = 1e6;%tm.fLow;
fHighMain = 3.4e6;
ctrl.config.Q_DB_ABOVE_NOISE = 10;
ctrl.config.Q_DB_MAX = 10;
ctrl.config.PROMINENCE = 5;

% Find peaks
%thicknessAlg.findPeaksInPsd(thicknessAlg.MAIN, fLowMain, fHighMain, PeakMethod.N_HIGEST_PROMINENCE)
thicknessAlg.findPeaksInPsd(thicknessAlg.MAIN, fLowMain, fHighMain, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE)

% Keep only peaks that are larger than half of max peak prominence
% maxPeakProminence = max(thicknessAlg.peakProminenceMain);
% idxl = (thicknessAlg.peakProminenceMain > (maxPeakProminence/2));
% thicknessAlg.peakProminenceMain = thicknessAlg.peakProminenceMain(idxl);
% thicknessAlg.peakLocationMain = thicknessAlg.peakLocationMain(idxl);
% thicknessAlg.peakValueMain = thicknessAlg.peakValueMain(idxl);
% thicknessAlg.peakWidthMain = thicknessAlg.peakWidthMain(idxl);

% Plot peaks
thicknessAlg.plotPsdPeaks(thicknessAlg.MAIN);

% Find frequency sets
ctrl.config.DEVIATION_FACTOR = 4;
thicknessAlg.findFrequencySets(thicknessAlg.MAIN, fLow, fHigh, requiredNumberOfHarmonicsInSet);

%% Process set data
thicknessAlg.processSets(thicknessAlg.MAIN, fLowMain, fHighMain, noiseAlg.psd(transducerId)); 
thicknessAlg


tic
[setC] = thicknessAlg.findBestSetE(thicknessAlg.setMain)
toc

%% PSD MAIN version 1
% Using mean level above noise floor in range [fLow, fHigh]. 
% Can consider using level above noisePsd(f).
thicknessAlg.meanNoiseFloor = 0;%noiseAlg.meanPsd(1);
% Override frequency range by setting fLow or fHigh.
fLowMain = 1e6;%tm.fLow;
fHighMain = 3.0e6;
ctrl.config.Q_DB_ABOVE_NOISE = 10;
ctrl.config.Q_DB_MAX = 10;
ctrl.config.PROMINENCE = 5;

numberOfHarmonics = thicknessAlg.findNumberOfHarmonics(fLowMain, fHighMain)

psd = -psdMain;
[pks, locs, startIndex] = thicknessAlg.findPeaksInPsdAboveNoise(psd, fLowMain, fHighMain, 3);

figure
plot(fMain, psd,fMain(locs),pks,'o',fMain(startIndex),(psd(startIndex)),'*')
grid

%% Resonance Part: Find all harmonic sets
ctrl.config.DEVIATION_FACTOR = 4;
%thicknessAlg.findFrequencySetsFromHighAndLow('absorption',psdMain, locs, fLowMain, fHighMain, 3);

thicknessAlg.findFrequencySets(thicknessAlg.ABSORPTION, fLow, fHigh, requiredNumberOfHarmonicsInSet);

%% Calculate validation parameters
setMain = thicknessAlg.calculateSetValidationParameters(thicknessAlg.absorptionSet, fLowMain, fHighMain, noiseAlg.psd(transducerId) );
setMain = thicknessAlg.calculateSetThickness(thicknessAlg.absorptionSet);
setMain
setAll  = setMain

%% Remove invalid sets by using d_min and d_nominal (d_maxs)
setMain = thicknessAlg.removeInvalidSets(thicknessAlg.absorptionSet, ctrl.config.D_MIN, ctrl.config.D_NOM * 1.1);
thicknessAlg.absorptionSet = setMain;

%% Remove subsets
setRemain = thicknessAlg.removeAllSubsets2(setMain);

%%
[setCandidateMain, setsWithMaxSize] = thicknessAlg.findBestSetD(setRemain, setMain);

%% 
close all
%thicknessAlg.plotAllSets('absorption')
thicknessAlg.plotAllSets('absorption', setC)

%%
[count, setIndex] = thicknessAlg.findNumberOfSetsWithThickness( 0.00189, setMain, 5)

%%
classArray = [setMain(:).class];
setsWithClassA = find(classArray == 'A')
setCMain = thicknessAlg.findSetWithLowestAveragePeakEnergy(setMain, setsWithClassA)

%% 
%%
mainLength = thicknessAlg.endMain - thicknessAlg.beginMain;
mainSignal = recordedSignal(thicknessAlg.beginMain:(thicknessAlg.endMain-1));

% Window type should be taken from config
mainWindow = thicknessAlg.getWindow(thicknessAlg.config.WINDOW_MAIN, mainLength);

% Calculate PSD using periodogram
[psd, f] = periodogram(mainSignal, mainWindow, thicknessAlg.config.FFT_LENGTH, thicknessAlg.config.SAMPLE_RATE, 'power' );

close all
figure
subplot(2,1,1)
plot(mainSignal)
grid on
subplot(2,1,2)
plot(f,psd)
xlim([0 4e6])
grid on
%%
Y = fft( mainSignal,  thicknessAlg.config.FFT_LENGTH);
f = thicknessAlg.config.SAMPLE_RATE*(0:(thicknessAlg.config.FFT_LENGTH/2))/thicknessAlg.config.FFT_LENGTH;
P = abs(Y/thicknessAlg.config.FFT_LENGTH);

figure
plot(f,P(1:thicknessAlg.config.FFT_LENGTH/2+1))
title('')
xlabel('Frequency (f)')
ylabel('|P(f)|')





%% Create a highpass filter
Fstop = 3.3e6;
Fpass = 3.5e6;
Astop = 65;
Apass = 1;
Fs = 15e6;

d = designfilt('highpassfir','StopbandFrequency',Fstop, ...
  'PassbandFrequency',Fpass,'StopbandAttenuation',Astop, ...
  'PassbandRipple',Apass,'SampleRate',Fs,'DesignMethod','equiripple');

fvtool(d)
%%

txPulseFilt = filtfilt(d,txPulse);
%%

[txPulse, tPulse] = generateChirp(header.sampleRate, header.pulseLength, 3.5e6, 3.8e6);    
%%
plot(txPulseFilt)
hold on
plot(txPulse)
                    
     