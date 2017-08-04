%> @file HarmonicSet.m
%> @brief Class representing a harmonic set
% ======================================================================
%> @brief Class representing a harmonic set
%
%> 
% ======================================================================
classdef HarmonicSet < matlab.mixin.Copyable
    % Class to store a set of harmonic frequencies    
    
    properties (SetAccess = immutable)
        firstFreq                   % First frequency added to the set 
        fHigh                       % Highest frequency in tx pulse
        fLow                        % Lowest frequency in tx pulse
        deviationInFrequency        % Deviation in frequency          
    end
    
    properties (Dependent)
        numFrequencies              % Number of frequencies in the set
    end
   
    properties  (SetAccess = private)
        freqArray                   % Frequency array                
        valueArray                  % Peak value array
        psdIndexArray               % Psd index for each set        
        freqTargetArray             % Array containg target frequency based on freqDiff
        freqDiff                    % Difference in frequency between first and second frequency in the set                
        vp                          % Validation Parameter 
        class = 'NotSet'            % Classification
        averageFreqDiff = 0         % Average difference between harmonic frequencies        
        extraFreqsAdded = 0;
        numFreqSkipped  = 0;         % Number of frequencies skipped when adding frequencies to this set        
    end
    
    properties                
        thickness               = 0 % Thickness calculated based on average freq diff                        
        scoreHarmonic           = 0 % Harmonic score, TODO: not sure we need this
        scoreDoubleThickness    = 0 % Score: number of sets with double thickness compared to this set
        scoreTrippelThickness   = 0 % Score: number of sets with trippel thickness compared to this set
        scoreSubset             = 0 % Score: number of subsets this set
        scoreGroupCount         = 0 % Score for number 
        setMember               = [];
    end    
    
    properties (Access = private)  
        % experimental properties
        psdIndexArrayIntp
        freqArrayIntp
        thicknessIntp = 0        
    end
    
    methods
        
        function value = get.numFrequencies(obj)
           value = numel(obj.freqArray);           
        end
             
        % ======================================================================
        %> @brief Class constructor
        %>
        %> @param f1 Struct with freq 1: ( freq, peakValue, index)
        %> @param f2 Struct with freq 2: ( freq, peakValue, index)
        %> @param deviationFactor Allowed deviation factor
        %> @param fLow The lower frequency of the bandwidth
        %> @param fHigh The higher frequency of the bandwidth
        %> @retval instance of the HarmonicSet class.
        % ======================================================================          
        function obj = HarmonicSet(f1, f2, deviationFactor, fLow, fHigh)
            % Constructor                        
            if nargin == 5
                obj.fLow = fLow;
                obj.fHigh = fHigh;
                obj.firstFreq = f1.freq;
                obj.freqArray = [f1.freq, f2.freq];
                obj.valueArray = [f1.peakValue, f2.peakValue];                
                obj.psdIndexArray = [f1.index, f2.index];
                obj.freqTargetArray = [f1.freq, f2.freq];
                obj.freqDiff = abs(f2.freq - f1.freq);                                         
                obj.deviationInFrequency = deviationFactor;
                obj.vp = zeros(1,6);
                if( f1.freq < f2.freq )                   
                    error('Constructor F1 must be higher than F2')    
                end
            else
                error('Constructor must have 3 arguments')
            end  
        end
        
        %======================================================================
        %> @brief Function will try to add a frequency to a harmonic set
        %>        - Frequencies are added from LOW to HIGH frequency.
        %>        - The frequency will be added if it matches the next
        %>          expected frequency within a given deviation.
        %>        - If the frequency does not match the next expected
        %>          frequency it will skip to the next expected frequency untill
        %>          fLowLimit
        %>        - If the frequency is closer to the previous target
        %>          frequency it will replace the last added frequency
        %>
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param freqToAdd frequency to be added 
        % ======================================================================                         
        function bFrequencyAdded = tryAddFreqFromLow(obj, freqToAdd)
            
            K = round((obj.freqArray(1) - obj.firstFreq)/obj.freqDiff);
            
            if(K > 0) 
                previousDeviation = abs(obj.freqArray(1) - (obj.firstFreq + K * obj.freqDiff));
                currentDeviation  = abs(freqToAdd.freq - (obj.firstFreq + K * obj.freqDiff)); 
                
                if( currentDeviation < previousDeviation )
                  % The new frequency is a better match so replace current with next
                  %disp('Previous is a better match')
                  %fprintf('New freq %f, old freq %f\n', freq, obj.freqArray(1));

                  obj.freqArray(1) = freqToAdd.freq;
                  obj.valueArray(1) = freqToAdd.peakValue;
                  obj.psdIndexArray(1) = freqToAdd.index;              

                  bFrequencyAdded = true;
                  return
                end                
            end
            
            fNext = obj.firstFreq + (K+1) * obj.freqDiff;
                                    
            % Calculate allowed deviation in frequency. 
            devInFreq = obj.deviationInFrequency;
            
            % Initiate variable
            bFrequencyAdded = false;
            
            % Init variable
            skipCount = 0;
            
            % Allow that 
            while((bFrequencyAdded == false) && ( fNext < obj.fHigh ))                
                if( devInFreq >= abs(freqToAdd.freq - fNext))                                                
                    bFrequencyAdded = true;    
                    obj.numFreqSkipped = obj.numFreqSkipped + skipCount;
                else                    
                    bFrequencyAdded = false;
                    
                    % increment k for next harmonic frequency
                    K = K + 1;
 
                    % Calculate next harmonic frequency
                    fNext = obj.firstFreq + (K * obj.freqDiff);                 
                    
                    % Increment frequency skipped count                    
                    skipCount = skipCount + 1;
                end 
            end 
            
            % If success, add frequency to harmonic set. 
            if( true == bFrequencyAdded )
                obj.freqArray = [freqToAdd.freq obj.freqArray];
                obj.valueArray = [freqToAdd.peakValue obj.valueArray];
                obj.psdIndexArray = [freqToAdd.index obj.psdIndexArray];         
                obj.extraFreqsAdded = obj.extraFreqsAdded + 1;
                obj.freqTargetArray = [fNext obj.freqTargetArray];
            end                           
        end
     
        %======================================================================
        %> @brief Function will try to add a frequency to a harmonic set
        %>        - Frequencies are added from high to low frequency.
        %>        - The frequency will be added if it matches the next
        %>          expected frequency within a given deviation.
        %>        - If the frequency does not match the next expected
        %>          frequency it will skip to the next expected frequency untill
        %>          fLowLimit
        %>        - If the frequency is closer to the previous target
        %>          frequency it will replace the last added frequency
        %>        
        %> @param obj instance of the HarmonicSet class. 
        %> @param freqToAdd frequency to be added 
        % ======================================================================           
        function bFrequencyAdded = tryAddFreqFromHigh(obj, freqToAdd)
            
            fFirstFound = obj.freqArray(1);                        
            fPreviousIndex = obj.numFrequencies;
            fNextIndex = fPreviousIndex+1; 
            
            k = -1 + round((obj.freqArray(fPreviousIndex)-fFirstFound) /obj.freqDiff);                      
            
            % First check if freq is a better match compared to previous added
            % frequency. Meaning: check if freq is closer to target frequency
            % compared to previous added frequency.
            previousDeviation = abs(obj.freqArray(obj.numFrequencies) - (fFirstFound + ((k+1) * obj.freqDiff)));
            currentDeviation  = abs(freqToAdd.freq - (fFirstFound + ((k+1) * obj.freqDiff)));           
            
            % Check if current frequency is closer to target harmonic
            % frequency compared to previous added frequency
            if( currentDeviation < previousDeviation )
              % The new frequency is a better match so replace current with next
              %disp('Previous is a better match')fHarmonicSet
              %fprintf('Old index %d, new index %d\n', obj.psdIndexArray(fPreviousIndex), index);
             
              obj.freqArray(fPreviousIndex) = freqToAdd.freq;
              obj.valueArray(fPreviousIndex) = freqToAdd.peakValue;
              obj.psdIndexArray(fPreviousIndex) = freqToAdd.index;              
              
              bFrequencyAdded = true;
              return
            end
                                   
            % Calculate next harmonic frequency
            fNext = fFirstFound + (k * obj.freqDiff);
            
            % Calculate allowed deviation in frequency. 
            devInFreq = obj.deviationInFrequency;
            
            % Initiate variable
            bFrequencyAdded = false;
            
            % Init variable
            skipCount = 0; 
            
            % Allow that 
            while((bFrequencyAdded == false) && ( fNext > obj.fLow ))
                if( devInFreq >= abs(freqToAdd.freq - fNext))                                    
                    bFrequencyAdded = true; 
                    
                    % Update number of skipped frequencies
                    obj.numFreqSkipped = obj.numFreqSkipped + skipCount;
                else                    
                    bFrequencyAdded = false;
                    
                    % Decrement k for next harmonic frequency
                    k = k - 1;
 
                    % Calculate next harmonic frequency
                    fNext = fFirstFound + (k * obj.freqDiff);                 
                    
                    % Increment frequency skipped count
                    skipCount = skipCount + 1;
                end 
            end
            
            % If success, add frequency to harmonic set. 
            if( true == bFrequencyAdded )
                obj.freqArray(fNextIndex) = freqToAdd.freq;
                obj.valueArray(fNextIndex) = freqToAdd.peakValue;
                obj.psdIndexArray(fNextIndex) = freqToAdd.index;                
                obj.freqTargetArray(fNextIndex) = fNext;
            end        
        end          
        
        %======================================================================
        %> @brief Function will flip arrays containing the frequency sets
        %>
        %> @param obj instance of the HarmonicSet class. 
        % ======================================================================          
        function flip(obj)
            obj.freqArray = flip(obj.freqArray);
            obj.valueArray = flip(obj.valueArray);
            obj.psdIndexArray = flip(obj.psdIndexArray);  
            obj.freqTargetArray = flip(obj.freqTargetArray);
        end        
           
        %======================================================================
        %> @brief Function plots frequency set
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param psd Psd spectrum that the set belongs to
        %> @param fs Sampling rate
        % ======================================================================   
        function plotSet(obj, psd, fs)
            
            figure('units','normalized','outerposition',[0 0 1 1])
            
            % Calculate FFT length
            nfft = (length(psd)-1)*2;
            
            % Create frequency array
            f = 0:fs/nfft:fs/2;
            
            % Plot PSD with peaks marked
            %pPsd = plot(f, psd, f(obj.psdIndexArray), obj.valueArray,'o')            
            pPsd = plot(f, psd);
            hold on
            pPeak = plot(f(obj.psdIndexArray), obj.valueArray,'o');
            hold off
                
            % Plot: target frequency lines and
            %       deviation lines from target frequency                
            for n = 1:numel(obj.freqArray)

                fTarget = obj.freqTargetArray(n);                                                  
                fDeviation = obj.deviationInFrequency;                    
                fTargetMin = fTarget - fDeviation;
                fTargetMax = fTarget + fDeviation;

                pTarget = line([fTarget fTarget],[obj.valueArray(n)+5,obj.valueArray(n)-5],'color','black');
                pTargetMin = line([fTargetMin fTargetMin],[obj.valueArray(n)+5,obj.valueArray(n)-5],'color','r', 'LineWidth',0.5);
                pTargetMax = line([fTargetMax fTargetMax],[obj.valueArray(n)+5,obj.valueArray(n)-5],'color','r','LineWidth',0.5);
            end
            
           % Plot: Average frequency lines 
           % Calculated from the first frequency found
           for n = 1:length(obj.freqArray)
                %k = round((obj.freqArray(n) - obj.firstFreq)/(obj.freqDiff) );
                k = round((obj.freqArray(n) - obj.firstFreq)/(obj.averageFreqDiff) );                
                fAverage = obj.firstFreq + (k * obj.averageFreqDiff);

                pAverage = line([fAverage fAverage],[obj.valueArray(n)+5,obj.valueArray(n)-5],'color','green','LineWidth',0.5);
           end

            % Plot harmonics and shear
            [harmonicArray,shearArray] = obj.plotHelperHarmonics();
            maxPeak = max(obj.valueArray);
            for n = 1:length(harmonicArray)                        
                fHarmonic = harmonicArray(n);
                pHarmonic = line([fHarmonic fHarmonic],[maxPeak+10,maxPeak],'color','magenta','LineWidth',0.5);
                str = sprintf('%d', n); 
                text(fHarmonic, maxPeak+10, str)                            
            end
