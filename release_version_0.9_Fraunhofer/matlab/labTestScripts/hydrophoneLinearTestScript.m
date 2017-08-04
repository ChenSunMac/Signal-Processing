
clear all
close all
import ppPkg.*
%% Run function
fileName1 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_chirp_300_3800_30u_x380_dx10\hydrophone_linear_scan_chirp_300_3800_30u_x380_dx10_20160711_11014003_header';
fileName2 = 'D:\scan\hydrophone_scans\hydrophone_linear_scan_400mm_20mm_sine_4MHz_5u_dx10\hydrophone_linear_scan_400mm_20mm_sine_4MHz_5u_dx10_20160804_14053725_header';
FFT_LENGTH = 4096;
[ psdArray, fVector, distanceArray, meanArray ] = hydrophoneDataProcessLinear( FFT_LENGTH, fileName2 );
%%
plot(distanceArray, 10*log10(meanArray))
grid on
title('Peak2Peak vs distance')
xlabel('Distance')
ylabel('Peak2Peak value')

%% Waterfall plot in dB
figure
mesh(10*log10(psdArray))

%% Plot change in value for F = 0.5MHz to 4Mhz in 0.5MHz step in dB
%f = 0.5e6:0.5e6:4e6;
f = 4e6;
N = round( f*FFT_LENGTH/15e6);
figure
msgLegend = {};
for index = 1:length(N)
    
    plot(distanceArray, 10*log10(psdArray(:,N(index))))
    hold on
        
    msgLegend(index) = cellstr(sprintf('f=%d', f(index)));    
    ylabel('Frequency gain [dB]')    
    xlabel('Distance between Hydrophone and Tranducer [m]')
    title('Frequency vs distance plot')
    grid on
end
legend(msgLegend)

%% New Linear scan using sinus
filename1 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_0M5_40u_dx10\hydrophone_linear_scan_400mm_20mm_sine_0M5_40u_dx10_20160805_10410283_header'
filename2 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_1M_20u_dx10\hydrophone_linear_scan_400mm_20mm_sine_1M_20u_dx10_20160805_10384521_header'
filename3 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_1M5_13u33_dx10\hydrophone_linear_scan_400mm_20mm_sine_1M5_13u33_dx10_20160805_10360350_header'
filename4 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_2M_10u_dx10\hydrophone_linear_scan_400mm_20mm_sine_2M_10u_dx10_20160805_10333987_header'
filename5 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_2M5_8u_dx10\hydrophone_linear_scan_400mm_20mm_sine_2M5_8u_dx10_20160805_10311653_header'
filename6 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_3M_6u67_dx10\hydrophone_linear_scan_400mm_20mm_sine_3M_6u67_dx10_20160805_10284857_header'
filename7 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_3M5_5u72_dx10\hydrophone_linear_scan_400mm_20mm_sine_3M5_5u72_dx10_20160805_10261510_header'
filename8 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_4M_5u_dx10\hydrophone_linear_scan_400mm_20mm_sine_4M_5u_dx10_20160805_10232357_header'
filename9 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_4M5_4u45_dx10\hydrophone_linear_scan_400mm_20mm_sine_4M5_4u45_dx10_20160805_10184012_header'
filename10 = 'D:\scan\hydrophone_scans\hydrophone_linear\hydrophone_linear_scan_400mm_20mm_sine_5M_4u_dx10\hydrophone_linear_scan_400mm_20mm_sine_5M_4u_dx10_20160805_10514459_header'


%%
FFT_LENGTH = 4096;
[ psdArray, fVector, distanceArray, meanArray ] = hydrophoneDataProcessLinear( FFT_LENGTH, filename10);

%%
array(10,:)=meanArray;
%%
plot(distanceArray, 10*log10(meanArray))
grid on
title('Peak2Peak vs distance 5.0MHz')
xlabel('Distance')
ylabel('Peak2Peak value [dB]')


%%
figure
for index = 1:10
    plot(distanceArray, 10*log10(array(index,:)))
    hold on
end
title('Peak2Peak vs distance')
xlabel('Distance')
ylabel('Peak2Peak value [dB]')
legend('0.5M','1.0M','1.5M','2.0M','2.5M','3.0M','3.5M','4.0M','4.5M','5.0M')
grid on
%% Linear scan with data on csv format

meanArray2 = processHydrophoneDataLinearFromCsv('D:\scan\hydrophone_scans\CSV\4MHz\');

distanceArray2 = 0.02:0.01:0.4;

hold on
plot(distanceArray2, 10*log10(meanArray2))
