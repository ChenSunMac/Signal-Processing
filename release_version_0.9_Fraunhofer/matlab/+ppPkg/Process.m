%> @file Process.m
%> @brief Class processing transducer data in parallel using Parallel
%>        computing tool box or processing in serial.
% ======================================================================
%> @brief Class processing transducer data in parallel using Parallel
%>        computing tool box or processing in serial.
%
%> 
% ======================================================================
classdef Process < handle
    % Class for processing scan data
    %   Detailed explanation goes here
    
    properties
        poolObj       
        processAllFiles = false
        processAllTransducers = false
        processAllShots = false
        processRangeOfShots = false
        blueNoseRawData = false
        saveResultToFile = false
        saveResultPath = '';        
    end
        
    properties 
        txPulse 
        transducerId
        fileIndex
        startShotIndex
        stopShotIndex
        numOfExpectedHarmonics
        disableWarningMessages = true
    end
    
    methods        
        %======================================================================
        %> @brief Class constructor
        %>         
        %> @return instance of the Process class.
        % ======================================================================    
        function obj = Process()
          
        end
        
        %======================================================================
        %> @brief Function parses input arguments
        %> 
        %> @param obj instance of the Process class. 
        %> @param headerFile headerFile         
        %> @param varargin 
        % ====================================================================== 
        function parseInput(obj, headerFile, varargin)                        
            % Create function input parser object
            p = inputParser;

            obj.processAllFiles = true;
            obj.processAllTransducers = true; 
            obj.processAllShots = true;
            obj.processRangeOfShots = false;
            obj.blueNoseRawData = false;
            obj.saveResultToFile = false;
            obj.saveResultPath = '';            

            % Default transducerId is set to 0, meaning all tranducers should be
            % used
            defaultTransducerId = -1;
            defaultFileNumber = 0;
            defaultShotIndex = 0;
            defaultBluenoseRaw = 0;
            defaultStartIndex = 0;
            defaultStopIndex = 0;
            defaultSaveResultPath = '';

            % Define function parameters
            addRequired(p, 'headerFile', @ischar);
            addParameter(p,'transducerId', defaultTransducerId, @isnumeric);
            addParameter(p,'fileNumber', defaultFileNumber, @isnumeric);
            addParameter(p,'shotIndex', defaultShotIndex, @isnumeric);
            addParameter(p,'startIndex', defaultStartIndex, @isnumeric);
            addParameter(p,'stopIndex', defaultStopIndex, @isnumeric);
            addParameter(p,'bluenoseRawEnabled', defaultBluenoseRaw, @isnumeric);
            addParameter(p,'saveResultPath', defaultSaveResultPath,  @ischar);

            % Parse function input
            parse(p, headerFile, varargin{:})

            if( p.Results.fileNumber ~= 0)        
                fprintf('Process data from file: %d\n', p.Results.fileNumber);
                obj.processAllFiles = false;  
                obj.fileIndex =  p.Results.fileNumber;

                if( p.Results.shotIndex ~= 0 )
                    fprintf('Process data from shotIndex: %d\n', p.Results.shotIndex);
                    obj.processAllShots = false;  
                end

                if( p.Results.startIndex ~= 0 && p.Results.stopIndex ~= 0)
                    obj.processRangeOfShots = true;
                    obj.processAllShots = false; 
                end        
            end  

            if( p.Results.transducerId ~= -1 )
                fprintf('Process data from transducerId: %d\n', p.Results.transducerId);
                obj.processAllTransducers = false; 
                obj.transducerId = p.Results.transducerId;
            end    
             
            if( p.Results.bluenoseRawEnabled ~= 0 )
                obj.blueNoseRawData = true;
            end  
            
           if( ~isempty(p.Results.saveResultPath) )
                % Save results to file
                obj.saveResultToFile = true;
                obj.saveResultPath = p.Results.saveResultPath;
                fprintf('Processing result is saved to folder %s\n', obj.saveResultPath)
           end                        

            % Check if only a single shot should be processed or a range of
            % shots
            if( false == obj.processAllShots && false == obj.processRangeOfShots)
                obj.startShotIndex =  p.Results.shotIndex;
                obj.stopShotIndex = obj.startShotIndex;
            elseif(false == obj.processAllShots && true == obj.processRangeOfShots )
                obj.startShotIndex =  p.Results.startIndex;
                obj.stopShotIndex =  p.Results.stopIndex;
            else
                obj.startShotIndex = 1;
                
            end            
            
        end
        
        %======================================================================
        %> @brief Function parses input arguments
        %> @brief 
        %> Optional parameters:
        %> transducerId: Process data from one specific transducer Id
        %> fileNumber:   Process data from one data file
        %> shotIndex:    Process data from one file and shotIndex
        %> startIndex,stopIndex:   Process data from one file and a range of
        %>               index [startIndex:stopIndex]
        %> bluenoseRawEnabled   For processing of data from bluenose and
        %>                      without header, this field must be set
        %>                      to 1.
        %> 
        %>
        %> Example: Process data from transducer Id: 5
        %> runProcess( ctrl, headerFile, 'transducerId', 5)
        %>
        %> Example: Process data from fileNumber 3
        %> runProcess( ctrl, headerFile, 'fileNumber', 5)
        %>
        %> Example: Process data from bluenose: fileNumber 5 and transducer 14 and
        %>          range of index 14510:18894
        %> runProcess( ctrl, headerFile, 'headerFile,  'fileNumber', 5, 'startIndex', 14510,'stopIndex',18894,'transducerId', 14, 'bluenoseRawEnabled', 1);
        %>       
        %> @param obj instance of the Process class. 
        %> @param ctrl reference to Controller object                    
        %> @param headerFile filepath to project header file         
        %> @param varagin
        % ======================================================================         
        function pr = runProcess( obj, ctrl, headerFile, varargin )

            import ppPkg.*
            obj.parseInput(headerFile, varargin{:});
                   
            disp('Start Parallel Processing')
            if(ctrl.enableThicknessProcessing)
                fprintf('Calliper and thickness processing:\n%s\n', headerFile);
            else
                fprintf('Calliper processing:\n%s\n', headerFile);
            end              
            
            if(obj.blueNoseRawData == true)                
                % Since bluenose data currently does not have a header
                % describing the data, some parameters must be set hard
                % coded:
                obj.setBlueNoseHardCodedConfiguration(ctrl, headerFile);
                
            else
                % Read header file
                ctrl.header = ctrl.importHandler.readHeader(headerFile);
                ctrl.importHandler
            end            
                 
            
            % Eric for 3us chirp
            ctrl.header.pulseLength = 45;
            % Generate TX pulse
            obj.txPulse =  obj.createTxPulse(ctrl.header.pulsePattern, ctrl.header.sampleRate, ctrl.header.pulseLength, ctrl.header.fLow, ctrl.header.fHigh);
            
            % Set tx Pulse
            ctrl.callipAlg.setTxPulse(obj.txPulse);
            
            % Calculate number of expected harmonics
            obj.numOfExpectedHarmonics = ctrl.thicknessAlg.findNumberOfHarmonics(ctrl.header.fLow, ctrl.header.fHigh + ...
                                                           ctrl.config.DELTA_FREQUENCY_RANGE);
            % Process all files in folder
            if(obj.processAllFiles)
                
                if( obj.saveResultToFile )
                    % Process data and save result
                    processFilesInParallelAndSavePartResult(obj, ctrl);
                    pr = ProcessingResult;
                    % Save Controller object
                    saveControllerToFile(obj, ctrl);
                else
                    [pr] = processFilesInParallel(obj, ctrl);

                    % Sort processing result from each worker, so that they are in
                    % correct order.
                    pr = obj.sortProcessResult(pr);
                end
            else
                [pr] = processDataFromOneFile(obj, ctrl);
            end  
            
            if(isempty(pr(end).fileIndex))
                pr(end) = [];
            end

        end
        
        %======================================================================
        %> @brief Function save controller object
        %>
        %> 
        % ======================================================================                  
        function saveControllerToFile(obj, ctrlScan)            
            path = strcat(obj.saveResultPath,'\');
            fileToSave = strcat(path, 'ctrlScan.mat');           
            save(fileToSave, 'ctrlScan');
        end        
        
        %======================================================================
        %> @brief Function process data with a set of configuration
        %>
        %> @param varagin
        % ======================================================================          
        function runProcessBatch( obj, ctrl, headerFile, configArray, filenameResult, varargin)            

            for i = 1:numel(configArray)
                                
                % Copy Controller
                ctrlBatch = ctrl.copy;
                
                % Set new configuration
                ctrlBatch.setConfiguration(configArray(i));                
                         
                % Process data with new configuration
                ctrlBatch.pr = obj.runProcess( ctrlBatch, headerFile, varargin{:} )
                
                s = strcat('_',int2str(i));
                filenameSave = strcat(filenameResult, s);
                
                % Save Controller containing processing results
                save(filenameSave, 'ctrlBatch')
                clear ctrlBatch;
                
            end              
        end
        
        %======================================================================
        %> @brief Function for processing data in parallel with a number of 
        %> @brief matlab workers. Each matlab worker will process data from
        %> @brief one file each. Function uses the spmd function from the 
        %> @brief Parallel Computing Toolbox.
        %> @brief
        %> @brief   NOTE: 
        %> @brief   numlabs: is the number of workers
        %> @brief   labindex: is the worker id 
        %> 
        %> @param obj instance of the Process class. 
        %> @param ctrl reference to Controller object         
        % ======================================================================              
        function [prRes] = processFilesInParallel(obj, ctrl)
            import ppPkg.*
            
            % Processing all files using several workers in parallel        
            spmd

                if(obj.disableWarningMessages)
                    warning('off','all')
                end
                
                pr(round(ctrl.header.numRec/numlabs)) = ProcessingResult;      
                
                % Init ProcessingResult index
                prIndex = 1;                   

                % Iterate through all file indexes
                for fileIndex_ = labindex:numlabs:ctrl.importHandler.header.numFiles        

                    % Set data file index
                    ctrl.importHandler.dataFileIndex = fileIndex_;
                    
                    % Read data file
                    tmArr = ctrl.importHandler.importDataFile(); 
                    
                    fprintf('labindex %d fileIndex %d: \"%s\"\n', labindex, fileIndex_, char(ctrl.importHandler.dataFiles(fileIndex_)));                                    

                    % Iterate over array of transducer recordings
                    for index = 1:numel(tmArr)
                     
                        % Check if all transducers shoult be processed
                        if(obj.processAllTransducers == false)
                            
                            logicArray = (tmArr(index).transducerId == obj.transducerId);                                      
                            if(0 == sum(logicArray))                        
                                continue;
                            end
                        end

                        if(mod(prIndex, 1000) == 0)
                            fprintf('Shoot count: %d file: %d\n', prIndex,  (ctrl.importHandler.dataFileIndex - 1));
                        end

                        % Set shotIndex  
                        pr(prIndex).shotIndex = index;

                        % Process data from one transducer
                        obj.processTm(ctrl, tmArr(index), pr(prIndex));

                        % Increment ProcessingResult index
                        prIndex = prIndex + 1;               
                    end
                end
                
                if(obj.disableWarningMessages)
                    warning('on','all')
                    warning('query','all')  
                end
                pr(prIndex:end) = [];
            end                          

            % Copy data out of workers
            poolStruct = gcp;
            if(~isempty(poolStruct))
                prRes = [];

                for i = 1:poolStruct.NumWorkers 
                    prRes = [prRes pr{i}];
                end
            else
                prRes = pr{1};
            end
                            
        end
        
        %======================================================================
        %> @brief Function for processing data in parallel with a number of 
        %> @brief matlab workers. Each matlab worker will process data from
        %> @brief one file each. Function uses the spmd function from the 
        %> @brief Parallel Computing Toolbox.
        %> @brief
        %> @brief   NOTE: 
        %> @brief   numlabs: is the number of workers
        %> @brief   labindex: is the worker id 
        %> 
        %> @param obj instance of the Process class. 
        %> @param ctrl reference to Controller object         
        % ======================================================================              
        function processFilesInParallelAndSavePartResult(obj, ctrl)
            import ppPkg.*
            
            % Processing all files using several workers in parallel        
            spmd

                if(obj.disableWarningMessages)
                    warning('off','all')
                end                                                                               

                % Iterate through all file indexes
                for fileIndex_ = labindex:numlabs:ctrl.importHandler.header.numFiles        

                    % Set data file index
                    ctrl.importHandler.dataFileIndex = fileIndex_;
                    
                    % Read data file
                    tmArr = ctrl.importHandler.importDataFile(); 
                    
                    % Allocate numel
                    pr(numel(tmArr)) = ProcessingResult;      
                    % Init ProcessingResult index
                    prIndex = 1;                   
                    
                    fprintf('labindex %d fileIndex %d: \"%s\"\n', labindex, fileIndex_, char(ctrl.importHandler.dataFiles(fileIndex_)));                                    

                    % Iterate over array of transducer recordings
                    for index = 1:numel(tmArr)
                     
                        % Check if all transducers shoult be processed
                        if(obj.processAllTransducers == false)
                            
                            logicArray = (tmArr(index).transducerId == obj.transducerId);                                      
                            if(0 == sum(logicArray))                        
                                continue;
                            end
                        end

                        if(mod(prIndex, 1000) == 0)
                            fprintf('Shoot count: %d file: %d\n', prIndex,  (ctrl.importHandler.dataFileIndex - 1));
                        end
                         

                        % Set shotIndex  
                        pr(prIndex).shotIndex = index;

                        % Process data from one transducer
                        obj.processTm(ctrl, tmArr(index), pr(prIndex));

                        % Increment ProcessingResult index
                        prIndex = prIndex + 1;               
                    end 
                    
                    % Save Processing result to file
                     prRes = [pr];
                     obj.saveProcessingResult(prRes, fileIndex_);

                end
                
                if(obj.disableWarningMessages)
                    warning('on','all')
                    warning('query','all')  
                end
                pr(prIndex:end) = [];
            end        
            
                                
                   
        end       
        
        function saveProcessingResult(obj, prRes, fileIndex)
            filename = sprintf('pr_file_%0.3d.mat',fileIndex);
            path = strcat(obj.saveResultPath,'\');
            fileToSave = strcat(path, filename);           
            save(fileToSave, 'prRes');     
        end
        
        %======================================================================
        %> @brief Function for processing data from only one data file
        %> 
        %> @param obj instance of the Process class. 
        %> @param ctrl reference to Controller object         
        % ======================================================================        
        function [prRes] = processDataFromOneFile(obj, ctrl)              
            
            % Processing data from one file 
            import ppPkg.*
            
            if(obj.disableWarningMessages)
                warning('off','all')
            end
            
            % Set file index
            ctrl.importHandler.dataFileIndex =  obj.fileIndex;

            % Read data file
            tmArr = ctrl.importHandler.importDataFile(); 

            if( true == obj.processAllShots)
                obj.stopShotIndex = numel(tmArr);
            end

            % Init ProcessResult index
            prIndex = 1;

            % Preallocate Processing Results
            numRes = obj.stopShotIndex - obj.startShotIndex + 1;
            prRes(numRes) = ProcessingResult; 
            
            % Iterate over array of transducer recordings
            for index = obj.startShotIndex:obj.stopShotIndex

                % Check if all transducers should be processed   
                if(obj.processAllTransducers == false)
                    
                    logicArray = (tmArr(index).transducerId == obj.transducerId);                       
                    if(0 == sum(logicArray))                        
                        continue;
                    end
                end

                if(mod(prIndex, 1000) == 0)
                    fprintf('Shoot count: %d file: %d\n', prIndex,  (ctrl.importHandler.dataFileIndex - 1));
                end

%                 fprintf('fileIndex %d index %d trId %d\n', obj.fileIndex, index, tmArr(index).transducerId)   

                % Set shotIndex  
                prRes(prIndex).shotIndex = index;

                % Process data from one transducer
                obj.processTm(ctrl, tmArr(index), prRes(prIndex));

                % Increment ProcessResult index
                prIndex = prIndex + 1;               
            end
            
            % Remove empty Processing results
            prRes(prIndex:end)=[];

            if(obj.disableWarningMessages)
                warning('on','all')
                warning('query','all')  
            end                       
        end    
        
        %======================================================================
        %> @brief Function reprocess an area given by dataAddress struct
        %> 
        %> @param obj instance of the Process class. 
        %> @param ctrl reference to Controller object         
        % ======================================================================             
        function reProcessArea(obj, ctrl, dataAddress)            
            import ppPkg.*
            
            if(obj.disableWarningMessages)
                warning('off','all')
            end             
            
            % Calculate number of expected harmonics
            obj.numOfExpectedHarmonics = ctrl.thicknessAlg.findNumberOfHarmonics(ctrl.header.fLow, ctrl.header.fHigh + ...
                                                           ctrl.config.DELTA_FREQUENCY_RANGE);            

            % Iterate over files
            for index = 1:numel(dataAddress)                
                if(dataAddress(index).shotCount == 0)
                    continue;
                end
                
                % Set file index
                ctrl.importHandler.dataFileIndex =  dataAddress(index).file;

                % Read data file
                tmArr = ctrl.importHandler.importDataFile(); 
                
                % Iterate over shots
                for indexM = 1:numel(dataAddress(index).shotIndex)
                                           
                    % Process shot
                    obj.processTm(ctrl, tmArr(dataAddress(index).shotIndex(indexM)),  ctrl.pr(dataAddress(index).prIndex(indexM)));
                end                                
            end
                        
            if(obj.disableWarningMessages)
                warning('on','all')
                warning('query','all')  
            end                                        
        end
        
        %======================================================================
        %> @brief Function reprocess an area with a set of configuration
        %>        objects. Results from each processing is saved to disk
        %> 
        %> @param obj instance of the Process class. 
        %> @param ctrl reference to an Controller object         
        %> @param configArray reference to an array of configuration objects 
        %> @param dataAddress struct containing information about data to
        %>                    process
        %> @param filename Name of file to be saved
        % ======================================================================          
        function reProcessAreaBatch(obj, ctrl, configArray, dataAddress, filename)
            import ppPkg.*
            
            for i = 1:numel(configArray)
                
                % Copy Controller
                ctrlBatch = ctrl.copy;
                
                % Set new configuration
                ctrlBatch.setConfiguraiton(configArray(i));                
                         
                % Process area with new configuration
                obj.reProcessArea(ctrlBatch, dataAddress);
                
                s = strcat('_',int2str(i));
                filenameSave = strcat(filename, s);
                
                % Save Controller object containing processing result
                save(filenameSave, 'ctrlBatch')
                clear ctrlBatch;
                
            end            
        end
        
        %======================================================================
        %> @brief Function starts requested number of matlab workers
        %> 
        %> @param obj instance of the Process class. 
        %> @param numWorkers number of matlab workers to start       
        % ======================================================================            
        function startWorkers(obj, numWorkers )            
            % Only start a new pool of workers if there is no active pool
            % of workers
            %if(isa(obj.poolObj, 'parallel.Pool') && isvalid(obj.poolObj) )
            if( ~isempty(gcp('nocreate')) )
                if(isempty(obj.poolObj))
                     obj.poolObj = gcp;
                end
                
                if(obj.poolObj.NumWorkers ~= numWorkers ) 
                    % Restart pool for workers if not enough workers started
                    obj.stopWorkers();
                    % Start requested number of workers
                    obj.poolObj = parpool('local', numWorkers);            
                end
               
            else
                % Start requested workers
                obj.poolObj = parpool('local', numWorkers);            
            end
        end
        
        %======================================================================
        %> @brief Function stops all matlab workers
        %> 
        %> @param obj instance of the Process class.    
        % ======================================================================        
        function stopWorkers(obj)
            delete(gcp('nocreate'))
            delete(obj.poolObj)
        end
        
        %======================================================================
        %> @brief Function sets hard coded parameters for blue nose project
        %> @brief since we yet do not have a header file describing the
        %> @brief data
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object     
        %> @param folderName name of folder containing data     
        % ======================================================================
        function setBlueNoseHardCodedConfiguration(~, ctrl, folderName)
                fprintf('\n***********************************************************!!!\n');
                fprintf('NOTE: header info is hardcoded since data header is missing!!!\n');
                fprintf('***********************************************************!!!\n\n');
                ctrl.importHandler.readFolder(folderName);
                ctrl.header.sampleRate = ctrl.config.SAMPLE_RATE;                
                ctrl.header.pulseLength = (30e-6)*ctrl.header.sampleRate;
                ctrl.header.fLow = 0.3e6;
                ctrl.header.fHigh = 3.8e6;  
                ctrl.header.pulsePattern = 'chirp';
                ctrl.header.numRec = 2e5;
                fprintf('Emitted signal type: %s\n', ctrl.header.pulsePattern);
                fprintf('Signal length in #samples: %d\n', ctrl.header.pulseLength);
                fprintf('Signal fLow: %d\n', ctrl.header.fLow);
                fprintf('Signal fHigh: %d\n', ctrl.header.fHigh);
                fprintf('Sampling rate: %d\n', ctrl.header.sampleRate);
                ctrl.importHandler.header.numFiles = numel(ctrl.importHandler.dataFiles);

                if(ctrl.header.sampleRate ~= ctrl.config.SAMPLE_RATE)
                    error('Mismatch in sample rate configuration');
                end            
        end
        
        %======================================================================
        %> @brief Function creates txPulse used for calliper calculation
        %>
        %> @param obj instance of the Process class.
        %> @param pattern Signal pattern       
        %> @param sampleRate Sample rate for tx pulse  
        %> @param pulseLength Pulse length in number of samples  
        %> @param fLow Lower frequency 
        %> @param fHigh Higher Frequency 
        % ======================================================================
        function [txPulse] = createTxPulse(~, pattern, sampleRate, pulseLength, fLow, fHigh)
            
            import ppPkg.SignalGenerator;            
            
            s = SignalGenerator(lower(pattern), sampleRate, pulseLength/sampleRate, fLow, fHigh);
            
            txPulse = s.signal;
            
        end
        
        %======================================================================
        %> @brief Function sort processing results in the correct order.
        %> @brief This is necessary if processing has been divided by
        %> @brief several matlab workers
        %>
        %> @param obj instance of the Process class.
        %> @param prUnsorted reference to unsorted ProcessingResult                   
        % ======================================================================          
        function [prSorted] = sortProcessResult(~, prUnsorted)

            import ppPkg.ProcessingResult

            % Init
            fileNumber = prUnsorted(1).fileIndex;

            % Find all file indexes
            for i = 1:numel(prUnsorted)
                if(fileNumber(end) ~= prUnsorted(i).fileIndex)
                    fileNumber = ([fileNumber prUnsorted(i).fileIndex]);
                end
            end

            % Keep the unqie ones
            fileNumber = unique(fileNumber);

            % If data is only from one file, Processing result is already 
            % in sorted order so return
            if(numel(fileNumber) == 1)
                prSorted = prUnsorted;
                return;
            end

            
            numberOfFiles = numel(fileNumber);

            length = round(numel(prUnsorted)/numberOfFiles);

            prTemp(numberOfFiles, length) = ProcessingResult;

            indexCounter = ones(numberOfFiles, 1);

            for i = 1:numel(prUnsorted)

                fileIndex_ = prUnsorted(i).fileIndex;
                shotIndex = indexCounter(prUnsorted(i).fileIndex);
                prTemp(fileIndex_, shotIndex) = prUnsorted(i);

                indexCounter(prUnsorted(i).fileIndex) = indexCounter(prUnsorted(i).fileIndex) + 1;
            end
            
            prSorted = [];
            for fileIndex_ = 1:numberOfFiles
                prSorted = [prSorted prTemp(fileIndex_,:)];
            end            
        end
          
        %======================================================================
        %> @brief Function process data from one transducer
        %> @brief Calculates - calliper, noise
        %> @brief            - thickness
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object
        %> @param tmObj reference to TransducerMeasurment object
        %> @param prObj reference to ProcessingResult object       
        % ====================================================================== 
        function processTm(obj, ctrl, tmObj, prObj)
            
            if(obj.blueNoseRawData)               
                DELAY_BEFORE_CORRELATION = 0;
            else
                DELAY_BEFORE_CORRELATION = 1000;
            end
                        
            timeBeforeRecordingInNumberOfSamples = tmObj.startTimeRec;

            % Calliper calculation
            [distance, ~, ~, ~] = ctrl.callipAlg.calculateDistance( DELAY_BEFORE_CORRELATION, tmObj.signal, double(timeBeforeRecordingInNumberOfSamples));
            
            % Set calliper result
            prObj.calliper = single(distance);
            
            % File index
            prObj.fileIndex = uint32((ctrl.importHandler.dataFileIndex - 1)); 
            
            % Copy transducer properties to processing result
            prObj.setPrPropertiesFromTm(tmObj);

            if(~obj.blueNoseRawData)               
                % For lab scan transducerId must be set to a fixed value
                % because current version labsystem does not handle this
                % correctly
               prObj.transducerId = uint16(1); 
            end                 

            % TODO temporary for bluenose
            if(obj.blueNoseRawData)
                tmObj.fHigh = 3.8e6;
                tmObj.fLow = 0.3e6;
            end
            
            % Limit search range
            if(0)
                tmObj.fHigh = 1e6;
                tmObj.fLow = 0.1e6;
            end

            % Calculate noise floor
            if(obj.blueNoseRawData)
               noiseSignal = calculateNoiseBlueNose(obj, ctrl, prObj, tmObj);
            else
               noiseSignal = calculateNoiseLab(obj, ctrl, prObj, tmObj);
            end              

            MINIMUM_DISTANCE_TO_PIPE_WALL = 0.01;
            % If distance is out of range, skip thickness calculations
            if( ~ctrl.enableThicknessProcessing || ... 
                    distance > 1.20*(ctrl.config.D_NOM + ctrl.config.NOMINAL_DISTANCE_TO_WALL)|| ...
                    distance < MINIMUM_DISTANCE_TO_PIPE_WALL)

                return
            end                

            % Calculate start and stop index for where psdMain and
            % psdResonance should be computed
            if(false == ctrl.thicknessAlg.calculateStartStopForAbsorptionAndResonance(tmObj.signal, ctrl.callipAlg))                      
                return
            end

            % Calculate psdMain and psdResonance                
            ctrl.thicknessAlg.calculatePsd(tmObj.signal);  
            
            % Calculate signal to noise ratio (SNR)
            prObj.snr = ctrl.thicknessAlg.calculateSNR(tmObj.signal, noiseSignal);  

            % Keep psd spectrum if enabled
            if(ctrl.keepPsdArrays)
                prObj.psdMain = ctrl.thicknessAlg.psdMain;
                prObj.psdResonance = ctrl.thicknessAlg.psdResonance;
                prObj.fMain = ctrl.thicknessAlg.fVector;        
            end

            % Calculate thickness from psd
            if(ctrl.calculateThicknessFromResonancePsd)
                [prObj] = obj.findThicknessFromResonancePsd( ctrl, prObj, tmObj );
            else
                [prObj] = obj.findThicknessFromAbsorptionPsd( ctrl, prObj, tmObj );
            end
        end   
        
        %======================================================================
        %> @brief Function calculates noise floor from lab scans
        %> @brief Noise floor is calculated if enabled otherwise a fixed
        %> @brief noise floor will be used
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object
        %> @param tmObj reference to TransducerMeasurment object
        %> @param prObj reference to ProcessingResult object       
        % ======================================================================
        function [noiseSignal] = calculateNoiseLab(~, ctrl, prObj,tmObj)
            
            noiseSignal = tmObj.signal(1000:ctrl.callipAlg.firstReflectionIndex-20);            
            
            if(ctrl.calculateNoiseFloor && length(noiseSignal) >= 400)
                % Noise PSD calculation: Using pWelch or periodogram
                [psdNoise] = ctrl.noiseAlg.calculatePsd(prObj.transducerId, noiseSignal, ...
                ctrl.config.TS_ADJUST_NOISE_ENABLE, 'periodogram', 'hanning', 400);

                % Calculate mean and var for range [fLow, fHigh]
                [ctrl.thicknessAlg.meanNoiseFloor] = ctrl.noiseAlg.calculateMeanVarInRange(prObj.transducerId, tmObj.fLow, tmObj.fHigh); 
            else
                ctrl.thicknessAlg.meanNoiseFloor = ctrl.labDefaultNoiseLevel;
            end
            
            prObj.noiseMean = single(ctrl.thicknessAlg.meanNoiseFloor);

        end
        
        %======================================================================
        %> @brief Function calculates noise floor from bluenose scans
        %> @brief Noise floor is calculated if enabled otherwise a fixed
        %> @brief noise floor will be used
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object
        %> @param tmObj reference to TransducerMeasurment object
        %> @param prObj reference to ProcessingResult object       
        % ======================================================================
        function [noiseSignal] = calculateNoiseBlueNose(~, ctrl, prObj, tmObj)
            
            noiseSignal = tmObj.signal(1:ctrl.callipAlg.firstReflectionIndex-50);            
                       
            if(ctrl.calculateNoiseFloor && length(noiseSignal) >= 100)
                % Noise PSD calculation: Using pWelch or periodogram
                [psdNoise] = ctrl.noiseAlg.calculatePsd(prObj.transducerId, noiseSignal, ...
                ctrl.config.TS_ADJUST_NOISE_ENABLE, 'periodogram', 'hanning', 400);

                % Calculate mean and var for range [fLow, fHigh]
                [ctrl.thicknessAlg.meanNoiseFloor] = ctrl.noiseAlg.calculateMeanVarInRange(prObj.transducerId, tmObj.fLow, tmObj.fHigh); 

                %ctrl.noiseAlg.plotPsd(prObj.transducerId);
            else
                ctrl.thicknessAlg.meanNoiseFloor = ctrl.bluenoseDefaultNoiseLevel;
            end  
            
            prObj.noiseMean = single(ctrl.thicknessAlg.meanNoiseFloor);
            
        end
        
        %======================================================================
        %> @brief Calculates thickness from resonance psd
        %> @brief 
        %> @brief 1. Find peaks or troughs in the psd
        %> @brief 2. Find all possible harmonic sets 
        %> @brief 3. Find the set that most likely represents the
        %> @brief    thickness
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object
        %> @param tmObj reference to TransducerMeasurment object
        %> @param prObj reference to ProcessingResult object       
        % ======================================================================       
        function [prObj] = findThicknessFromResonancePsd(obj, ctrl, prObj, tmObj)
            % Find thichness from the Resonance spectrum
            
            import ppPkg.PeakMethod;
            
            if(ctrl.config.RESONANCE_PSD_SEARCH_FOR_PEAKS)
                % Find peaks in resonance spectrum
                obj.findPeaksFromResonancePsd(ctrl, tmObj);

                % Find all possible sets based on the peaks found and
                % calculate set thickness and validation parameters
                obj.findSetsInResonancePsd(ctrl, tmObj, ctrl.config.REQUIRED_NO_HARMONICS);

                if( isempty(ctrl.thicknessAlg.setResonance)) 
                    % If no sets was found, search after 8 peaks with highest
                    % prominence, and calculate sets
                    ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, tmObj.fLow, tmObj.fHigh + ...
                        ctrl.config.DELTA_FREQUENCY_RANGE, PeakMethod.N_HIGEST_PROMINENCE, 8);
                    %disp('peaks 3');    

                    obj.findSetsInResonancePsd(ctrl, tmObj, 3);
                end


                if( ~isempty(ctrl.thicknessAlg.setResonance)) 

                    setCandidate = ctrl.thicknessAlg.findBestSetE(ctrl.thicknessAlg.setResonance);
                    %close all
                    %ctrl.thicknessAlg.plotAllSets('resonance', setCandidate)

                    if( ~isempty(setCandidate) )
                        prObj.thickness = single(ctrl.thicknessAlg.setResonance(setCandidate(1)).thickness);
                        prObj.setNo = uint16(setCandidate(1));
                        prObj.vp = single(ctrl.thicknessAlg.setResonance(setCandidate(1)).vp);
                        prObj.class = ctrl.thicknessAlg.setResonance(setCandidate(1)).class;
                    end
                end                                    
                
            else
                % Find the the troughs in the resonance spectrum
                
                % Flip the spectrum and then search for the peaks.                 
                ctrl.thicknessAlg.psdResonance = -ctrl.thicknessAlg.psdResonance;
                
                % Search for peaks            
                obj.findPeaksFromResonancePsd(ctrl, tmObj);
                
                setCandidate = [];
                
                if(numel(ctrl.thicknessAlg.peakValueResonance) >= 2 )
                    
                    obj.findSetsInResonancePsd(ctrl, tmObj, ctrl.config.REQUIRED_NO_HARMONICS );
                    
                    if( isempty(ctrl.thicknessAlg.setResonance)) 
                        % If no sets was found, search after 8 peaks with highest
                        % prominence, and calculate sets
                        ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, tmObj.fLow, tmObj.fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);  
                        %disp('peaks 3');    

                        obj.findSetsInResonancePsd(ctrl, tmObj, 2);
                    end                    
                    

                    if( ~isempty(ctrl.thicknessAlg.setResonance))                                                          

                        if( ~isempty(ctrl.thicknessAlg.setResonance) )                                 
                            setCandidate = ctrl.thicknessAlg.findBestSetE(ctrl.thicknessAlg.setResonance); 
                        end   

                        if( ~isempty(setCandidate) )
                            prObj.thickness = single(ctrl.thicknessAlg.setResonance(setCandidate(1)).thickness);
                            prObj.setNo = uint32(setCandidate(1));
                            prObj.vp = single(ctrl.thicknessAlg.setResonance(setCandidate(1)).vp);
                            prObj.class = ctrl.thicknessAlg.setResonance(setCandidate(1)).class;
                        end                          
                    end
                    
                end
                
                if( isempty(setCandidate) )
                    prObj.thickness = 0;
                    prObj.setNo = 0;
                    prObj.vp = 0;                                
                end 
                
            end
            
        end
        
        %======================================================================
        %> @brief Calculates thickness from absorption psd
        %> @brief 
        %> @brief 1. Find peaks in the psd
        %> @brief 2. Find all possible harmonic sets 
        %> @brief 3. Find the set that most likely represents the
        %> @brief    thickness
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object
        %> @param tmObj reference to TransducerMeasurment object
        %> @param prObj reference to ProcessingResult object       
        % ======================================================================      
        function [prObj] = findThicknessFromAbsorptionPsd(~, ctrl, prObj, tmObj)
            
            TODO needs to verify
            % Find peaks in absorption spectrum
            ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.MAIN, 1e6, 3e6, PeakMethod.N_HIGEST_PROMINENCE);
            
            
            % Find harmonic sets
            ctrl.thicknessAlg.findFrequencySets(ctrl.thicknessAlg.MAIN, 1e6, 3e6, ctrl.config.REQUIRED_NO_HARMONICS );

            if( ~isempty(ctrl.thicknessAlg.setMain)) 
                % Find the best set and thickness
                ctrl.thicknessAlg.processSets(ctrl.thicknessAlg.MAIN, ctrl.noiseAlg.psd(prObj.transducerId)); 

                setCandidate = [];

                if( ~isempty(ctrl.thicknessAlg.setMain) )                                 
                    setCandidate = ctrl.thicknessAlg.findBestSetE(ctrl.thicknessAlg.setMain); 


                end   

                if( ~isempty(setCandidate) )
                    prObj.thickness = single(ctrl.thicknessAlg.setMain(setCandidate(1)).thickness);
                    prObj.setNo = uint32(setCandidate(1));
                    prObj.vp = single(ctrl.thicknessAlg.setMain(setCandidate(1)).vp);
                    prObj.class = ctrl.thicknessAlg.setMain(setCandidate(1)).class;
                end                          
            end    
        end
        
        
        %======================================================================
        %> @brief Function find peaks in the resonance psd spectrum
        %> @brief 
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object        
        %> @param tmObj reference to TransducerMeasurment object      
        % ======================================================================           
        function findPeaksFromResonancePsd(obj, ctrl, tmObj)
            import ppPkg.PeakMethod;

            % Using find peak method with minimum peak prominence and
            % minimum db above noise as requirement 
            ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, tmObj.fLow, tmObj.fHigh + ...
                    ctrl.config.DELTA_FREQUENCY_RANGE, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);

            % If number of peaks found is less than 3, search for the 3 peaks with highest prominince    
            if(numel(ctrl.thicknessAlg.peakValueResonance) < 3 )

                ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, tmObj.fLow, tmObj.fHigh + ...
                    ctrl.config.DELTA_FREQUENCY_RANGE, PeakMethod.N_HIGEST_PROMINENCE, 3);
                %disp('peaks 2');            
            end

            if(0 )

                ctrl.thicknessAlg.findPeaksInPsd(ctrl.thicknessAlg.RESONANCE, tmObj.fLow, tmObj.fHigh + ...
                    ctrl.config.DELTA_FREQUENCY_RANGE, PeakMethod.N_HIGEST_PROMINENCE, 8);
                %disp('test');            
            end

            % Test peak reduction
