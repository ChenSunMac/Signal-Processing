%> @file MainSignalProcessing.m
%> @ Processing Signal test
% ======================================================================
%> @Input: 
%       - multiple files/ single .bin file
%
%> @Output:
%       - Time/Freq Energy map: (a   x   matrix)
%       - Thickness map: (a 96 x 520 matrix)
%       - 3 FFT results: (each of them is a 96 x 520 x 2048 matrix)
%
%> @Author: Chen Sun 
%
%> @Date: Sept 26, 2017 
% ======================================================================
clc
clear
%% INITIALIZATION
% Const Parameters    
Fs = 15.0e6;
FFT_LENGTH = 4096;
f = Fs*(0:(FFT_LENGTH/2))/FFT_LENGTH;
%for Olympus
   trLayout = [1 33 17 29 13 93 49 81 65 77 61 21 25 9 41 5 37 69 73 57 89 53 85 45 2 34 18 30 14 94 50 82 66 78 62 22 26 10 42 6 38 70 74 58 90 54 86 46 3 35 19 31 15 95 51 83 67 79 63 23 27 11 43 7 39 71 75 59 91 55 87 47 4 36 20 32 16 96 52 84 68 80 64 24 28 12 44 8 40 72 76 60 92 56 88 48];
%   %for Olympus
%  trLayout = 1:96;
%   % for Fraunhofer.
    % trLayout = [1 17 13 33 5 93 49 65 61 81 77 21 25 41 37 9 29 69 73 89 85 57 53 45 2 18 14 34 6 94 50 66 62 82 78 22 26 42 38 10 30 70 74 90 86 58 54 46 3 19 15 35 7 95 51 67 63 83 79 23 27 43 39 11 31 71 75 91 87 59 55 47 4 20 16 36 8 96 52 68 64 84 80 24 28 44 40 12 32 72 76 92 88 60 56 48];

    %% predefined values for test.
%     hasCoating = 1;
%     timeFlight = 59;
%     coatingFlight = 37;
%     signalEnd = 1400;
    hasCoating = 0;
    timeFlight = 51;
    coatingFlight = 0;
    signalEnd = 1400;
    
round_per_read = 520;
% predefine result mapping
thickPoints = zeros(96,round_per_read)+timeFlight; %round_per_read*length(Files)
coatPoints = zeros(96,round_per_read)+coatingFlight;
nominalThickness = 0.01;
PulseLength = 20; % length of the first pulse reflection.
coatingV  = 1e6;        %@
materialV = 1e6;        %@
CoatThickness = 1;      %@
startThickness = 0;     %@
endThickness = 0;       %@
RefInterval = round(((startThickness+endThickness)*Fs/materialV)*1);  % calculate use the nominal thickness plus 20% tolerance.
if ~hasCoating
    CoatingPoints = 0;
else 
    CoatingPoints = round(CoatThickness*2*Fs/coatingV);
end  

deltaPoints = round(nominalThickness/5910*15e6*2);
%% Initilize the storing matrices
FullSignalFFT = zeros(96,520,2049);
SecondReflectionSignalFFT = zeros(96,520,2049);
MetalReflectionSignalFFT = zeros(96,520,2049);
SignalMatrices = zeros(96,520,2000);
SignalMatrix = zeros(520,2000);
Signal = zeros(1,signalEnd);
MainReflection = zeros(1,300);
CalliperMap = zeros(96,520);
energySlicing1  = zeros(1,520);
energySlicing2  = zeros(1,520);
TimeEnergyMap1 = zeros(96,520);
TimeEnergyMap2 = zeros(96,520);
%% thickness calculation.
    if hasCoating~=0 && hasCoating~=1
       msgbox('coating selection must be 0 or 1');
       return
    end
    s=[-0.0729   -0.2975   -0.2346    0.1057    0.8121    0.5721   -0.4512   -0.7820   -0.5137     0.4829    0.8867   -0.0891   -0.4474   -0.0875    0.2159];
    t=1:315;
    
[FileNames,PathName]= uigetfile('*.bin;*.mat','MultiSelect', 'on');

