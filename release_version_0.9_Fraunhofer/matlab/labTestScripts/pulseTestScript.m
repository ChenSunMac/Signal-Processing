clear all
close all
import ppPkg.*
%%


ctrlScan = Controller;

% Set configuration
ctrlScan.config.V_PIPE = 4965;
ctrlScan.config.D_MIN = 0.015;
ctrlScan.config.D_NOM = 0.025;            
ctrlScan.config.SAMPLE_RATE = 15e6; 
ctrlScan.config.FFT_LENGTH = 4096;
ctrlScan.config.NOMINAL_DISTANCE_TO_WALL = 0.200;  
ctrlScan.config.ADJUST_START_TIME_RESONANCE = 0;
ctrlScan.config.ADJUST_STOP_TIME_RESONANCE =  0;
ctrlScan.config.WINDOW_RESONANCE = 'hanning';
ctrlScan.config.WINDOW_MAIN = 'rect'; 
ctrlScan.config.PERIODOGRAM_OVERLAP = 0.50;
ctrlScan.config.PERIODOGRAM_SEGMENT_LENGTH = 900;
ctrlScan.config.USE_PWELCH = true;
ctrlScan.config.MAX_WELCH_LENGTH = 1000;
ctrlScan.config.NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 1;           
ctrlScan.config.Q_DB_ABOVE_NOISE = 10;
ctrlScan.config.Q_DB_MAX = 10;
ctrlScan.config.PROMINENCE = 8;
ctrlScan.config.DELTA_FREQUENCY_RANGE = 0.5e6;
ctrlScan.config.DEBUG_INFO = false;
ctrlScan.config.NUMBER_OF_CHANNELS = 1;

ctrlScan.noiseAlg.setConfiguration(ctrlScan.config)


ctrlScan.enableThicknessProcessing = true;

%%
%folder = 'G:\data\scan\CI_pipe\01022017'; 
folderSinc = 'G:\data\scan\CI_pipe\01022017 sinc sg1';
%folderChirp = 'G:\data\scan\CI_pipe\01022017 chirp sg1';
%folderChirp = 'G:\data\scan\CI_pipe\02020217 part 1';
%folderChirp = '/Volumes/Samsung_T3/data/scan/CI_pipe/02020217';
%folderChirp = '/Volumes/Samsung_T/data/scan/CI_pipe/02020217 part 1';
%folderChirp = 'G:\data\scan\CI_pipe\03022017';

%folderToSaveFig = 'C:\Users\Processing PC 01\Documents\MATLAB\matlab\figures\';

folderToSaveFig = 'G:\figures\CI pipe\CIP_IN_SINC\';


%resSinc = pulseTest(ctrlScan, folderSinc, folderToSaveFig)

resChirp = pulseTest(ctrlScan, folderSinc, folderToSaveFig)
%%
for i = 1:length(resChirp)
   temp{i} = {i resChirp(i).title}
end


%%
close all
figure
startIndex = 18;
stopIndex = length(resChirp);
step = 7
for i = startIndex:step:stopIndex
    i
    plot(resChirp(i).psdF, resChirp(i).psdResonance)
    %plot(resChirp(i).psdF, resChirp(i).psdMain)
    hold on
    grid on
    
end

legend(resChirp(startIndex:step:stopIndex).title)
% figure
% 
% plot([resChirp(startIndex:step:stopIndex).snr])
% grid on
% ylabel('dB')
% 
% figure
% 
% stem([resChirp(startIndex:step:stopIndex).averageF0])
% mean([resChirp(startIndex:step:stopIndex).averageF0])
% grid on
% ylabel('thickness [m]')
% xlabel('Chirp type')
% ylim([0 1.14e5])

%%
allParts = [ 4    11    18    25    32    39     5    12    19    26    33    40     6    13    20    27    34    41     7    14    21    28    35    42];
figure
subplot(3,1,1)
plot(sort(allParts), [resChirp(sort(allParts)).averageF0])
title('Average F0')
grid on
subplot(3,1,2)
plot(sort(allParts),[resChirp(sort(allParts)).thickness])
title('Thickness')
grid on
subplot(3,1,3)

plot(sort(allParts), [resChirp(sort(allParts)).snr])
title('SNR')

grid on
%%

figure
dataIndex = [21]
for i = dataIndex
    i
    %plot(resChirp(i).psdF, resChirp(i).psdResonance)
    plot(resChirp(i).psdF, -resChirp(i).psdMain-180)
    
    hold on
    plot(resChirp(i).psdF, resChirp(i).psdResonance)
    grid on
    
end

legend(resChirp(dataIndex).title)
%%
figure
dataIndex = [42]
for i = dataIndex
    i
    %plot(resSinc(i).psdF, resSinc(i).psdResonance)
    plot(resSinc(i).psdF, resSinc(i).psdMain)
    hold on
    %plot(resChirp(i).psdF, resChirp(i).psdResonance)    
    plot(resChirp(i).psdF, resChirp(i).psdMain)
    grid on
    
end

%title(resSinc(dataIndex).title)
legend(resSinc(dataIndex).title, resChirp(dataIndex).title)
%legend(resSinc(dataIndex).title)
%legend(resChirp(dataIndex).title)



