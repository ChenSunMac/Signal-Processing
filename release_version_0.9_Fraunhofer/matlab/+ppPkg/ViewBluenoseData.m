%> @file ViewBluenoseData.m
%> @brief Class for inspection processesing results from Bluenose data
% ======================================================================
classdef ViewBluenoseData < handle
    
    properties
        ctrl
        numTransducers = 96
        transducerIds
        callipM
        thicknessM
        callipRemappedM
        thicknessRemappedM        
        noiseM
        snrM
        snrRemappedM
        transducerLayout
        transducerPingRate
        numberOfSamplesOffsetPrChannel
        defaultToolSpeed = 0.1525
        
        xc1Array = [];
        yc1Array = [];
        xc6Array = [];
        yc6Array = [];
        
        %16 nov, tool speed: 0.1525
        %18 nov, tool speed: 0.3638
        
        % Ring 1 transducer Id
        ring1 = [1 49 25 73  2 50 26 74 3 51 27 75 4 52 28 76];

        % Ring 6 transducer Id
        ring6 = [93 21 69 45 94 22 70 46 95 23 71 47 96 24 72 48];
        

    end
    
    properties (Access = private)
                axesHandle
        figHandle
        rectxy1
        rectxy2
        hl
        pointsSelected = 0
        
        
    end
    
    
    methods
        
        %======================================================================
        %> @brief Constructor for ViewBluenoseData
        %> @brief creates a matrix for thickness and calliper
        %> 
        %> @param ctrl instance of the Controller class.      
        %> @return obj of the ViewBluenoseData              
        % ======================================================================                 
        function obj = ViewBluenoseData(ctrl)
            % Deep copy
            obj.ctrl = ctrl.copy;            
            
            obj.setDefaultTransducerMapping();
            obj.extractResultToMatrix();
        end
                        
        %======================================================================
        %> @brief Function calculates transducer ping rater
        %>     
        %> @param obj instance of the ViewBluenoseData class.             
        % ======================================================================                         
        function calculateTransducerPingRate(obj)
            %obj.numBoards = ceil(numel(obj.transducerIds)/8);
            
            [pr] = getTransducerPr(obj, obj.transducerIds(1));
            
            medianFireTimeDiff = median(diff([pr.fireTime]));
            
            obj.transducerPingRate = (1/(double(medianFireTimeDiff) * 1e-6));            
        end
             
        %======================================================================
        %> @brief Function 
        %> @brief        
        %> 
        %> @param obj instance of the ViewBluenoseData class.     
        % ======================================================================                           
        function setDefaultTransducerMapping(obj, varargin)
            
            % Layout 17th May: 36 inch pipe
            trLayout = [
            1
            17
            13
            33
            5
            93
            49
            65
            61
            81
            77
            21
            25
            41
            37
            9
            29
            69
            73
            89
            85
            57
            53
            45
            2
            18
            14
            34
            6
            94
            50
            66
            62
            82
            78
            22
            26
            42
            38
            10
            30
            70
            74
            90
            86
            58
            54
            46
            3
            19
            15
            35
            7
            95
            51
            67
            63
            83
            79
            23
            27
            43
            39
            11
            31
            71
            75
            91
            87
            59
            55
            47
            4
            20
            16
            36
            8
            96
            52
            68
            64
            84
            80
            24
            28
            44
            40
            12
            32
            72
            76
            92
            88
            60
            56
            48
            ];                   

            obj.transducerLayout =  trLayout;                                                
            
        end

        %======================================================================
        %> @brief Function remaps the transducers according to the
        %> @brief transducer layout
        %> @brief        
        %> 
        %> @param obj instance of the ViewBluenoseData class.     
        % ======================================================================                   
        function remapTransducers(obj)
            