for fileID = 1:length(FileNames)
        FileName = cell2mat(FileNames(fileID));
        tic
        [SignalMatrices] = processingBinFile(PathName,FileName);
        Time_ProcessingBinFile = toc;

    for k=1:96
        SignalMatrix(:,:) = SignalMatrices(trLayout(k),:,:);
        for i=1:round_per_read
            % we have a predefined SignalEnd Mark to truncate the signal
            Signal = SignalMatrix(i,1:signalEnd);
            % Normalize the valid signal
            Signal = Signal/max(abs(Signal));
            %% Calculate Calliper 
            Script_CalculatingCalliperMap;
            for j=1:signalEnd
                if(abs(Signal(j))>0.99*0.6) %find the first incline where 60% of max.
                    if( j > 20 ) && ( j < signalEnd - 280 + 1 )
                        Trigger = j - 20;
                        
                        %% Time Domain Analysis -> Thinkness
                        Script_CalculatingThicknessMap;
                        
                        %% Time Domain Analysis -> Energy Map
                        Script_CalculatingTimeEnergyMap;
                                                
                        %%  Frequency Analysis -> 3 different FFT results
                        Y = fft(Signal(Trigger: signalEnd),FFT_LENGTH);                        
                        FullSignalFFT(k,i,:) = abs(Y(1:FFT_LENGTH/2+1)/FFT_LENGTH);  % only need (1:n/2+1)
                        % FFT1 =  squeeze(FullSignalFFT(1,1,1:2048));
                        %% Main reflection window 
                        SignalMainReflection = Signal(1,j-20:j+279);
                        
                        [~,locsP] = findpeaks(SignalMainReflection,'MinPeakDistance',0.18*timeFlight);
                        
                        % added 0 start to ensure the envlop performance
                        envlop = interp1([1, t(locsP)],[0,SignalMainReflection(locsP)],t,'spline');

                        [pksEnvlop,locsEnvlop] = findpeaks(envlop);
                        if length(locsEnvlop) < 2
%                             errorMessage = 'Only found one peak in Signal';
%                             [falseLog] = logFalse(k, i, errorMessage, falseLog);
                            break;
                        end

                        TriggerToSecondReflectionStart = round((locsEnvlop(1) + locsEnvlop(2))/2);
                        
                        %FFT2 
                        Y = fft(Signal(TriggerToSecondReflectionStart + Trigger: signalEnd),FFT_LENGTH);                        
                        SecondReflectionSignalFFT(k,i,:) = abs(Y(1:FFT_LENGTH/2+1)/FFT_LENGTH);  % only need (1:n/2+1)
                        % FFT2 =  squeeze(SecondReflectionSignalFFT(1,1,1:2048));                        
                        
                        if hasCoating
                            % assuming df has at least 4 elements if with
                            % coating
                            df = diff(locsEnvlop);
                            if length(df) < 4
                                errorMessage = 'HasCoating But not enough peaks to identify';
                                [falseLog] = logFalse(k, i, errorMessage, falseLog);
                                break;
                            else
                                for df_index = 1 : (length(df) - 1)
                                    current_value = df(df_index);
                                    next_value = df(df_index + 1);
                                    if (current_value < next_value + 7) && (current_value > next_value - 7)  
                                        MetalStart = round((locsEnvlop(df_index + 1) + locsEnvlop(df_index + 2))/2);
                                    else 
                                        MetalStart = round((locsEnvlop(df_index + 1) + locsEnvlop(df_index + 2))/2);     
                                        break;
                                    end  
                                end
                        Y = fft( Signal(MetalStart + Trigger: signalEnd),FFT_LENGTH);                        
                        MetalReflectionSignalFFT(k,i,:) = abs(Y(1:FFT_LENGTH/2+1)/FFT_LENGTH);  % only need (1:n/2+1)
                        % FFT3 =  squeeze(SecondReflectionSignalFFT(1,1,1:2048));      
                            end
                        end
                        
                        
                        break;
                    else
                        % Signal too small - no meaning to do FFT
                       FullSignalFFT(k,i,:) = zeros(1, 2049);
                       SecondReflectionSignalFFT(k,i,:) = zeros(1, 2049);
                       MetalReflectionSignalFFT(k,i,:) = zeros(1, 2049);
%                        errorMessage = 'Signal too small' ;
%                        [falseLog] = logFalse(k, i, errorMessage, falseLog);


                        break;
                    end
                end
            end 
        end
    end
end
 Time_Total = toc;
    %% plot FFT results for certain channel:
FFT1 =  squeeze(FullSignalFFT(1,:,:));
figure(1),imagesc(FFT1');
FFT2 =  squeeze(SecondReflectionSignalFFT(1,:,:));
figure(2),imagesc(FFT2');
% FFT3 =  squeeze(MetalReflectionSignalFFT(1,:,:));
% figure(3),imagesc(FFT3);    
save(CalliperMap,CalliperMap);
save(ThicknessMap,thickPoints);
save(TimeEnergyMap1, TimeEnergyMap1);
save(TimeEnergyMap2, TimeEnergyMap2);
save(FullSignalFFT, FullSignalFFT);
save(SecondReflectionSignalFFT, SecondReflectionSignalFFT);
