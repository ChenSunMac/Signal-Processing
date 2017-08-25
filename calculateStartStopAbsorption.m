function [adjustBeginMain, adjustEndMain, indexSecondPeak] = calculateStartStopAbsorption(SEARCH_RANGE, peakDistance, xcorrResult, indexMax, valueMax )
         
            adjustBeginMain = 0;
            adjustEndMain = 0;
            indexSecondPeak = indexMax;
            r_subset = xcorrResult(indexMax - SEARCH_RANGE:indexMax + SEARCH_RANGE);

            minPeakHeight = double(valueMax*0.6); % Set a bar with 60% of the maximum peak
                
            [peak, locs] = findpeaks(double(r_subset),'SortStr','descend','NPeaks', 2, 'MinPeakHeight',minPeakHeight, 'MinPeakDistance',  peakDistance);
       
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