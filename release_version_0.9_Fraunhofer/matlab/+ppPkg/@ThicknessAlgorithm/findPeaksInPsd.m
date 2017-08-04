function [peakLocation, peakValue, peakWidth, peakProminence] = findPeaksInPsd(obj, type, fLow, fHigh, method, varargin)
%findPeaksInPsd - Find peak frequencies in the Power Spectral density
%
% Syntax:  [peakLocation, peakValue, peakWidth, peakProminence] = findPeaksInPsd(obj, type, fLow, fHigh, method)
%
% Inputs:
%    type - 'obj.RESONANCE' or 'obj.RESONANCE'
%    fLow - Lower frequency 
%    fHigh - Higher frequency
%    method
%
% Outputs:
%    peakLocation   - Peak index
%    peakValue      - Peak heigth
%    peakWidth      - 3dB peak width
%    peakProminence - Peak prominence
%
% Example: 
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
% Other m-files required: ThicknessAlgorithm.m class
% Subfunctions: none
% MAT-files required: none
%


    import ppPkg.*
    % Find maximum peak in dB from fLow.
    % First find start index to search from. 
    startSearchIndex = double((1 + floor(fLow/(obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH))));
    stopSearchIndex = double((1 + floor(fHigh/(obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH))));

    obj.startPeakSearchIndex = startSearchIndex;
    obj.stopPeakSearchIndex = stopSearchIndex;

    % Type check
    if(obj.RESONANCE == type)
        psd = obj.psdResonance;                
    elseif(obj.MAIN == type)
        
        psd = -obj.psdMain;
    else
        error('Ilegal type %d', type');
    end


    switch method

        case PeakMethod.MIN_DB_ABOVE_NOISE                     
            % Using restriction "Minimum peak height"
            disp('Using findpeaks with "MinPeakHeight"')
            [peakValue, peakLocation, peakWidth, peakProminence] = findpeaks(psd(startSearchIndex:stopSearchIndex), 'MinPeakHeight',(obj.meanNoiseFloor+obj.config.Q_DB_ABOVE_NOISE));
            peakLocation = peakLocation + startSearchIndex - 1 ;

        case PeakMethod.MIN_PEAK_DISTANCE_AND_MIN_DB_ABOVE_NOISE
            % Using restrictions "Minimum peak distance" and "Minimum peak heigth" 
            disp('Using findpeaks with "MinPeakDistance" and "MinimumPeakHeigth" ')
            freqFundamentalMinimum = obj.config.V_PIPE/(2*obj.config.D_NOM);
            minPeakDistance = floor(freqFundamentalMinimum/(obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH));

            [peakValue, peakLocation, peakWidth, peakProminence] = findpeaks(psd(startSearchIndex:stopSearchIndex),'MinPeakDistance',minPeakDistance ,'MinPeakHeight',(obj.meanNoiseFloor+obj.config.Q_DB_ABOVE_NOISE));
            peakLocation = peakLocation + startSearchIndex - 1 ;
            
        case PeakMethod.TEST
            % Using restrictions "Minimum peak distance" and "Minimum peak heigth" 
            disp('Using findpeaks with "MinPeakDistance" and "MinimumPeakHeigth" ')
            freqFundamentalMinimum = obj.config.V_PIPE/(2*obj.config.D_NOM);
            minPeakDistance = floor(freqFundamentalMinimum/(obj.config.SAMPLE_RATE/obj.config.FFT_LENGTH));

            [peakValue, peakLocation, peakWidth, peakProminence] = findpeaks(psd(startSearchIndex:stopSearchIndex),'MinPeakDistance',minPeakDistance ,'MinPeakProminence',obj.config.PROMINENCE, 'MinPeakHeight',(obj.meanNoiseFloor+obj.config.Q_DB_ABOVE_NOISE));
            peakLocation = peakLocation + startSearchIndex - 1 ;            
            
        case PeakMethod.MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE
            % Using restrictions "Minimum Peak Prominence" and "Minimum peak heigth" 
            [peakValue, peakLocation, peakWidth, peakProminence] = findpeaks(psd(startSearchIndex:stopSearchIndex),'MinPeakProminence',obj.config.PROMINENCE, 'MinPeakHeight',(obj.meanNoiseFloor+obj.config.Q_DB_ABOVE_NOISE));                
            peakLocation = peakLocation + startSearchIndex - 1 ;            

        case PeakMethod.N_HIGEST_PEAKS
            % Find the N highest peaks. N should be based on the
            % nominal thickness. 
            %[pks, locs, w, p] = findpeaks(psd_dB(startSearchIndex:stopSearchIndex),'MinPeakProminence',obj.config.PROMINENCE, 'MinPeakHeight',(obj.meanNoiseFloor+obj.config.Q_DB_ABOVE_NOISE), 'SortStr', 'descend');                
            [peakValue, peakLocation, peakWidth, peakProminence] = findpeaks(psd(startSearchIndex:stopSearchIndex),'SortStr', 'descend');                
            peakLocation = peakLocation + startSearchIndex - 1 ;
            f0 = obj.config.V_PIPE/(2*obj.config.D_NOM);

            N = round((fHigh - fLow)/f0);                    

            % Keep N heighest peaks
            if(length(peakValue)>N)
                peakValue = peakValue(1:N);
                peakLocation = peakLocation(1:N);
                peakWidth = peakWidth(1:N);
                peakProminence = peakProminence(1:N);
            end

        case PeakMethod.N_HIGEST_PROMINENCE 
            
            if( length(varargin)> 0)
                N = varargin{1};
            else
                f0 = obj.config.V_PIPE/(2*obj.config.D_NOM);
                N = round((fHigh - fLow)/f0);
            end
   
            % Return the N peaks with highest prominence
            %[peakValue, peakLocation, peakWidth, peakProminence] = findpeaks(psd(startSearchIndex:stopSearchIndex),'MinPeakProminence',obj.config.PROMINENCE, 'MinPeakHeight',(obj.meanNoiseFloor+obj.config.Q_DB_ABOVE_NOISE), 'SortStr', 'descend');                
            [peakValue, peakLocation, peakWidth, peakProminence] = findpeaks(psd(startSearchIndex:stopSearchIndex),'SortStr', 'descend');                
            peakLocation = peakLocation + startSearchIndex - 1 ;                    
            tempPeakMatrix = [peakProminence,peakValue,peakLocation,peakWidth];

            % Sort table based on coloumn 1, prominence
            tempPeakMatrix = sortrows(tempPeakMatrix);   
        

            % Keep the N peaks with heighest prominence
            if( length(tempPeakMatrix) > N )
                a_ = tempPeakMatrix(length(tempPeakMatrix)-(N-1):end,:);
                peakWidth = a_(:,4);
                peakLocation = a_(:,3);
                peakValue = a_(:,2);
                peakProminence = a_(:,1);

            end                

        otherwise
            disp('No method set')

    end   

    if(obj.RESONANCE == type)
        obj.peakWidthResonance = peakWidth;
        obj.peakLocationResonance = peakLocation;
        obj.peakValueResonance = peakValue;
        obj.peakProminenceResonance = peakProminence;
    elseif(obj.MAIN == type)          
        obj.peakWidthMain = peakWidth;
        obj.peakLocationMain = peakLocation;
        obj.peakValueMain = peakValue;
        obj.peakProminenceMain = peakProminence;
    end                        

end 