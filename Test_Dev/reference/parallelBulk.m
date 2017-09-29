% function [thickPoints,coatPoints] = bulkThickness(coating,S,trLayout,timeFlight,coatingFlight,signalEnd)
%% Load .bin data.
tic
folderPath = uigetdir;
thickMap = [];
%         %for Olympus
trLayout = [1 33 17 29 13 93 49 81 65 77 61 21 25 9 41 5 37 69 73 57 89 53 85 45 2 34 18 30 14 94 50 82 66 78 62 22 26 10 42 6 38 70 74 58 90 54 86 46 3 35 19 31 15 95 51 83 67 79 63 23 27 11 43 7 39 71 75 59 91 55 87 47 4 36 20 32 16 96 52 84 68 80 64 24 28 12 44 8 40 72 76 60 92 56 88 48];
%         %     %for Olympus
%         %     trLayout = 1:96;
%         % % for Fraunhofer.
%         % trLayout = [1 17 13 33 5 93 49 65 61 81 77 21 25 41 37 9 29 69 73 89 85 57 53 45 2 18 14 34 6 94 50 66 62 82 78 22 26 42 38 10 30 70 74 90 86 58 54 46 3 19 15 35 7 95 51 67 63 83 79 23 27 43 39 11 31 71 75 91 87 59 55 47 4 20 16 36 8 96 52 68 64 84 80 24 28 44 40 12 32 72 76 92 88 60 56 48];

dirF = dir(fullfile(folderPath));
dirF=dirF(~ismember({dirF.name},{'.','..'}));
all_dir = ([dirF(:).isdir]);
totalFiles = numel(~all_dir);
sizeAll = dirF.bytes;
fileCount = 0;
lastRoundNumFiles = 0;
% Process data from a full minute of recording
% Find the first file of a folder
[~,fisrtFileName,~] = fileparts(dirF(1).name);
splittedName = strsplit(fisrtFileName,'-');
fileTime = splittedName(2);
% find hhmmss
minutesTime = str2double(fileTime{1,1}(1:6));
chunkSecond = rem(minutesTime,100);
% Example 43 48 53 58
fisrtRoundNumFiles = ceil((60-chunkSecond)/5);
totalRound = ceil((totalFiles - 6)/11)+1;

coating = 0;

if coating~=0 && coating~=1
    msgbox('coating selection must be 0 or 1');
    return
end