if(0) % Disable shear frequency plotting                
            for n = 1:length(shearArray)                        
                fshear = shearArray(n);
                line([fshear fshear],[obj.valueArray(1)+20,obj.valueArray(1)],'color','magenta','LineWidth',0.5)
                str = sprintf('%d/2', (1+2*(n))); 
                text(fshear, obj.valueArray(1)+20, str)                            
            end                                              
end              

            % Plot harnomincs line for concrete
if(0)            
            f0Concrete = 516e3;
            f0ConcreteDelta = 0.035e6;
            harmonicArrayConcrete = obj.plotHelperHarmonicsMaterial(f0Concrete, f0ConcreteDelta);
            for n = 1:length(harmonicArrayConcrete)                        
                fConcrete = harmonicArrayConcrete(n);
                line([fConcrete fConcrete],[obj.valueArray(1)+20,obj.valueArray(1)],'color','black','LineWidth',0.5)
                str = sprintf('%d', n); 
                text(fConcrete, obj.valueArray(1)+20, str)                            
            end                                              
end          
if(0)
            f0CastIron = 110962;
            harmonicArrayCastIron = obj.plotHelperHarmonicsMaterial(f0CastIron, 0);
            for n = 1:length(harmonicArrayCastIron)                        
                fCastIron = harmonicArrayCastIron(n);
                line([fCastIron fCastIron],[obj.valueArray(1)+20,obj.valueArray(1)],'color','red','LineWidth',0.5)
                str = sprintf('%d', n); 
                text(fCastIron, obj.valueArray(1)+20, str)                            
            end                                              
