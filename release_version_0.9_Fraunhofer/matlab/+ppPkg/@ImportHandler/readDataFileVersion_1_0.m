function [tm] = readDataFileVersion_1_0(obj, fileId, dateInSec)

    import ppPkg.TransducerMeasurement
    
    errorMsg = 'Error importing';
    index = 0;
    tm = TransducerMeasurement;
    
    
    packageCount = 0;
    roll = 0;
    pitch = 0;
    
    while ~feof(fileId)  
        
        % Read shot header
        [text, count] = fread(fileId, 15, '*char');
        if count < 1
            if(feof(fileId))
                break;
            else                        
                error(errorMsg);
            end
        end
        
        % transpose to get row vector
        text = text';
                
        
        if( ~strcmp(text,'<bluenose V1.1>'))
            fclose(fileId)
            error('Error importing, package header name is wrong: %s\n', text)
        end
        

        
        % Shot count
        [shotCount, count] = fread(fileId, 1, 'uint8');
        if count < 1
            error('Error importing: shotCount, shotIndex %d', index);
        end  
        
       
        % Roll 16 bits  
        % Divide by 100 to get degrees
        [rollTemp, count] = fread(fileId, 1, 'uint16');
        if count < 1
            error('Error importing: startTimeRec, index %d, shotIndex %d',index , shotIndex);
        end       

        % Pitch 16 bits
        % Divide by 100 to get degrees
        [pitchTemp, count] = fread(fileId, 1, 'uint16');
        if count < 1
            error('Error importing: pitch, index %d',index );
        end 
   
        if(shotCount == 0)
        % Update roll, pitch
            roll = rollTemp;
            pitch = pitchTemp;            
        end
        
        
        % Reserved 32 bits
        [reserved1, count] = fread(fileId, 1,  'uint32');
        if count < 1
            error('Error importing: reserved1, index %d', index);
        end           
        
        % Firetime in us 64 bits        
        [fireTime, count] = fread(fileId, 1, 'uint64');
        if count < 1
            error('Error importing: fireTime, index %d', index);
        end           
        
        shotIndex = 0;
        
        while ( ~feof(fileId) && (shotIndex < 8))
            
            index = index + 1;
            tm(index) = TransducerMeasurement;
            
            tm(index).date = dateInSec;
            tm(index).fireTime = fireTime; 
            tm(index).roll = roll; 
            tm(index).pitch = pitch; 
            
            % Record start time in AD count
            [startTimeRec, count] = fread(fileId, 1, 'uint16');
            if count < 1
                error('Error importing: startTimeRec, index %d, shotIndex %d',index , shotIndex);
            end    
            
            tm(index).startTimeRec = startTimeRec; 
            
            [reserved2, count] = fread(fileId, 1, 'uint32');
            if count < 1
                error('Error importing: reserved2, index %d, shotIndex %d',index , shotIndex);
            end
            

            % Transducer Id 3 bits
            [transducerId, count] = fread(fileId, 1, 'ubit3');
            if count < 1
                error('Error importing: transducerId, index %d shotIndex %d', index , shotIndex);
            end  
                        
            % Group Id 4 bits
            [tm(index).groupId, count] = fread(fileId, 1,  'ubit4');
            if count < 1
                error('Error importing: groupId, index %d shotIndex %d', index , shotIndex);
            end 
            
            % Alternatively combine with groupId to get a number [1-96]
            tm(index).transducerId = 1 + tm(index).groupId*8 + transducerId;
            
            
            [reserved3, count] = fread(fileId, 1, 'ubit9');
            if count < 1
                error('Error importing: reserved3, index %d shotIndex %d', index , shotIndex);
            end             

            %[groupId, transducerId]            
            
            [signalUnmodified, count] = fread(fileId, 2000, 'uint16');
            if count < 2000
                error('Error importing: data, index %d shotIndex %d', index , shotIndex);
            end  
            
            tm(index).signal = ((signalUnmodified - 2^15)/2^15);
            
            shotIndex = shotIndex + 1;
        end       
        
    end
    
end