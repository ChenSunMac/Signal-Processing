%> @file CalliperAlgorithm.m
%> @brief Contain algorithm for calculating calliper distance
% ======================================================================
%> @brief Contain algorithm for calculating calliper distance
%
%> 
% ======================================================================
classdef CalliperAlgorithm < matlab.mixin.Copyable

    properties                 
        adjustBeginMain;
        adjustEndMain;
        firstReflectionIndex;
        secondReflectionIndex;
        nextReflectionFound = false;
        callipDistance;
        signal_delay
    end    

    properties (Access = private)
        txPulseSet = false;
    end
    
    properties (SetAccess = private)
        config
        txPulse
    end
    
    methods
        % ======================================================================
        %> @brief Class constructor
        %>
        %> @param config Configuration object        
        %> @return instance of the CalliperAlgorithm class.
        % ======================================================================        
        function obj = CalliperAlgorithm(config)
            import ppPkg.Configuration;
                        
            if nargin == 1            
                
                if(isa(config,'Configuration'))
                    obj.config = config;
                    obj.txPulseSet = false;
                else
                    error('CalliperAlgorithm constructor: Configuration object is of wrong type')
                end     
                            
            else 
                error('Not enough arguments to constuct CalliperAlgorithm object')
            end            
        end  
        
        % ======================================================================
        %> @brief Set function for config
        %>
        %> @param obj instance of the CalliperAlgorithm class.
        %> @param configuration Configuration object                
        % ======================================================================              
        function setConfiguration(obj, configuration)
           obj.config = configuration; 
        end            
        
        % ======================================================================
        %> @brief Set transmitted pulse
        %>
        %> @param obj instance of the CalliperAlgorithm class.
        %> @param txPulse Array containing emitted pulse
        % ======================================================================   
        function setTxPulse(obj, txPulse)
            obj.txPulse = txPulse;
            obj.txPulseSet = true;
        end
       
        % ======================================================================
        %> @brief Compute adjustment in number of samples to begin index
        %>         and end index for calculation for the main spectrum        
        %>
        %>       Function uses findpeaks function to check if there are
        %>       more than one main reflection. If there are two reflections
        %>       of the emitted pulse the distance between these two peaks
        %>       is calculated. This can give an indication of the pit dept
        %>       
        %>
        %> @param obj instance of the CalliperAlgorithm class.
        %> @param xcorrResult Cross correlation result
        %> @param indexMax Index of highest peak in xcorr
        %> @param valueMax Value of highest peak
        %> @return adjustBeginMain Adjustment to begin main
        %> @return adjustEndMain Adjustment to end main
        %> @return indexSecondPeak Index to second highest peak
        % ======================================================================         
        function [adjustBeginMain, adjustEndMain, indexSecondPeak] = calculateStartStopAbsorption(obj, xcorrResult, indexMax, valueMax )
         
        % TODO: need to verify that this function. Verify that the adjustment of Main works as intended.     
            
            % Configuration parameters:
            SEARCH_RANGE = round((obj.config.NOMINAL_DISTANCE_TO_WALL/(3*obj.config.V_WATER))*obj.config.SAMPLE_RATE);
            
            % Calculated minimum peak distance
            pitDept = 0.002;
            peakDistance = (pitDept * obj.config.SAMPLE_RATE * 2) / obj.config.V_WATER  ;
            
            adjustBeginMain = 0;
            adjustEndMain = 0;
            indexSecondPeak = indexMax;
            
            if(indexMax + SEARCH_RANGE > length(xcorrResult) )
                % index is to large
                % Do nothing
               
            else
            
                r_subset = xcorrResult(indexMax - SEARCH_RANGE:indexMax + SEARCH_RANGE);

                % Plot
                %figure
                %findpeaks(r_subset,'SortStr','descend','NPeaks', 2, 'MinPeakHeight',valueMax/4, 'MinPeakDistance',  peakDistance);

                minPeakHeight = double(valueMax*0.6);
                
                [peak, locs] = findpeaks(double(r_subset),'SortStr','descend','NPeaks', 2, 'MinPeakHeight',minPeakHeight, 'MinPeakDistance',  peakDistance);
                %findpeaks(double(r_subset),'NPeaks', 2, 'MinPeakHeight',minPeakHeight, 'MinPeakDistance',  peakDistance);
                
                if(numel(locs) == 2)

                    delta = abs(locs(1)-locs(2));
                    if(locs(1)<locs(2))
                        adjustEndMain = delta;        
                    elseif(locs(1)>locs(2))
                        adjustBeginMain = delta;
                    end
                    
                    if( peak(1) > peak(2))
                        indexSecondPeak = locs(2) + indexMax - SEARCH_RANGE - 1;
                    else
                        indexSecondPeak = locs(1) + indexMax - SEARCH_RANGE - 1;
                    end
                end  
            
            end
            obj.adjustBeginMain = adjustBeginMain;
            obj.adjustEndMain = adjustEndMain;
            
        end
        
        % ======================================================================
        %> @brief Calculates calliper distance
        %>
        %> Function uses cross correclation between emitted pulse and recorded 
        %> transducer signal to compute time of flight and distance to pipe wall.
        %> 
        %>
        %> @param obj instance of the CalliperAlgorithm class.
        %> @param delay Delay in number of samples in received signal
        %>              before calculating cross correlation
        %> @param receivedSignal Recorded transducer signal        
        %> @param deltaTimeBeforeRecordingIsStarted Time in number if samples 
        %>              between fire is shot and recording is started        
        %> @retval distance Calliper distance
        %> @retval firstReflectionIndex Index to first reflection
        %> @retval nextReflectionIndex Index to second reflection
        %> @retval pitDept Pit dept detected ( experimental )
        % ======================================================================
        function [distance, firstReflectionIndex, secondReflectionIndex, pitDept] = calculateDistance(obj, delay, receivedSignal, deltaTimeBeforeRecordingIsStarted)
        
            pitDept = 0;
           
            if(false == obj.txPulseSet )
                error('Transmitted pulse is not set')
            end
            
            startIndex = 1 + delay;
            % Calculate the cross correlation between received pulse and
            % transmitted pulse. 
            [r, lags] = xcorr(receivedSignal(startIndex:end), obj.txPulse);

            % Find the index where the cross correlation is at its
            % maximum            
            [valueMax, indexMax] = max(r);
            
             
            if( valueMax < 1e-4 ) 
                obj.firstReflectionIndex = 0;
                obj.secondReflectionIndex = 0;
                obj.callipDistance = -1;  
                distance = -1;
                firstReflectionIndex = 0;
                secondReflectionIndex = 0;
                return
            end
            % Calculate adjustement to start and stop index of
            % absorption spectrum. Also find index to second highest peak
            % if second peak is higher than X times valueMax
            [~,~, indexSecondPeak] = obj.calculateStartStopAbsorption(r, indexMax, valueMax);
            
            % Find the lag (delay) at this index in number of samples.            
            lagInterpolateHighestPeak = findLagUsingInterpolation(obj, r, lags, indexMax);            
            firstReflectionIndex = delay + round(lagInterpolateHighestPeak);                        
                       
            % Experiment: Find pit dept. "Edge detection"
            if(indexSecondPeak ~= indexMax)
                % Interpolate
                lagInterpSecondPeak = findLagUsingInterpolation(obj, r, lags, indexSecondPeak);                                                
                
                pitDept = ((lagInterpSecondPeak - lagInterpolateHighestPeak) * obj.config.V_WATER) / ( 2 * obj.config.SAMPLE_RATE );
            end
            
            % Experiment: Find next reflection            
            delayNumberSamples = (obj.config.NOMINAL_DISTANCE_TO_WALL/obj.config.V_WATER)*obj.config.SAMPLE_RATE;
            
            % Dont calculate nextReflecationIndex if receivedSignal is too short.  
            if(firstReflectionIndex + delayNumberSamples < length(receivedSignal))
                
                % Search for next peak in the crosscorrelation which should
                % then be the second reflection.            
                [~, indexNextMax] = max((r(indexMax + delayNumberSamples :end)));                                        
                secondReflectionIndex =  delay + indexMax + delayNumberSamples + lags(indexNextMax); 
                obj.nextReflectionFound = true;
            else
                % Set nextReflectionIndex to be end at signal
                secondReflectionIndex = length(receivedSignal);
                obj.nextReflectionFound = false;
            end
                             
            % Calculate total travel time for transmitted signal. 
            obj.signal_delay = delay+lagInterpolateHighestPeak + deltaTimeBeforeRecordingIsStarted;

            % Calculate distance to pipe wall from transducer d = (v*t)/(2*Fs)
            distance = single(obj.signal_delay) * obj.config.V_WATER / ( 2 * obj.config.SAMPLE_RATE );
            
            % Set class properties
            obj.firstReflectionIndex = firstReflectionIndex;
            obj.secondReflectionIndex = secondReflectionIndex;
            obj.callipDistance = distance;                        
        end  

        % ======================================================================
        %> @brief Find a better approximation to peak index by using
        %>        interpolation
        %>
        %>        Function uses an interpolation factor of 8 and uses 3
        %>        data samples before and after peak index when
        %>        interpolating
        %>
        %> @param obj instance of the CalliperAlgorithm class.
        %> @param xcorrResult Cross correlation result
        %> @param samplePoints signal to interpolate
        %> @param indexMax Index to maximum peak in signal
        %> @retval pitDept Pit dept detected ( experimental )
        % ======================================================================
        function lag = findLagUsingInterpolation(obj, xcorrResult, samplePoints, indexMax)

            % Number of point before and after max peak
            deltaPoint = 4;

            % Number of quary points for each sample
            interpolation_factor = 10;

            startIndex = indexMax-deltaPoint;
            if(startIndex < 1)
                startIndex = 1;
            end

            stopIndex = indexMax+deltaPoint;
            startRange = samplePoints(startIndex);
            stopRange = samplePoints(stopIndex);    

            %% Retrieve small segment including max peak
            % Segment sample points
            segmentRange = startIndex:1:stopIndex;
            % Segment sample values
            r_segment = xcorrResult(segmentRange);

            %% Create quary vector
            % Quary segment sample points
            interpolationRange = startRange:1/interpolation_factor:stopRange;     
            x_segmentRange = startRange:1:stopRange;

            r_interp = interp1(x_segmentRange, r_segment,interpolationRange,'spline');

            % Draw figure
%             figure
%             plot(x_segmentRange, r_segment,'o',interpolationRange,r_interp,':.');    
%             title('Spline Interpolation');

            % Find index for max peak for the interpolated curve
            [~,I_intep] = max(r_interp);

            % Find lag at this index
            lag = interpolationRange(I_intep);

        end        
    end    
end