end
            
            
                               
            title('PSD with harmonic set marked')
            xlabel('Frequency')
            ylabel('dB')
            DeviationMaxTxt = sprintf('Deviation: %0.0fHz', obj.deviationInFrequency);
            DeviationMinTxt = sprintf('Deviation: -%0.0fHz', obj.deviationInFrequency);
            TargetTxt = sprintf('Target dF: %0.0fHz', obj.freqDiff);
            AverageTxt = sprintf('Average dF: %0.0fHz\nThickness: %f\nClass: %s', obj.averageFreqDiff, obj.thickness, obj.class);
            %legend('Psd','Peak', TargetTxt, DeviationMinTxt, DeviationMaxTxt, AverageTxt,'test1', 'test2')
            legend([pPsd pPeak pTarget pTargetMin pTargetMax pAverage pHarmonic], 'Psd','Peak', TargetTxt, DeviationMinTxt, DeviationMaxTxt, AverageTxt,'Harmonics')
            grid on
        end
        
        %======================================================================
        %> @brief Helper function for plotting harmonics and shear
        %>        frequencies
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @retval harmonicArray 
        %> @retval shearArray 
        % ======================================================================          
        function [harmonicArray, shearArray] = plotHelperHarmonics(obj)
        %% Helper function to draw lines for where the harmonics should be found in psd
           
        % Harmonic
            K = floor(obj.freqArray(1)/obj.averageFreqDiff);
                                    
            harmonicArray = zeros(1,15);
            index = 1;
            harmonic = obj.freqArray(1) + (index-1-K) * obj.averageFreqDiff;                
            while( harmonic < 5e6)
                harmonicArray(index) = harmonic;
                index = index + 1;
                harmonic = obj.freqArray(1) + (index-1-K) * obj.averageFreqDiff;                                    
            end
            harmonicArray(index:end) = [];
            
            % Remove first frequency if less than F0
            if(harmonicArray(1)<obj.averageFreqDiff/2)
                harmonicArray = harmonicArray(2:end);
            end
            
        % Shear
            delta = harmonicArray(1)-obj.averageFreqDiff;
            
            shearArray = zeros(1,15);
            index = 1;
            shear = obj.averageFreqDiff*((2*(index+1)-1)/2) + delta;
            
            while( shear < 5e6) 
                shearArray(index) = shear;
                index = index + 1;
                shear = obj.averageFreqDiff*((2*(index+1)-1)/2) + delta;                
            end
            
            shearArray(index:end) = [];                        
        end
        
        function [harmonicArray] = plotHelperHarmonicsMaterial(obj, f0, delta)
            %% Helper function to draw lines for where the harmonics should be found in psd
            
            % Harmonic            
            harmonicArray = zeros(1,15);
            index = 1;
            harmonic = f0 + delta;                
            
            while( harmonic < 5e6)
                harmonicArray(index) = harmonic;            
                harmonic =  f0 + delta + index * f0;                                    
                index = index + 1;
            end
            harmonicArray(index:end) = [];
        end
        
        %======================================================================
        %> @brief Function calculates validation parameters        
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param psdNoise Psd of the noise
        %> @param meanNoise Mean value of the psd noise spectrum
        %> @param qSet Number of dB above noise set
        %> @param qMax Maximum dB above noise as set in the configuration
        % ======================================================================        
        function calculateValidationParameters(obj, psdNoise, meanNoise, qSet, qMax)          

            import ppPkg.VP;                                
                        
            % Absolute Number of harmonics
            obj.vp(VP.ABSOLUTE_NUM_HARMONICS) = ...
                obj.numFrequencies;
            
            % Relative Number of harmonics            
            % Calculates the number of harmonics that can exist in the 
            % bandwidth of the transmitted pulse.                      
            
            obj.vp(VP.RELATIVE_NUM_HARMONICS) = ...
                (obj.numFrequencies/obj.calculateMaxHarmonics());
            
            % Average deviation from theoretical frequency             
            % Calculate mean of abs of the deviation frequencies. 
            obj.vp(VP.AVERAGE_DEVIATION) = ...
                mean(abs(obj.calculateDeviationFromAverageF0()));             
            
            % Relative Q applied 
            % These numbers are taken from configuration used.
            obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) = qSet/qMax;
                        
            % Total resonance energy
            resonanceEnergy = obj.calculateResonanceEnergy(psdNoise, meanNoise);
            
            obj.vp(VP.TOTAL_RESONANCE_ENERGY) = ...
                sum(resonanceEnergy);
            
            % Average resonance energy
            obj.vp(VP.AVERAGE_RESONANCE_ENERGY) = ...
                mean(resonanceEnergy);
            
        end
        
        %======================================================================
        %> @brief Function calculates maximum number of harmonics that        
        %>        can exist given fLow and fHigh
        %>
        %> @param obj instance of the HarmonicSet class. 
        % ======================================================================             
        function maxHarmonics = calculateMaxHarmonics(obj)
          
            if (obj.fHigh == obj.fLow)
                maxHarmonics = 1;
                return
            end 
            
            n = 0;
            fFirst = obj.freqArray(1);                            
            
            % Calculate distance in frequency from fLow to where first
            % harmonic frequency should be found
            while(fFirst - n*obj.freqDiff >= obj.fLow) 
                n = n + 1;
            end            
            delta = (fFirst - (n-1)*obj.freqDiff) - obj.fLow;
            
            % Calculate number of harmonics
            maxHarmonics = 0;
            while(obj.fLow + delta + (maxHarmonics * obj.freqDiff) <= obj.fHigh)                
                maxHarmonics = 1 + maxHarmonics; 
            end            
        end
        
        %======================================================================
        %> @brief Function calculates resonance energy based on the 
        %>        sum of peaks substracted the noise floor                
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param psdNoise Psd spectrum of the noise, Currently not used
        %> @param meanNoise Mean value of the psd noise spectrum
        % ======================================================================   
        function resonanceEnergy = calculateResonanceEnergy(obj, psdNoise, meanNoise)
       
            % NOTE: using meanNoise instead of psdNoise
            resonanceEnergy = zeros(1,obj.numFrequencies);            
            i = 1:obj.numFrequencies;
            resonanceEnergy(i) = obj.valueArray(i) - meanNoise;
        end
        
        %======================================================================
        %> @brief Function calculates the average frequency difference 
        %>        between frequencies in the set
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param varargin Input if one want to use a subset of the frequencies
        % ======================================================================  
        function [averageDiff] = calculateAverageFreqDiff(obj, varargin)                    
        
            useWeightedAverage = true;
            if(nargin == 2)               
               diffArray = diff(varargin{1});
            else
               diffArray = diff(obj.freqArray);    
            end            
            
            % Find skipped frequencies
            divArray = round(diffArray/obj.freqDiff);
            
            % To take care of skipped harmonic frequencies
            diffArrayAdjusted = diffArray./divArray;
            
            if(useWeightedAverage)
                index = 1;
                diffArrayWeighted = zeros(1, sum(divArray));            

                % Create weigthed diffArray
                for n=1:length(divArray)
                    for k = 1:divArray(n)
                        diffArrayWeighted(index) = diffArrayAdjusted(n);
                        index = index + 1;
                    end
                end  
            end
                        
            averageDiff = mean(diffArrayAdjusted);            
            obj.averageFreqDiff = averageDiff;
        end   
        
        function [medianDiff] = calculateMedianFreqDiff(obj, varargin)  
            if(nargin == 2)               
               diffArray = diff(varargin{1});
            else
               diffArray = diff(obj.freqArray);    
            end 
            
            % Find skipped frequencies
            divArray = round(diffArray/obj.freqDiff);
            
            % To take care of skipped harmonic frequencies
            diffArrayAdjusted = diffArray./divArray;
            
            %meanDiff = mean(diffArrayAdjusted);            
            %deviationFromMean = abs((diffArrayAdjusted - meanDiff)/meanDiff);
            
            medianDiff = median(diffArrayAdjusted);            
            deviationFromMedian = abs((diffArrayAdjusted - medianDiff)/medianDiff);

            
            p = 3;
  
            arrayWithinPpercent = diffArrayAdjusted(deviationFromMedian < p/100);            
            
            %medianDiff = median(sort(diffArrayAdjusted));
            medianDiff = mean(arrayWithinPpercent);
            
            
        end
        
        %======================================================================
        %> @brief Function calculates the average frequency difference 
        %>        between frequencies in the set
        %>
        %> @param obj instance of the HarmonicSet class. 
        % ======================================================================        
        function  freqDiff = calculateAverageAdjustedDiff(obj, meanDiff, p, varargin)
            
            if(nargin == 4)               
               diffA = diff(varargin{1});                        
            else
               diffArray = diff(obj.freqArray);    
               
                % Find skipped frequencies
                divArray = round(diffArray./obj.freqDiff);

                % To take care of skipped harmonic frequencies
                diffArrayAdjusted = diffArray./divArray;
                index = 1;
                diffA = zeros(1, sum(divArray));

                % Create weigthed diffArray
                for n=1:length(divArray)
                    for k = 1:divArray(n)
                        diffA(index) = diffArrayAdjusted(n);
                        index = index + 1;
                    end
                end    
                
            end 
            

            deviationFromMean = abs((diffA - meanDiff)/meanDiff);
  
            arrayWithinPpercent = diffA(deviationFromMean < p/100);
            
            freqDiff = mean( arrayWithinPpercent );
                        
        end
                
        %======================================================================
        %> @brief Function calculates the deviation from average F0
        %>        (freqDiffAverage) harmonic frequency (freqDiff) for each 
        %>        frequency in the set (freqArray).
        %>        
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @retval deviationArray Array of deviations 
        % ======================================================================               
        function deviationArray = calculateDeviationFromAverageF0(obj)
                        
           % Initialize array
           deviationArray = zeros(1,numel(obj.freqArray));            
           for n = 1:length(obj.freqArray)
                k = round((obj.freqArray(n) - obj.firstFreq)/(obj.freqDiff) );
                fAverage = obj.firstFreq + (k * obj.averageFreqDiff);                           
               
                deviationArray(n) = obj.freqArray(n)- fAverage;           
           end                                              
        end   
        
        %======================================================================
        %> @brief Function calculates the deviation from target F0
        %>        (freqTargetArray) harmonic frequency 
        %>        
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @retval deviationArray Array of deviations 
        % ======================================================================          
        function deviationArray = calculateDeviationFromTargetF0(obj)
            
           % Initialize array
           deviationArray = zeros(1,numel(obj.freqArray));            
           for n = 1:length(obj.freqArray)
               
                deviationArray(n) = obj.freqArray(n)- obj.freqTargetArray(n);           
           end
        end
        
        %====================================================================== 
        %> @brief Function calculates the deviation from theoretical            
        %>        harmonic frequency (freqDiff) for each frequency in the       
        %>        set (freqArray)                                               
        %>                                                                      
        %> @param obj instance of the HarmonicSet class.                        
        %> @retval deviationArray Array of deviations                           
        % ======================================================================
        function deviationArray = calculateDeviationFromTheoreticalF0(obj)      

            % Calculate difference between adjacent elements in freqArray       
            diffArray = diff(obj.freqArray);                                    

            % Initialize array                                                  
            deviationArray = zeros(1,numel(diffArray));                         

            % Calculate the deviation from theoretical harmonic frequency       
            for index = 1:numel(diffArray)                                      
                deviation = diffArray(index) - obj.freqDiff;                    

                % Handle the case where a harmonic is missing                   
                while (deviation > (0.5*obj.freqDiff) )                         
                    deviation = deviation - obj.freqDiff;                       
                end                                                             

                deviationArray(index) = deviation;                              
            end                                                                 
        end                                                                     
                                                                        

        
               
        %======================================================================
        %> @brief Function sets validation class based on the validation
        %>        parameters
        %>
        %> @param obj instance of the HarmonicSet class. 
        %> @param sampleRate sample rate
        %> @param fftLength FFT length
        % ======================================================================             
        function classSet = findVpClass(obj, sampleRate, fftLength)

            import ppPkg.VP;
            
            ratio = sampleRate/(fftLength);
            printDebugMsg = false;
            debugMsg = '';
            classDefault = 'Not Set';
            
            % Class A
            if( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) > 5) && ...
                (obj.vp(VP.RELATIVE_NUM_HARMONICS) > 0.5) && ...
                (obj.vp(VP.AVERAGE_DEVIATION) < 10*ratio) && ...
                (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.2) )
                if(printDebugMsg)
                    debugMsg = 'Class A, 1';
                end                
                classDefault = 'A';
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) > 4) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) >= 0.8 ) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 10*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.5) )                
                if(printDebugMsg)
                    debugMsg = 'Class A, 2';
                end
                classDefault = 'A';                
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) > 4) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) >= 0.8 ) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 10*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.6) )                
                if(printDebugMsg)
                    debugMsg = 'Class A, 3';
                end
                classDefault = 'A';                     
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) >= 3) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1 ) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 5*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.8) )                
                if(printDebugMsg)
                    debugMsg = 'Class A, 4';
                end
                classDefault = 'A';                 
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) >= 2) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1 ) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 3*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.8) )                
                if(printDebugMsg)
                    debugMsg = 'Class A, 5';
                end
                classDefault = 'A';                  
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) >= 2) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1 ) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 3*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.5) && ...
                    (obj.vp(VP.TOTAL_RESONANCE_ENERGY) > 20))                
                if(printDebugMsg)
                    debugMsg = 'Class A, 6';
                end
                classDefault = 'A';
                                
             % Class B:  
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) > 5) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) < 0.5 ) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) < 15*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.2) )                
                if(printDebugMsg)
                    debugMsg = 'Class B, 1';
                end
                classDefault = 'B';                
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) > 4) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) <= 0.8 ) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 15*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.5) )                
                if(printDebugMsg)
                    debugMsg = 'Class B, 2';
                end
                classDefault = 'B';                
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) > 4) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 15*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.6) )                
                if(printDebugMsg)
                    debugMsg = 'Class B, 3';
                end
                classDefault = 'B';                   
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) >= 3) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 10*ratio) )                
                if(printDebugMsg)
                    debugMsg = 'Class B, 4';
                end
                classDefault = 'B';                   
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) >= 2) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 10*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.8) )                
                if(printDebugMsg)
                    debugMsg = 'Class B, 5';
                end
                classDefault = 'B';                   
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) >= 2) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 10*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.5) && ...
                    (obj.vp(VP.TOTAL_RESONANCE_ENERGY) > 20) )                
                if(printDebugMsg)
                    debugMsg = 'Class B, 6';
                end
                classDefault = 'B';   
                
            % Class C: 
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) == 3) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) <= 0.5) && ...
                    (obj.vp(VP.AVERAGE_DEVIATION) <= 15*ratio) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 0.8))                
                if(printDebugMsg)
                    debugMsg = 'Class C, 1';
                end
                classDefault = 'C';   
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) == 2) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 1))                
                if(printDebugMsg)
                    debugMsg = 'Class C, 2';
                end
                classDefault = 'C';                
            
            elseif( (obj.vp(VP.ABSOLUTE_NUM_HARMONICS) == 2) && ...
                    (obj.vp(VP.RELATIVE_NUM_HARMONICS) == 1) && ...
                    (obj.vp(VP.RELATIVE_Q_ABOVE_NOISE) > 1) )                
                if(printDebugMsg)
                    debugMsg = 'Class C, 3';
                end
                classDefault = 'C';
                                
            else 
                if(printDebugMsg)
                    debugMsg = 'Class D, Default';
                end
                classDefault ='D';
            end
            
            if(printDebugMsg)
                disp(debugMsg);
            end
            
            % Set class member variable
            obj.class = classDefault;
            classSet = obj.class;
            
        end                                                   
    end    
end




