function [tm] = readDataFileVersion6(obj, fileId)
    %% Read binary data file 
    %  Import data into TransducerMeasurement object

    import ppPkg.TransducerMeasurement

    errorMsg = 'Error importing';
    index = 0;
    tm = TransducerMeasurement;

    while ~feof(fileId)                

        % Set specific header data

        % Read dateRec
        % YYYYMMDD   -> year month day
        [dateRec, count] = fread(fileId, 1,'uint32');
        if count < 1
            if(feof(fileId))
                break;
            else                        
                error(errorMsg);
            end
        end

        index = index + 1;
        tm(index) = TransducerMeasurement;
        tm(index).date = dateRec;

        % Read fire time
        % Hour | minute | second | millisecond
        [tm(index).fireTime, count] = fread(fileId, 1,'uint32');
        if count < 1
            error('Error importing: fireTime, shotIndex %d', index);
        end    

        % In microseconds
        [adcStartTime, count] = fread(fileId, 1,'uint32');
        if count < 1
            error('Error importing: adcStartTime, shotIndex %d', index);
        end 
        % TODO: need to calculate startTime in number of samples
        tm(index).startTimeRec = adcStartTime;

        [numSamples, count] = fread(fileId, 1,'uint16');
        if count < 1
            error('Error importing: numSamples, shotIndex %d', index);
        end                    

        %
        [tm(index).xPos, count] = fread(fileId, 1,'uint32');
        if count < 1
            error('Error importing: xPos, shotIndex %d', index);
        end

        [tm(index).yPos, count] = fread(fileId, 1,'uint32');
        if count < 1
            error('Error importing: yPos, shotIndex %d', index);
        end

        [tm(index).zPos, count] = fread(fileId, 1,'uint32');
        if count < 1
            error('Error importing: zPos, shotIndex %d', index);
        end

        [tm(index).uPos, count] = fread(fileId, 1,'uint32');
        if count < 1
            error('Error importing: uPos, shotIndex %d', index);
        end

        % Get transducer Id
        [tm(index).transducerId, count] = fread(fileId, 1,'uint8');
        if count < 1
            error('Error importing: transducerId, shotIndex %d', index);
        end       

        % Read data 
        % TODO: if samples are stored in a different format:
        % Using a 16 bit ADC results in 2 bytes number, so need to
        % convert to a floating point number
        [tm(index).signal, count] = fread(fileId, numSamples,'single');
        if count < numSamples
            error('Error importing: samples, shotIndex %d', index);
        end 

        tm(index).sampleRate = obj.header.sampleRate;
        tm(index).fLow = obj.header.fLow;
        tm(index).fHigh = obj.header.fHigh;
    end


end