%             if(numel(ctrl.thicknessAlg.peakProminenceResonance) > obj.numOfExpectedHarmonics - 2)                                                                  
% 
%                 ctrl.thicknessAlg.peakReduction(ctrl.thicknessAlg.RESONANCE);    
%             end
        end
        
        %======================================================================
        %> @brief Function finds harmonic sets based on peaks found
        %> @brief and calculate thickness and validation parameters for
        %> @brief each set. Sets that have a thickness that is outside the
        %> @brief allowed range are removed.
        %>
        %> @param obj instance of the Process class.
        %> @param ctrl reference to Controller object        
        %> @param tmObj reference to TransducerMeasurment object      
        % ======================================================================     
        function findSetsInResonancePsd(~, ctrl, tmObj, numberOfHarmonics)
            

            % Find all harmonic sets
            ctrl.thicknessAlg.findFrequencySets(ctrl.thicknessAlg.RESONANCE, tmObj.fLow, tmObj.fHigh + ...
                ctrl.config.DELTA_FREQUENCY_RANGE, numberOfHarmonics);
            
            % Calculated set validation parameters and set thickness                            
            ctrl.thicknessAlg.processSets(ctrl.thicknessAlg.RESONANCE, ...                                            
                                            ctrl.thicknessAlg.meanNoiseFloor);            
        end                                
    end           
end