%             obj.callipRemappedM = obj.callipM(obj.transducerLayout,:);
%             obj.thicknessRemappedM = obj.thicknessM(obj.transducerLayout,:);            

            [m,n] = size(obj.callipM);
            obj.callipRemappedM = zeros(m,n);
            obj.thicknessRemappedM = zeros(m,n);
            obj.snrRemappedM =  zeros(m,n);
            
            for index = 1:numel(obj.transducerLayout)
                
                % Skip layout that is not set
                if(obj.transducerLayout(index) ~= 0)
                    obj.callipRemappedM(index,:) = obj.callipM(obj.transducerLayout(index),:);
                    obj.thicknessRemappedM(index,:) = obj.thicknessM(obj.transducerLayout(index),:);
                    obj.snrRemappedM(index,:) = obj.snrM(obj.transducerLayout(index),:);
                end
            end
                                
        end
        
        %======================================================================
        %> @brief Function alignes transducer channels according to ping
        %> @brief rate and tool speed
        %> @brief        
        %> 
        %> @param obj instance of the ViewBluenoseData class.     
        % ======================================================================           
        function alignTransducerMeasurements(obj)
                                    
            obj.calculateTransducerPingRate()
            
            % Position offset for each ring
            posArray = [0, 55.88, 111.76, 27.94, 83.82, 139.7]';
            
            % Position offset for each transducer
            posOffset = [posArray; posArray; posArray; posArray; ... 
                         posArray; posArray; posArray; posArray; ...
                         posArray; posArray; posArray; posArray; ...
                         posArray; posArray; posArray; posArray]; 
            
            % Convert mm
            posOffset = posOffset/1000;
            
            % Calculate number of samples offset pr channel
            obj.numberOfSamplesOffsetPrChannel = round((posOffset/obj.defaultToolSpeed)*obj.transducerPingRate);
            
            % Shift each channels so that they are aligned
            for index = 1:length(obj.transducerLayout)
                elementsToRemove = obj.numberOfSamplesOffsetPrChannel(index);
                
                tempThicknessM = obj.thicknessRemappedM(index,:);
                tempCalliperM = obj.callipRemappedM(index,:);
                
                tempSnrM = obj.snrRemappedM(index,:);
                
                if(elementsToRemove > 0)
                    % Remove elements in front
                    tempThicknessM(1:elementsToRemove) = [];
                    tempCalliperM(1:elementsToRemove) = [];
                    tempSnrM(1:elementsToRemove) = [];
                    % Append same amount of zeros to the end
                    tempThicknessM = [tempThicknessM zeros(1,elementsToRemove)];        
                    tempCalliperM = [tempCalliperM zeros(1,elementsToRemove)];        
                    tempSnrM = [tempSnrM zeros(1,elementsToRemove)];        
                end

                obj.thicknessRemappedM(index,:) = tempThicknessM; 
                obj.callipRemappedM(index,:) = tempCalliperM;
                obj.snrRemappedM(index,:) = tempSnrM;
            end                                                         
        end                
        
        %======================================================================
        %> @brief Function plots image of thickness and calliper
        %> @brief - First the transducer are remapped according to the layout
        %> @brief - The transducers channels are aligned according to ping
        %> @brief   rate and tool speed
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        % ======================================================================                 
        function [fig, imThickness, imCalliper] = plotImage(obj)
            
            % Remap transducers
            obj.remapTransducers();
            
            % Align transducers channels
            obj.alignTransducerMeasurements();
            
            
            scanDate = obj.ctrl.pr(1).date;
            scanDate.Format = 'dd-MMM-uuuu';            
            
            titleCalliper = sprintf('Calliper image %s tool speed %d', scanDate, obj.defaultToolSpeed);
            titleThickness = sprintf('Thickness image %s', scanDate);
            
            fig = figure
            %plot
            ax1 = subplot(2,1,1);
            climsThickness = [obj.ctrl.config.D_MIN obj.ctrl.config.D_NOM];
            imThickness = imagesc(obj.thicknessRemappedM, climsThickness);
            colorbar
            title(titleThickness)            
            
            ax2 = subplot(2,1,2);
            climsCalliper = [0.33 0.37];
            imCalliper = imagesc(obj.callipRemappedM, climsCalliper);
            colorbar
            title(titleCalliper)  
            
            linkaxes([ax1, ax2])               
        end              
        
        %======================================================================
        %> @brief Function lets user select a region in the figure image
        %>        by drawing a rectangle for selecting the area
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param transducerLines array of images lines
        %> @param startStop start and stop index        
        % ======================================================================          
        function [transducerLine startStop] = selectRegionInImage(obj)
            
            % Plot image of thickness and calliper
            figH  = obj.plotImage();
            
            % Get handle to axes for child 4 which is the thickness image
            axesH  = figH.Children(4);
            
            continueSelection = true;
            while(continueSelection)
            
                % Set class variables
                obj.figHandle = figH;
                obj.axesHandle = axesH;
                
                % Init 
                obj.pointsSelected = 0;
                figure(obj.figHandle)
                obj.figHandle.WindowButtonDownFcn = @obj.windowButtonDownFcn; 

                uiwait

                obj.rectxy1;
                obj.rectxy2;
                rowTemp = [obj.rectxy1(1) obj.rectxy2(1) ];
                colTemp = [obj.rectxy1(2) obj.rectxy2(2) ];
                minRow = min(rowTemp);
                maxRow = max(rowTemp);
                minCol = min(colTemp);
                maxCol = max(colTemp);
                               
                row = [ ceil(minRow) floor(maxRow) ];
                col = [ ceil(minCol) floor(maxCol) ];

                % Dialog
                continueSelection = obj.continueSelectionDialog(row, col);
            end
            
            startStop = [min(row) max(row)];
            transducerLine = [min(col) max(col)];                                 
        end
        
        %======================================================================
        %> @brief Function plots image transducer lines in a 2D
        %>        as a plot
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param lines array of images lines
        %> @param start start index
        %> @param stop stop index
        % ======================================================================          
        function plotImageLines(obj, lines, start, stop)
            
            figure
            for index = lines
                line = obj.thicknessRemappedM(index, start:stop);
                plot(line)
                hold on
            end
            hold off            
        end
        
        %======================================================================
        %> @brief Function plots image transducer lines in 3D
        %>        as a mesh plot
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param lines array of images lines
        %> @param start start index
        %> @param stop stop index
        % ======================================================================            
        function plotImageLines3D(obj, lines, start, stop)            
            figure
            mesh(obj.thicknessRemappedM(lines, start:stop));             
        end
        
        %======================================================================
        %> @brief Function get address of area
        %>        Use image from plotImage to find the area of interest.
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param lines array of images lines
        %> @param start start index
        %> @param stop stop index
        %> @retval dataAddress struct containing (file, shotIndex, prIndex,
        %>                                        shotCount
        % ======================================================================                 
        function dataAddress = getAddressOfArea(obj, transducerLine, startStop)
            
            if(2 == numel(startStop))
                start = startStop(1);
                stop = startStop(2);
            else
                start = startStop(1);
                stop = startStop(1);
            end
            
            % Init dataAddress struct
            dataAddress(numel(obj.ctrl.importHandler.dataFiles)) = ...
                struct('file',0,'shotIndex', [], 'prIndex', [], 'shotCount', 0);
            
            % Consider initilize shotIndex with zeros
            for fileIndex = 1:numel(obj.ctrl.importHandler.dataFiles)
                dataAddress(fileIndex).file = fileIndex;
                dataAddress(fileIndex).shotIndex = [];
                dataAddress(fileIndex).prIndex = [];
                dataAddress(fileIndex).shotCount = 0;
            end
            
            for index = 1:numel(transducerLine)
                transducerId = obj.transducerLayout(transducerLine(index));

                offset = obj.numberOfSamplesOffsetPrChannel(transducerLine(index));

                [pr, prIndexArray] = getTransducerPr(obj, transducerId);
                                
                prShot = pr(start+offset : stop+offset);
                prIndexShot = prIndexArray(start+offset : stop+offset);
                
                for shotindex = 1:numel(prShot)   
                    structIndex = prShot(shotindex).fileIndex;
                    dataAddress(structIndex).shotIndex(dataAddress(structIndex).shotCount + 1) = prShot(shotindex).shotIndex; 
                    dataAddress(structIndex).prIndex(dataAddress(structIndex).shotCount + 1) = prIndexShot(shotindex); 
                    dataAddress(structIndex).shotCount = dataAddress(structIndex).shotCount + 1;
                end                    
            end
        end
        
        %======================================================================
        %> @brief Function calculates average thickness of an area
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param lines array of images lines
        %> @param start start index
        %> @param stop stop index
        %> @retval averageThickness
        % ======================================================================   
        function averageThickness = calculateAverageThicknessOfArea(obj, transducerLine, startStop)
            
            if(2 == numel(startStop))
                start = startStop(1);
                stop = startStop(2);
            else
                start = startStop(1);
                stop = startStop(1);
            end
            
            thicknessPrTr = zeros(numel(transducerLine), (stop-start + 1) );
            for index = 1:numel(transducerLine)
                transducerId = obj.transducerLayout(transducerLine(index));

                offset = obj.numberOfSamplesOffsetPrChannel(transducerLine(index));

                [pr, prIndexArray] = getTransducerPr(obj, transducerId);
                                
                prShot = pr(start+offset : stop+offset);
                thicknessPrTr(index, :) = double([prShot.thickness])  ;               
            end
            
            averageThickness = mean(mean(thicknessPrTr));
        end        
        
        %======================================================================
        %> @brief Function plots image of Signal to Noise Ratio
        %> @brief - First the transducer are remapped according to the layout
        %> @brief - The transducers channels are aligned according to ping
        %> @brief   rate and tool speed
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        % ======================================================================         
        function plotImageSNR(obj)

            % Remap transducers
            obj.remapTransducers();

            % Align transducers channels
            obj.alignTransducerMeasurements();

            scanDate = obj.ctrl.pr(1).date;
            scanDate.Format = 'dd-MMM-uuuu';            

            figure
            titleSNR= sprintf('SNR image %s', scanDate);
            climsSNR = [0 50];
            imagesc(obj.snrRemappedM, climsSNR);
            colorbar
            title(titleSNR)    
        end
        
        function plotSurface(obj)
            % Remap transducers
            obj.remapTransducers();
            
            % Align transducers channels
            obj.alignTransducerMeasurements();
            
            scanDate = obj.ctrl.pr(1).date;
            scanDate.Format = 'dd-MMM-uuuu';            
            
            titleCalliper = sprintf('Calliper image %s', scanDate);
            titleThickness = sprintf('Thickness image %s', scanDate);
            
            figure
            surface(obj.thicknessRemappedM)
            title(titleThickness)
            shading interp

            figure
            surface(obj.callipRemappedM)
            title(titleCalliper)
            shading interp                        
        end
        
        function  plotSelectedAreaCalliper(obj, trLines, startStopIndex)
            figure
            surface(obj.callipRemappedM(trLines(1):trLines(2), startStopIndex(1):startStopIndex(2)))
            scanDate = obj.ctrl.pr(1).date;
            scanDate.Format = 'dd-MMM-uuuu';            
            
            titleCalliper = sprintf('Calliper image %s', scanDate);
            
            title(titleCalliper)
            shading interp      
            grid on;grid minor;
        end

        %======================================================================
        %> @brief Function returns the ProcessResult object for a given
        %> @brief point on the thickness/calliper image
        %> @brief 
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param xIndex shotIndex
        %> @param yIndex transducerLine
        %> @return pr ProcessingResult object for the requested point on
        %>       image        
        % ======================================================================                 
        function [prShot] = getPrFromImageCoordinate(obj, shotIndex, transducerLine)
            
            transducerId = obj.transducerLayout(transducerLine);
            
            offset = obj.numberOfSamplesOffsetPrChannel(transducerLine);
            
            [pr] = getTransducerPr(obj, transducerId);
            
            prShot = pr(shotIndex+offset);
            
        end
        
        %======================================================================
        %> @brief Function plots roll and pitch for given transducer
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param transducerId TransducerId
        % ======================================================================                         
        function plotRollPitch(obj, transducerId)
            
            [pr] = getTransducerPr(obj, transducerId);
            
            roll = [pr.roll]/100;
            pitch = [pr.pitch]/100;
            
            scanDate = obj.ctrl.pr(1).date;
            scanDate.Format = 'dd-MMM-uuuu';            
            
            titleRoll = sprintf('Roll transducer %d %s', transducerId, scanDate);
            titlePitch = sprintf('Pitch transducer %d %s', transducerId, scanDate);
            
            figure
            
            ax1 = subplot(2,1,1);
            plot(roll)
            ylabel('Degree')
            title(titleRoll)
            grid on
            
            ax2 = subplot(2,1,2);            
            plot(pitch)
            title(titlePitch)
            ylabel('Degree')
            grid on
            
            linkaxes([ax1, ax2],'x')               
        end
                       
        %======================================================================
        %> @brief Function finds all the transducerIds used in the
        %> @brief recording       
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        %> @retrun transducerId TransducerIds       
        % ====================================================================== 
        function transducerIds = findNumberOfTransducers(obj)
            % Init
            transducerIds = obj.ctrl.pr(1).transducerId;

            % Find all transducerIds
            for i = 1:numel(obj.ctrl.pr)
                if(~(transducerIds == obj.ctrl.pr(i).transducerId))
                    transducerIds = ([transducerIds obj.ctrl.pr(i).transducerId]);
                end
            end

            % Keep the unique ones
            transducerIds = unique(transducerIds);            
            obj.transducerIds = transducerIds;            
        end
        
        %======================================================================
        %> @brief Function        
        %> 
        %> @param
        %> @param
        %> @param
        %> @param
        %> @return
        %> @return
        % ======================================================================         
        function [eObj, calliperArray] = calculateRingPosition(obj, dataIndex, ringTransducerIds, enablePlot)
            import ppPkg.EllipseFit;
            
            transducerAtDeadCenter = 59;
            angleBetweenEachTransducer = 360/obj.numTransducers;
            
            calliperIndex = zeros(1,numel(ringTransducerIds));
                        
            iter  = 1;
            for i = 1:numel(ringTransducerIds)
                temp = find(obj.transducerLayout == ringTransducerIds(i));            
                if(~isempty(temp))
                   calliperIndex(iter) = temp; 
                   iter = iter + 1;
                end
            end
            calliperIndex(iter:end) = [];

            callipRemappedM_ = obj.callipRemappedM(:,dataIndex);
            
            % Get calliper for given transducers on given ring
            % TODO should add dimension of tool to calliper 
            calliperArray = callipRemappedM_(calliperIndex) + 7.5*0.0254/2 ;
            
            if(sum(calliperArray ~= 0) < 5)
                eObj = [];
                return
            end
            
            % Only use the ones that are closest to median
            % Disregard all measurements that deviate more than
            allowedDeviation = 1/100;
            
            logicArray = abs(calliperArray-mean(calliperArray))/mean(calliperArray) < allowedDeviation;
            if(sum(logicArray) > 10)
                calliperArray = calliperArray(logicArray);
                calliperIndex = calliperIndex(logicArray);
            end
            
            % Angle from dead center transducer
            angleArray = (calliperIndex-transducerAtDeadCenter) * angleBetweenEachTransducer;
            
            % Init
            pointOnPipeWall = zeros(numel(calliperArray), 2);

            % Calculate point (x,y) on pipe wall
            for index = 1:numel(calliperArray)  
                pointOnPipeWall((index),1) = calliperArray(index) * cos(angleArray(index)*pi/180 + pi/2);        
                pointOnPipeWall((index),2) = calliperArray(index) * sin(angleArray(index)*pi/180 + pi/2);        
            end
            
            % Get EllipseFit object
            eObj = EllipseFit;
            
            % Compute Ellipse
            eObj.computeEllipseEstimate(pointOnPipeWall);
            
            if(enablePlot)
                figure
                eObj.plotData(pointOnPipeWall);
                
                %for index = 1:numel(ringTransducerIds)
                for index = 1:numel(calliperIndex)
                    
                    %txt = sprintf('%d', ringTransducerIds(index));
                    txt = sprintf('%d', calliperIndex(index));
                    text(pointOnPipeWall(index,1),pointOnPipeWall(index,2),txt );
                    
                end


                %distDeviation = eObj.computeDistanceToEllipse(dataPoint);

                hold on

                eObj.plotToolCircle(0.20574)
                hold off
                
                legend('Pipe wall', 'pipe center','points measured', 'tool')
            end
        end
        
        %======================================================================
        %> @brief Function calculates tool position in pipe based calliper data 
        %> @brief for ring1 and ring2 and draws tools position in the pipe
        %> @brief as viewed from ring1 and ring2
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        %> @param shotIndex
        % ======================================================================         
        function calculateToolPositionAtIndex(obj,  shotIndex )
            
            enablePlot = 1;
                
            obj.calculateRingPosition(shotIndex, obj.ring1, enablePlot);              
            title('Ring 1')
            
            obj.calculateRingPosition(shotIndex, obj.ring6, enablePlot);
            title('Ring 6')            
        end
                
        %======================================================================
        %> @brief Function calculates tool position through pipe
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        % ======================================================================                 
        function calculateToolPositionThroughPipe(obj)

            % Find number of active transducers
            obj.findNumberOfTransducers();
            numActiveTransducers = numel(obj.transducerIds);
            
            % Calculate number of shots pr transducers
            numShotsPrTransducer = round(numel(obj.ctrl.pr)/numActiveTransducers);
            
            
            xc1Array_ = zeros(1,numShotsPrTransducer);
            yc1Array_ = zeros(1,numShotsPrTransducer);
            xc6Array_ = zeros(1,numShotsPrTransducer);
            yc6Array_ = zeros(1,numShotsPrTransducer);

            posIndex = 1;
            enablePlot = 0;
            for dataIndex = 1:1:numShotsPrTransducer%12000%length(MC)

                dataIndex
                [r1, ~] = obj.calculateRingPosition(dataIndex, obj.ring1, enablePlot);    
                [r6, ~] = obj.calculateRingPosition(dataIndex, obj.ring6, enablePlot);
                
                if( isempty(r1) || isempty(r6) )
                    continue
                end

                xc1Array_(posIndex) = r1.xc;
                yc1Array_(posIndex) = r1.yc;
                xc6Array_(posIndex) = r6.xc;
                yc6Array_(posIndex) = r6.yc;

                posIndex = posIndex + 1;

            end    
            
            obj.xc1Array = xc1Array_;
            obj.yc1Array = yc1Array_;
            obj.xc6Array = xc6Array_;
            obj.yc6Array = yc6Array_;
        end
        
        %======================================================================
        %> @brief Function plot Tool Position through pipe
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        % ======================================================================                         
        function plotToolPositionThroughPipe(obj)
            
            % If empty, calculate tool position
            if(isempty(obj.xc1Array ))
                obj.calculateToolPositionThroughPipe();
            end
            figure
            
            ax1 = subplot(2,1,1);
            plot(-obj.xc1Array*1000)
            hold on
            plot(-obj.xc6Array*1000)
            title('x position')
            ylabel('mm')
            xlabel('shot')
            grid on
            legend('Ring1','Ring6')

            ax2 = subplot(2,1,2);
            plot(-obj.yc1Array*1000)
            hold on
            plot(-obj.yc6Array*1000)
            title('y position')
            ylabel('mm')
            xlabel('shot')
            grid on
            legend('Ring1','Ring6')
            
            linkaxes([ax1 ax2])
        end
        
        %======================================================================
        %> @brief Function retrieves ProcessingResult for requested
        %> @brief transducer id
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        %> @param transducerId TransducerId       
        % ====================================================================== 
        function [pr, prIndexArray] = getTransducerPr(obj, transducerId)

            import ppPkg.*

            numActiveTransducers = numel(obj.transducerIds);
            
            % Calculate number of shots pr transducers
            numShotsPrTransducer = round(numel(obj.ctrl.pr)/numActiveTransducers);

            pr(numShotsPrTransducer) = ProcessingResult; 
            prIndexArray = zeros(1, numShotsPrTransducer);

            prIndex = 1;
            for i = 1:length(obj.ctrl.pr)
                if(obj.ctrl.pr(i).transducerId == transducerId)
                    pr(prIndex) = obj.ctrl.pr(i);
                    prIndexArray(prIndex) = i;
                    prIndex = prIndex + 1;
                end
            end
        end    
        
        
        
        %======================================================================
        %> @brief Test function      
        %> 
        %> @param 
        %> @param 
        % ======================================================================                 
        function [dev,a ] = plotDeviationFromGivenRange(obj, transducerId, startIndex, stopIndex, minLimit, maxLimit)
            
            [pr] = getTransducerPr(obj, transducerId);
            
            dev.shotIndex = [];
            dev.index = [];
            dev.thickness = [];
            indexMatch = 1;
            for i = startIndex:1:stopIndex

                if( pr(i).thickness < minLimit || pr(i).thickness > maxLimit )
                    dev.thickness(indexMatch) = pr(i).thickness;
                    dev.index(indexMatch) = i;
                    dev.shotIndex(indexMatch) = pr(i).shotIndex;
                    indexMatch = indexMatch + 1;
                end

            end

            a = [dev.index' dev.shotIndex' dev.thickness'];

            figure
            plot([pr.thickness])
            grid on
            hold on
            plot([dev.index], [pr(dev.index).thickness] ,'o')            
        end
        
        %======================================================================
        %> @brief Function plot thickness and calliper for requested
        %> @brief transducer id        
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        %> @param transducerId TransducerId       
        % ======================================================================         
        function plotTransducer(obj, transducerId)
            
            if(~(obj.transducerIds == transducerId))
                disp('No data from this transducer')
                return
            end
            
            % Get ProcessingResult for transducerId
            [pr] = getTransducerPr(obj, transducerId);
            
            class = [pr.class];
            thickness = [pr.thickness];
            z = zeros(size(class));

            map = [0, 0, 1
                   0, 1, 0
                   0, 1, 1
                   1, 0, 0];           
               
            colorArray = zeros(size(class));
            for index = 1:numel(class)
                if(isempty(pr(index).class))
                    pr(index).class = 'D';
                end
                switch(pr(index).class)
                    case 'A'                
                        colorArray(index) = 1;        
                    case 'B'
                        colorArray(index) = 2;        
                    case 'C'
                        colorArray(index) = 3;        
                    case 'D'
                        colorArray(index) = 4;   
                    otherwise
                        disp('error')
                end
            end

            x = 1:numel(class);

            figure
            colormap(map)
            
            scanDate = pr(1).date;
            scanDate.Format = 'dd-MMM-uuuu';

            sh(1) = subplot(2,1,1);
            plot([pr.calliper])
            titleCalliper = sprintf('Calliper for transducerId %d: %s', transducerId, scanDate);
            title(titleCalliper)
            grid on

            sh(2) = subplot(2,1,2);    
            titleThickness = sprintf('Thickness for transducerId %d: %s', transducerId, scanDate);
            title(titleThickness)
            
            surface([x;x],[thickness;thickness],[z;z],[colorArray;colorArray],...
                'facecol','no',...
                'edgecol','interp',...
                'linew',1);
            grid on

            linkaxes(sh,'x')             
        end  

        %======================================================================
        %> @brief Function plot line
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        %> @param 
        % ======================================================================                         
        function plotLine(obj, transducerLine)
            figure
            plot(obj.thicknessRemappedM(transducerLine,:))
            grid on
        end    
        
        %======================================================================
        %> @brief Function for plotting SNR for each group
        %> 
        %> @param obj instance of the ViewBluenoseData class. 
        %> @param groupId Group id
        % ======================================================================                         
        function plotGroupSNR(obj, groupId)
            
            if(groupId < 0 || groupId > 3)
                error('Currently only supporting groupID between 0 and 3')
            end
            
            transducers = (1:8) + 8 * groupId;
            
            figure
            iter = 1;
            for trId = transducers
                [pr] = getTransducerPr(obj, trId);
                legendText(iter) = {num2str(trId)}; 
                iter = iter + 1;
                plot([pr.snr])
                hold on
            end
            hold off
            grid on
            ylim([0 55])
            legend(legendText)
            titleTxt = sprintf('SNR for transducers with groupId %d', groupId);
            title(titleTxt)
        
        end
    end    
    
    methods (Hidden = true)      
            
        %======================================================================
        %> @brief Function extracts data from ProcessingResults and
        %> @brief creates a matrix for thickness and calliper
        %> 
        %> @param obj instance of the ViewBluenoseData class.      
        % ======================================================================         
        function extractResultToMatrix(obj)

            % Find number of active transducers
            obj.findNumberOfTransducers();
            numActiveTransducers = numel(obj.transducerIds);

            % Calculate number of shots pr transducers
            numShotsPrTransducer = round(numel(obj.ctrl.pr)/numActiveTransducers);

            % Init matrix
            obj.callipM = zeros(obj.numTransducers, numShotsPrTransducer);
            obj.thicknessM = zeros(obj.numTransducers, numShotsPrTransducer);
            obj.noiseM = zeros(obj.numTransducers,numShotsPrTransducer);

            obj.snrM =  zeros(obj.numTransducers,numShotsPrTransducer);
            counterIndex = ones(obj.numTransducers,1);

            % Iterate through Processing Result to extract data
            for index = 1:length(obj.ctrl.pr)

                trId = obj.ctrl.pr(index).transducerId;
                obj.callipM(trId, counterIndex(trId)) = obj.ctrl.pr(index).calliper;
                obj.thicknessM(trId, counterIndex(trId)) = obj.ctrl.pr(index).thickness;
                obj.snrM(trId, counterIndex(trId)) = obj.ctrl.pr(index).snr; 
                if(~isnan(obj.ctrl.pr(index).noiseMean))
                    obj.noiseM(trId, counterIndex(trId)) = obj.ctrl.pr(index).noiseMean;    
                end
                counterIndex(trId) = counterIndex(trId) + 1;
            end                                    
        end            

        %======================================================================
        %> @brief Function pop up a dialog regarding user accepting
        %>        selection
        %>                         
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param row
        %> @param col
        % ======================================================================          
        function selectionFlag = continueSelectionDialog(obj, row, col)

            % Pop up a dialog                         
            txt = sprintf('You have selected: Transducers %d to %d, shot %d to %d\nKeep selection?', ...
                           min(col), max(col), min(row), max(row) );

            ButtonName = questdlg( ...
              txt,'Dialog', ...
              'Yes','Redo Selection','Yes');

            switch ButtonName
                case 'Yes'
                    % we can drop through
                    selectionFlag = false;

                case 'Redo Selection'
                    % or try again. The while loop will cycle
                    % until happy or canceled
                    selectionFlag = true;                    
                    children = get(gca, 'children')
                    delete(children(1))                    
            end            
        end        

        %======================================================================
        %> @brief Callback function: WindowButtonDownFcn 
        %>                         
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param src
        %> @param eventData
        % ======================================================================                  
        function windowButtonDownFcn(obj, src, eventData)
            seltype = src.SelectionType;                       

            if(strcmp(seltype,'normal'))
                src.Pointer = 'cross';
                cp = obj.axesHandle.CurrentPoint;

                disp('button down')
                if(obj.pointsSelected == 0)
                    obj.rectxy1 = (cp(1,1:2));
                    obj.rectxy2 = obj.rectxy1 + eps(obj.rectxy1);

                    obj.rectxy1(2) = round(obj.rectxy1(2)-0.5)+0.5;
                    obj.rectxy1(1) = round(obj.rectxy1(1)-0.5)+0.5;
                    obj.rectxy2(2) = round(obj.rectxy2(2)-0.5)+0.5;
                    obj.rectxy2(1) = round(obj.rectxy2(1)-0.5)+0.5;

                else                    
                    obj.rectxy2 =  (cp(1,1:2));                    
                    obj.rectxy2(2) = round(obj.rectxy2(2)-0.5)+0.5;
                    obj.rectxy2(1) = round(obj.rectxy2(1)-0.5)+0.5;                    
                end

                % Make rect
                xv = [obj.rectxy1(1), obj.rectxy2(1), obj.rectxy2(1), obj.rectxy1(1), obj.rectxy1(1)];
                yv = [obj.rectxy1(2), obj.rectxy1(2), obj.rectxy2(2), obj.rectxy2(2), obj.rectxy1(2)];

                obj.hl = line('XData',xv,'YData',yv,...
                 'Marker','none','color','black','LineStyle','--');                 


                src.WindowButtonMotionFcn = @obj.windowButtonMotionFcn;
                src.WindowButtonUpFcn = @obj.windowButtonUpFcn;                                                             
            end                            
        end

        %======================================================================
        %> @brief Callback function: WindowButtonMotionFcn
        %>                         
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param src
        %> @param eventData
        % ======================================================================          
        function windowButtonMotionFcn(obj, src, eventData)

            % Current point
            cp = obj.axesHandle.CurrentPoint;                           
            obj.rectxy2 = (cp(1,1:2));

            % make sure the axes are fixed
            %axis(axissize)
            obj.rectxy2(2) = round(obj.rectxy2(2)-0.5)+0.5;
            obj.rectxy2(1) = round(obj.rectxy2(1)-0.5)+0.5;

            % update the rect of the box, changing the second corner
            xv = [obj.rectxy1(1), obj.rectxy2(1), obj.rectxy2(1), obj.rectxy1(1), obj.rectxy1(1)];
            yv = [obj.rectxy1(2), obj.rectxy1(2), obj.rectxy2(2), obj.rectxy2(2), obj.rectxy1(2)];                   

            obj.hl.XData = xv;
            obj.hl.YData = yv;            

            drawnow                   
        end

        %======================================================================
        %> @brief Callback function: WindowButtonUpFcn
        %>                         
        %> @param obj instance of the ViewBluenoseData class.      
        %> @param src
        %> @param eventData
        % ======================================================================           
        function windowButtonUpFcn(obj, src, eventData)

            obj.pointsSelected = obj.pointsSelected + 1;

            if(obj.pointsSelected == 1)
                src.Pointer = 'arrow';
                src.WindowButtonMotionFcn = '';
                src.WindowButtonUpFcn = '';
                src.WindowButtonDownFcn = '';       
                uiresume
            end
        end 
    end
end

