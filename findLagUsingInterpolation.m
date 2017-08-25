        function lag = findLagUsingInterpolation(xcorrResult, samplePoints, indexMax)

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

            % Find index for max peak for the interpolated curve
            [~,I_intep] = max(r_interp);

            % Find lag at this index
            lag = interpolationRange(I_intep);

        end     