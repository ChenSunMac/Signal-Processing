classdef Controller < matlab.mixin.Copyable;% handle
    % Controller of the post processing application
    % Will control the flow of the application
    
    % Import data
    % Create objects containing measurement data
    % Run algorithms on the data
    
    
    properties
        
        importHandler      % Import data handler
        callipAlg          % 
        thicknessAlg       %
        noiseAlg
        pr
        
        
        header
        keepPsdArrays = false
        keepPeakData = false
        fLow
        fHigh
        enableThicknessProcessing = false
        calculateThicknessFromResonancePsd = true
        skipThicknessCalculation = true;
        calculateNoiseFloor = false;
        bluenoseDefaultNoiseLevel = -135.7
        labDefaultNoiseLevel = -141;
        
    end
    
    properties (SetAccess = private)
        config             % Configuration object with parameters
    end
    
    methods
        function obj = Controller()
            import ppPkg.*;
            config = Configuration;
            obj.importHandler = ImportHandler;          
            obj.config = config;
            
            obj.callipAlg = CalliperAlgorithm(obj.config);
            obj.thicknessAlg = ThicknessAlgorithm(obj.config);
            obj.noiseAlg = Noise(obj.config);
            obj.pr = ProcessingResult;                        
        end
        
        function setConfiguration(obj, configuration)
            % Set new configuration
            obj.config = configuration; 
            % Sync configuration with the other algorithm classes
            obj.reSyncConfig();
        end
        
        function start(obj, filename, varargin)
        %% Function will start process scan data
        %  
        % filename: filename to scan headerfile
        % dataFileIndex:     
            
            import ppPkg.ProcessingResult
            import ppPkg.Noise
            import ppPkg.PeakMethod
            disp('Start controller')
            tic
            
            % Read header file
            obj.header = obj.importHandler.readHeader(filename);
                        
            obj.noiseAlg = Noise(obj.config);
            
            % Create pulse signal to use with calliper algorithm
            txPulse = obj.createPulse();             
            obj.callipAlg.setTxPulse(txPulse);
            pulseLength = length(obj.callipAlg.txPulse);
                                    
            recCount = 1;                        
            searchForSecondThickness = false;
          
            linePlotScanEnabled = false;
            singleShotScanEnabled = false;
            numberOfHarmonics = 2;
            
            if (length(varargin) == 1)
                % Line scan
                disp('Line scan')
                linePlotScanEnabled = true;
                dataFileIndex = varargin{1};                
                obj.importHandler.dataFileIndex = dataFileIndex;
                startShotIndex = 1;                
                
            elseif(length(varargin) == 2)
                % Single shot scan
                disp('Single shot scan')
                singleShotScanEnabled = true;
                dataFileIndex = varargin{1};
                shotIndex = varargin{2};
                
                obj.importHandler.dataFileIndex = dataFileIndex;
                startShotIndex = shotIndex;
                
            else
                % Normal scan
                disp('Scan whole plate')
                obj.importHandler.dataFileIndex = 1;
                startShotIndex = 1;                
            end
               
            % Create array of ProcessingResult objects
            obj.pr(obj.importHandler.header.numRec) = ProcessingResult;                  
            
            
            % Loop each file
            for fileNo = 1:obj.header.numFiles
                
                % Import data
                tmArr = obj.importHandler.importDataFile();              
                                
                if(linePlotScanEnabled && obj.importHandler.dataFileIndex == dataFileIndex + 2)
                    obj.pr(recCount:end) = [];
                    toc
                    return
                end
                                               
                % Loop each transducer measurement
                for index = startShotIndex:length(tmArr) 
                    % Create Processing Result object                    
                    
                    if(singleShotScanEnabled && index == startShotIndex + 1)
                        obj.pr(recCount:end) = [];
                        return
                    end                    
      
                    if(mod(recCount, 1000) == 0)
                        fprintf('Shoot count: %d file: %d\n', recCount, (obj.importHandler.dataFileIndex - 1));
                    end
                     fprintf('Shoot count: %d file: %d\n', recCount, (obj.importHandler.dataFileIndex - 1));                    
                    
                    if(obj.config.SAMPLE_RATE ~= tmArr(index).sampleRate)
                        error('Error in sampleRate')
                    end
                    
                    obj.pr(recCount).fileIndex = (obj.importHandler.dataFileIndex - 1); 
                    obj.pr(recCount).shotIndex = index;
                    obj.pr(recCount).date = tmArr(index).date;
                    obj.pr(recCount).fireTime = tmArr(index).fireTime;
                    obj.pr(recCount).xPos = tmArr(index).xPos;
                    obj.pr(recCount).yPos = tmArr(index).yPos;
                    obj.pr(recCount).zPos = tmArr(index).zPos;
                    obj.pr(recCount).uPos = tmArr(index).uPos;
                    obj.pr(recCount).transducerId = 1; %tmArr(index).transducerId;
                    obj.pr(recCount).debug = 0;                                      
                                       
                    delay = 1000;

                    deltaTimeBeforeRecordingIsStarted = (double(tmArr(index).startTimeRec))*double(tmArr(index).sampleRate);
                    [distance, firstReflectionStartIndex, ~, pitDept] = obj.callipAlg.calculateDistance( delay, tmArr(index).signal, deltaTimeBeforeRecordingIsStarted);                    

                    obj.pr(recCount).calliper = distance;                    
                    obj.pr(recCount).calliperPitDetect = pitDept;
                    
                    MINIMUM_DISTANCE_TO_WALL = 0.01;
                    % Hack to bypass thickness algorithm                    
                    if( ~obj.enableThicknessProcessing  || distance > 1.20*(obj.config.D_NOM + obj.config.NOMINAL_DISTANCE_TO_WALL)|| distance < MINIMUM_DISTANCE_TO_WALL)
                        %disp('o')                       
                    else
                  
                        %% Noise calculations
                        if(1)
                            noiseSignal = tmArr(index).signal((2*pulseLength+100):firstReflectionStartIndex-200);
                            
                            % If remaining noise signal is too short, set
                            % noise meanValue to default value
                            if(length(noiseSignal) > 400)
   
                                % Noise PSD calculation: Using pWelch or periodogram
                                obj.noiseAlg.calculatePsd(obj.pr(recCount).transducerId, noiseSignal, obj.config.TS_ADJUST_NOISE_ENABLE, 'periodogram', 'hanning', 400);

                                % Calculate mean and var for range [fLow, fHigh]
                                [meanValue] = obj.noiseAlg.calculateMeanVarInRange(obj.pr(recCount).transducerId, tmArr(index).fLow, tmArr(index).fHigh);
                            else
                                meanValue = -147.8427;
                            end
                        else
                            meanValue = -147.8427;
                        end
                        
                        obj.pr(recCount).noiseMean = meanValue;

                        % Calculate start and stop index for where psdMain and
                        % psdResonance should be computed
                        if(false == obj.thicknessAlg.calculateStartStopForAbsorptionAndResonance(tmArr(index).signal, obj.callipAlg))                      
                            recCount = recCount + 1;
                            continue;
                            
                            disp('Error in calculating start and stop index for resonance')
                        end
                        

                        %% Calculate psdMain and psdResonance                       
                        obj.thicknessAlg.calculatePsd(tmArr(index).signal); 
                        
                        obj.pr(recCount).pMain = obj.thicknessAlg.calculateFFTMain(tmArr(index).signal);
                                                
                        
                        % Store PSD for Main and Resonance
                        if(obj.keepPsdArrays)
                            obj.pr(recCount).psdResonance = obj.thicknessAlg.psdResonance;
                            obj.pr(recCount).psdMain = obj.thicknessAlg.psdMain;
                            obj.pr(recCount).fMain = obj.thicknessAlg.fVector;
                        end
                        
                        % Set Noise floor
                        obj.thicknessAlg.meanNoiseFloor = meanValue;

                        % Find peaks
                        if(~isempty(obj.fLow) && ~isempty(obj.fHigh))                        
                            %[pks, locs, startIndex, w, p] = obj.thicknessAlg.findPeaksInPsd(psdResonance,  obj.fLow, obj.fHigh , 3);                                             
                            %peakLocation, peakValue, peakWidth, peakProminence
                            [peakLocation, peakValue, peakWidth, peakProminence] = obj.thicknessAlg.findPeaksInPsd(obj.thicknessAlg.RESONANCE, obj.fLow, obj.fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);
                            
                            %plot(fResonance, psdResonance,fResonance(locs),pks,'o',fResonance(startIndex),(psdResonance(startIndex)),'*')
                            obj.thicknessAlg.plotPsdPeaks(obj.thicknessAlg.RESONANCE);
                            ylim([-160 -70])
                            grid on
                            
                           obj.pr(recCount).peakDB = peakValue;
                        else
                            
                            % Test                         
                            obj.thicknessAlg.findPeaksInPsd(obj.thicknessAlg.RESONANCE, 0.8e6, tmArr(index).fHigh + ... 
                                obj.config.DELTA_FREQUENCY_RANGE, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE);
                        end 
                        
                        
                        if(obj.skipThicknessCalculation)
                            recCount = recCount + 1;
                            continue;
                        end
                        
                        
                        % Find sets                       
                        obj.thicknessAlg.findFrequencySets(obj.thicknessAlg.RESONANCE, 0.8e6, tmArr(index).fHigh + ...
                            obj.config.DELTA_FREQUENCY_RANGE, numberOfHarmonics);

                        if( isempty(obj.thicknessAlg.setResonance)) 
                           
                            recCount = recCount + 1;
                            continue;
                        end
                        
                        % Process sets
                        obj.thicknessAlg.processSets(obj.thicknessAlg.RESONANCE, tmArr(index).fLow, tmArr(index).fHigh + obj.config.DELTA_FREQUENCY_RANGE, obj.noiseAlg.psd(obj.pr(recCount).transducerId)) 
                        
                        set = obj.thicknessAlg.setResonance;
                                                
                        if( isempty(set) )                         
                            recCount = recCount + 1;
                            continue;
                        end
                        
                                                                        
                        thicknessFromMain = 0;
                        % Find the best set. 
                        if(numel(set) > 1)
                           [setCandidate] = obj.thicknessAlg.findBestSetE(set);
                           %[setCandidate] = obj.thicknessAlg.findBestSetD(set, set);
                        else
                            setCandidate = 1;  
                        end

                        % Test
                        %thicknessFromMain = obj.findThicknessFromMain();
                        
                        if(0)
                            T_nom = 0.0096;
                            if( abs(thicknessResonance - T_nom) > 0.15*T_nom)

                                thicknessFromMain = obj.findThicknessFromMain2();

                                if(abs(thicknessFromMain - T_nom) < 0.15*T_nom)                                        
                                    set(setCandidate).thickness = thicknessFromMain;
                                end
                            else
                                thicknessFromMain = 0;
                            end
                        end
                        
                        
 
                        %[setCandidate2] = obj.thicknessAlg.findSetWithHighestAveragePeakEnergy(remainSet);

                         %thicknessFromMain = findThicknessFromMain(obj, psdMain);
                         %thicknessFromMain = 0;
                         
