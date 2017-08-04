%> @file transducerTest.m
%> @brief Contain functions for processing transducer test measurements
% ======================================================================
%> @brief Contain functions for processing transducer test measurements
%
%> 
% ======================================================================


% ======================================================================
%> @brief Function transducerTest
%>
%> @param ctrl Controller object
%> @param folder Folder containing transducer test measurements
%> @param psdCompare Baseline transducer to compare with
%> @param folderToSave Path to folder to where plots should be saved
%> @retval res Struct containing:
%>                        medianNoise
%>                        meanNoise
%>                        medianDbAboveNoise
%>                        meanDbAboveNoise
%>                        psdMain
%>                        psdResonance
%>                        dataHeader
%>                        transducer
%>                        title
% ======================================================================  
function res = transducerTest(ctrl, folder, psdCompare, folderToSaveFig)

    % Read folder 
    % Get all subfolder names
    % Do a regex
    % Keep the ones that matches the regex
    listing = dir(folder);
    
    %folderNames;
    [pathstr,name,ext] = fileparts(folder); 
    
    folderIndex = 1;
    for index = 1:size(listing,1)        
        temp = regexp(listing(index).name,'B12_BN218.*','match');
        if(~isempty(temp))
            dataFolders(folderIndex) = cellstr(listing(index).name);
            folderIndex = folderIndex + 1;
        end
    end
    
    folderFirstPart = strcat(listing(1).folder,'\');

    % Initialize struct
    res(numel(dataFolders)) = struct('medianNoise',0,...
           'meanNoise',0,...
           'medianDbAboveNoise',0,...
           'meanDbAboveNoise',0,...
           'psdMain', 0,...
           'psdResonance', 0,...
           'dataHeader','',...
           'transducer','',...
           'title','');    
                    
    
    % Get path to all header files in dataFolders    
    for indexN = 1:numel(dataFolders)
        folderPath = char(dataFolders(indexN));        
        folderPath = strcat(folderFirstPart, folderPath);
        folderPath = strcat(folderPath,'\');
        
        % Get content of folderPath
        listingFolder = dir(char(folderPath));
        
        % Iterate through the files in the folder
        for indexM = 1:size(listingFolder,1)     
            
            % Get the file that contains 'header' and extract information
            % from the file name
            temp = regexp(listingFolder(indexM).name,'.*header','match');
            if(~isempty(temp))
                
                % Get Transducer info
                token1 = regexp(listingFolder(indexM).name,'.*(BN218_\d\d_\d\d\d).*','tokens');
                res(indexN).transducer = char(token1{1});
                
                % Get Title txt
                token2 = regexp(listingFolder(indexM).name,'(.*)_[0-9]+_[0-9]+_header','tokens');
                res(indexN).title = char(token2{1});
                
                % Get path to data file header               
                fileName = listingFolder(indexM).name;    
                res(indexN).dataHeader = strcat(folderPath, fileName);                                
            end
        end                
    end
    
    % Iterate through struct array to process data from each transducer
    for index = 1:numel(res)

        % Process data
        res(index) = processData(ctrl, res(index));
        
        % Plot PSD main with psd compare        
        plotPsdMain(ctrl, res(index), psdCompare, folderToSaveFig);
        plotPsdResonance(ctrl, res(index), folderToSaveFig);
               
        res(index)
        %pause()
        
        close all
        
    end    
end

% ======================================================================
%> @brief Function process transducer data
%>        Function will calculate median and mean noise, and median and
%>        mean dB above noise for the peaks. And calculate the mean Psd
%>        main and psd resonance
%>
%> @param ctrl Controller object
%> @param res Struct
%> @retval res Struct
% ======================================================================   
function res = processData(ctrl, res)
    ctrl.start(res.dataHeader);

    res.medianNoise = median([ctrl.pr(:).noiseMean])
    res.meanNoise = mean([ctrl.pr(:).noiseMean])

    dbAboveNoiseTemp = zeros(1, length(ctrl.pr));

    for indexM = 1:length(ctrl.pr)
        dbAboveNoiseTemp(indexM) = mean(ctrl.pr(indexM).peakDB) - res.medianNoise;
    end

    res.medianDbAboveNoise = median(dbAboveNoiseTemp);
    res.meanDbAboveNoise = mean(dbAboveNoiseTemp);

    res.psdMain = mean([ctrl.pr(:).psdMain], 2);
    res.psdResonance = mean([ctrl.pr(:).psdResonance], 2);  
end

% ======================================================================
%> @brief Function plots Psd Main and save figure to file
%>
%> @param ctrl Controller object
%> @param res Struct
%> @param psdCompare
%> @param folderToSaveFig
% ======================================================================   
function plotPsdMain(ctrl, res, psdCompare, folderToSaveFig)

    fig = figure;
    plot(ctrl.pr(1).fMain,[res.psdMain])
    hold on
    plot(ctrl.pr(1).fMain, psdCompare)
    title('Psd Main')
    grid on
    transducerTxt = strrep(res.transducer, '_', ' ');
    titleTxt = strrep(res.title, '_', ' '); 
    filenameFig = strcat('Psd_Main_', res.title)
    legend(transducerTxt,'BN lab 3 LG40 SG05 latest')
    title(titleTxt)
    ylim([-120 -60]);

    saveFigPath = strcat(folderToSaveFig,'\');
    saveFigPath = strcat(saveFigPath,filenameFig);

    savefig(fig, saveFigPath)

end

% ======================================================================
%> @brief Function plots Psd Resonance
%>
%> @param ctrl Controller object
%> @param res Struct
%> @param folderToSaveFig
% ======================================================================   
function plotPsdResonance(ctrl, res, folderToSaveFig)
    fig = figure;
    plot(ctrl.pr(1).fMain,[res.psdResonance])
    grid on
    titleTxt = strrep(res.title, '_', ' '); 
    filenameFig = strcat('Psd_Resonance_', res.title);    
    title(titleTxt)
    ylim([-150 -80]);
    saveFigPath = strcat(folderToSaveFig,'\');
    saveFigPath = strcat(saveFigPath,filenameFig);

    savefig(fig, saveFigPath)
        
end
