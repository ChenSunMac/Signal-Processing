folderPath = uigetdir;
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

fileCount = fileCount + numFiles2Read;
end