if(0)                         
                         if(obj.callipAlg.adjustBeginMain == 0 && ... 
                            obj.callipAlg.adjustEndMain == 0 )                        
                           
                           % Find thickness from main                           
                            
                           % Use results from main as input when searching
                            %for a set in resonance part of signal                      
                           %[setCandidateMain] = obj.thicknessAlg.findBestSetD(set, set, thicknessFromMain);
                           %  obj.pr(recCount).thicknessCombined = set(setCandidateMain).thickness;
                            
                         else
                            obj.pr(recCount).debug = 0.001;  
%                             [setCandidate] = obj.thicknessAlg.findBestSetD(set, set);
%                             obj.pr(recCount).thicknessCombined = set(setCandidate).thickness;
                         end
 end                        
                         
                        % Test search for 2. thickness in resonance
                        % spectrum.
                        % 1. Remove peaks that belong to intact thickness,
                        % 2. Find sets based on the remaining peaks
                        % 3. Find sets that has the same thickness as found
                        % in calliper algorithm
                        %firstThickness = set(setCandidate).thickness;
                        firstThicknessSet = set(setCandidate);
                        firstThicknessSetNo = setCandidate;
                        secondThickness = 0; 
                        if(searchForSecondThickness && ...
                           ~(pitDept == 0) )

                            % Find all sets that belong to thickness
                            % "firstThicknessSet"
                            [count, setIndex] = obj.thicknessAlg.findNumberOfSetsWithThickness( firstThicknessSet.thickness, set, 3);
                            % Return location for all peaks
                            locsToRemove = unique([set([setIndex]).psdIndexArray]);
                            % Remove locsToRemove from locs
                            locsToSeach = setxor(locs, locsToRemove');      
                            % Find sets based on the remaining peaks
                            obj.thicknessAlg.findFrequencySetsFromHighAndLow('resonance', psdResonance, locsToSeach, 0.8e6, tmArr(index).fHigh + obj.config.DELTA_FREQUENCY_RANGE );
                            
                            if( ~isempty(obj.thicknessAlg.resonanceSet))                                                         
                                % Calculate validation parameters
                                set = obj.thicknessAlg.calculateSetThickness(obj.thicknessAlg.resonanceSet);                        
                                set = obj.thicknessAlg.calculateSetValidationParameters(obj.thicknessAlg.resonanceSet, tmArr(index).fLow, tmArr(index).fHigh + obj.config.DELTA_FREQUENCY_RANGE , obj.noiseAlg.psd(1) );
                                
                                % Remove invalid sets by using d_min and d_nominal (d_maxs)
                                set = obj.thicknessAlg.removeInvalidSets(obj.thicknessAlg.resonanceSet, obj.config.D_MIN, obj.config.D_NOM);
                                obj.thicknessAlg.resonanceSet = set;

                                if( isempty(set) )                         
                                    secondThickness = 0;                                    
                                else
                                    setIndex = [];
                                    [count, setIndex] = obj.thicknessAlg.findNumberOfSetsWithThickness( (obj.config.D_NOM-pitDept), set, 10);
                                    if(~isempty(setIndex))
                                        secondThickness = set(setIndex(1)).thickness;
                                    end
                                end
                            end                            
                        end                                                                        

                                             

                        if( length(setCandidate) > 0)
                            obj.pr(recCount).thickness = firstThicknessSet.thickness;
                            obj.pr(recCount).thicknessSecond = secondThickness;
                            obj.pr(recCount).thicknessMain = thicknessFromMain;
                            obj.pr(recCount).setNo = firstThicknessSetNo;%setCandidate(1);
                            obj.pr(recCount).vp = firstThicknessSet.validationParameter;
                            obj.pr(recCount).class = firstThicknessSet.class;
                            
                        end

                    end 
                    
                    recCount = recCount + 1;
                end 
                
            end 
            
            obj.pr(recCount:end) = [];
            
            toc
        end
        
        
        function thickness = findThicknessFromMain(obj)
            import ppPkg.PeakMethod;
            
            tmpNoiseFloor = obj.thicknessAlg.meanNoiseFloor;            
            obj.thicknessAlg.meanNoiseFloor = 0;
            fLow = 1e6;%tm.fLow;
            fHigh = 3.4e6;
            
            % Find peaks
            obj.thicknessAlg.findPeaksInPsd(obj.thicknessAlg.MAIN, fLow, fHigh, PeakMethod.N_HIGEST_PROMINENCE);
            %obj.thicknessAlg.findPeaksInPsd(obj.thicknessAlg.MAIN, fLow, fHigh, PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE)
            
            
            if(0)
                % Keep only peaks that are larger than half of max peak prominence
                maxPeakProminence = max(obj.thicknessAlg.peakProminenceMain);
                idxl = (obj.thicknessAlg.peakProminenceMain > (maxPeakProminence/2));
                obj.thicknessAlg.peakProminenceMain = obj.thicknessAlg.peakProminenceMain(idxl);
                obj.thicknessAlg.peakLocationMain = obj.thicknessAlg.peakLocationMain(idxl);
                obj.thicknessAlg.peakValueMain = obj.thicknessAlg.peakValueMain(idxl);
                obj.thicknessAlg.peakWidthMain = obj.thicknessAlg.peakWidthMain(idxl);
            end
            
            % Plot peaks
            %obj.thicknessAlg.plotPsdPeaks(obj.thicknessAlg.MAIN);
                        
            % If no peaks found: exit function
            if( numel(obj.thicknessAlg.peakValueMain) < 2)
                                
                thickness = 0;
                return                
            end
            
            % Set required number of harmonics
            requiredNumberOfHarmonicsInSet = 2;

            % Find frequency sets
            obj.thicknessAlg.findFrequencySets(obj.thicknessAlg.MAIN, fLow, fHigh, requiredNumberOfHarmonicsInSet);

            % TODO: exit if no sets found
            if( isempty(obj.thicknessAlg.setMain) )
                thickness = 0;
                return                
            end
            
            % Process set data
            obj.thicknessAlg.processSets(obj.thicknessAlg.MAIN, fLow, fHigh, obj.noiseAlg.psd(1)); 
            
            if( isempty(obj.thicknessAlg.setMain) )
                thickness = 0;
                return                
            end
            
            % Find best set candidate
            [setC] = obj.thicknessAlg.findBestSetE(obj.thicknessAlg.setMain);
            
            % Get thickness
            thickness = obj.thicknessAlg.setMain(setC).thickness;
        end              
               
        function txPulse = createPulse(obj)
            % Create pulse for calliper algoritm
            import ppPkg.SignalGenerator
            
            s = SignalGenerator(lower(obj.header.pulsePattern), obj.header.sampleRate, obj.header.pulseLength/obj.header.sampleRate,  obj.header.fLow, obj.header.fHigh);
            
            txPulse = s.signal;              
        end 
                        

        
        function reSyncConfig(obj)
            obj.thicknessAlg.setConfiguration(obj.config);
            obj.noiseAlg.setConfiguration(obj.config);
            obj.callipAlg.setConfiguration(obj.config);            
        end
        
    end    
    
   methods(Access = protected)
      % Override copyElement method:
      function cpObj = copyElement(obj)
         % Make a shallow copy of all four properties
         cpObj = copyElement@matlab.mixin.Copyable(obj);
         % Make a deep copy of the config object
         cpObj.config = copy(obj.config);
         cpObj.importHandler = copy(obj.importHandler);
         cpObj.callipAlg = copy(obj.callipAlg);
         cpObj.thicknessAlg = copy(obj.thicknessAlg);
         cpObj.noiseAlg = copy(obj.noiseAlg);
         cpObj.pr = copy(obj.pr);
         
         cpObj.reSyncConfig();
      end
   end    
end