for indexProcess = 1:totalFiles
    %% ==================================================================
    %   Find one minute's worth of continuous data
    %   Observatioin: there are max 11 files in one minute
    %   The interval is not always 5 seconds
    
    %get first
    [~,fisrtFileName,~] = fileparts(dirF(fileCount+1).name);
    splittedName = strsplit(fisrtFileName,'-');
    fileTime = splittedName(2);
    % Get time as filename, hours and minutes. HHMM
    fileNameSave = fileTime{1,1}(1:4);
    fileNameSave = strcat('bn-thickMap', fileNameSave)
    
    %  Get time of a file in seconds
    if totalFiles - fileCount <=11
        numFiles2Read = totalFiles - fileCount;
    else
        % Find first file in this minute
        [~,fisrtFileName,~] = fileparts(dirF(fileCount+1).name);
        splittedName = strsplit(fisrtFileName,'-');
        fileTime = splittedName(2);
        %  Get time of a file in seconds
        timeStart = str2double(fileTime{1,1}(5:6));
        % File name XXXX43, read is 4 files
        numFiles2Read = ceil((60-timeStart)/5);
        
        % Find possible last file in this minute
        [~,tempLastFileName,~] = fileparts(dirF(fileCount+numFiles2Read).name);
        splittedName = strsplit(tempLastFileName,'-');
        fileTime = splittedName(2);
        timeStopTemp = str2double(fileTime{1,1}(5:6));
        
        if timeStopTemp - timeStart <= 0
            numFiles2Read = numFiles2Read - 1;
        end
    end
    %
    
    
    
    %% ===================================================================
    
    
    
    fileCount = fileCount + numFiles2Read;
    
    spmd
        
        for fileID = labindex:numlabs:numFiles2Read
            filename = dirF(fileID).name;
            disp(filename)
            iReadN = 1;
            tempSize = sizeAll/iReadN;
            round_per_read = floor(tempSize/32096/12);
            NewSignal=zeros(96,round_per_read,2000); % predefine size of the whole read signal from file.
            % ====================================
            iReadN = floor(sizeAll/(32096*12*round_per_read));
            skipByte = 0;
            
            fid=fopen(fullfile(folderPath,filename));
            status = fseek(fid,skipByte,'bof');
            raw_data = fread(fid,32096*12*round_per_read,'uint8');
            fclose(fid);
            
            sb=0;
            rp_i=0;
            ii=zeros(1,128);
            for i = 1:fix(size(raw_data,1)/32096) %128
                gain(i)   = uint8(raw_data(sb+24:sb+24)');
                raw_fireTime = uint8(raw_data(sb+25:sb+32)');
                fireTimeA(i)= typecast(raw_fireTime,'uint64');
                roll_b =typecast(uint8(raw_data(sb+17:sb+18)'),'int16');
                pitch_b =typecast(uint8(raw_data(sb+19:sb+20)'),'int16');
                
                if((roll_b~=8224)||(pitch_b~=8224))
                    rp_i=rp_i+1;
                    rp_locs(rp_i)=i;
                    roll_r(i)=roll_b;
                    pitch_r(i)=pitch_b;
                end
                
                for k=0:7
                    
                    raw_signal = uint8(raw_data(sb+k*4008+41:sb+k*4008+4040)');
                    signal0 = (typecast(raw_signal, 'uint16'));
                    signal0 = (double(signal0)-32768)/32768;
                    
                    % signal0(1)=32768;
                    raw_firstRef = uint8(raw_data(sb+k*4008+33:sb+k*4008+34)');
                    firstRef = typecast(raw_firstRef,'uint16');
                    ch= uint8(raw_data(sb+k*4008+39));
                    j=ch+1;
                    ii(j)=ii(j)+1;
                    
                    NewSignal(j,ii(j),:)=signal0;
                    
                end
                %   Increment starting bit. Needed
                sb = sb + 32096;
            end
            %
            raw_data = [];
            
            %% predefined values for test.
            coating = 1;
            timeFlight = 59;
            coatingFlight = 37;
            signalEnd = 1400;
            
            thickPoints = zeros(96,round_per_read)+timeFlight;
            coatPoints = zeros(96,round_per_read)+coatingFlight;
            s=[-0.0729   -0.2975   -0.2346    0.1057    0.8121    0.5721   -0.4512   -0.7820   -0.5137     0.4829    0.8867   -0.0891   -0.4474   -0.0875    0.2159];
            t=1:315;
            [b, a] = butter(1, 0.06, 'high');
            
            for k=1:96
                Signal = [];
                %             SNames = fieldnames(S);
                %             Signal = S.(SNames{trLayout(k)});
                Signal(:,:) = NewSignal(trLayout(k),:,:);
                
                for i=1:round_per_read
                    Sc(1,:)=Signal(i,1:signalEnd);
                    %     S = filtfilt(b, a, St);
                    Sc=Sc/max(abs(Sc));
                    for j=1:signalEnd
                        if(abs(Sc(j))>0.99*0.6) %find the first incline where 60% of max.
                            if(j>20)&&(j<signalEnd-280+1)
                                CS(k,i,:)=Sc(1,j-20:j+279); % obtain the main reflections.
                                SS =Sc(1,j-20:j+279);
                                break;
                            else
                                CS(k,i,:)=Sc(1,1:1+299);
                                SS =Sc(1,1:1+299);
                                break;
                            end
                        end
                    end
                    C=abs(conv(SS,s));
                    %C=envelope(SS,8,'rms');
                    [pksP,locsP] = findpeaks(C,'MinPeakDistance',0.2*timeFlight);
                    envlop = interp1(t(locsP),C(locsP),t,'spline');
                    %,min peak distance to be 20% of timeFlight, assuming most defects within 80% of loss.
                    [pksa,locsa] = findpeaks(envlop,'MinPeakProminence',0.8,'MinPeakDistance',0.2*timeFlight);
                    df=diff(locsa);
                    if(size(df,2)>0) %means find at least two peaks and have 1 diff.
                        
                        if coating == 0
                            coatPoints(k,i)=0;
                            n = median(df);
                            if n<timeFlight*1.2 % calculated points must not be over 120% of nominal.
                                thickPoints(k,i)=n;
                            end
                        elseif coating ==1
                            %% if coating fell at this point, assumuing bare metal at least 5 peaks can be found.
                            if df(1)<coatingFlight-7 && df(1)>coatingFlight+7 % if df(1) doesnt match with nominal coating thickness.
                                coatPoints(k,i)=0;
                                thickPoints(k,i)=df(1);
                                % if coating is there
                            else
                                coatPoints(k,i)=df(1);
                                if(size(df,2)>1)&&(pksa(3)>pksa(2)) % if pksa 3 is metal and pksa 2 is coating, and metal signal stronger than coating.
                                    thickPoints(k,i)=df(2);
                                elseif (size(df,2)>2)&&(pksa(4)>pksa(3)) % if pksa 4 is metal and pksa 2 and 3 is coating, and metal signal stronger than coating.
                                    thickPoints(k,i)=df(2)+df(3);
                                elseif (size(df,2)>3)&&(pksa(5)>pksa(4))
                                    thickPoints(k,i)=df(2)+df(3)+df(4);
                                elseif (size(df,2)>1)&&(abs(df(1)-df(2))>3) %if df(1) and df(2) are not the same reflection, ex. one for coating one for metal. means only one detected coating before metal.
                                    thickPoints(k,i)=df(2);
                                elseif(size(df,2)>2)&&(abs(df(2)-df(3))>3) % means two detected coating before metal.
                                    thickPoints(k,i)=df(2)+df(3);
                                elseif (size(df,2)>3)&& (abs(df(3)-df(4))>3) % means three detected coating before metal.
                                    thickPoints(k,i)=df(2)+df(3)+df(4);
                                end
                                
                            end
                            
                        end
                    end
                end
            end
        end
    end
    
    for resultCount = 1:numFiles2Read
        thickMap = [thickMap thickPoints{resultCount}];
    end
    toc
    tic
    save(fileNameSave,'thickMap')
    thickMap = [];
    toc
    
    if fileCount >= totalFiles
        return
    end
    
end


