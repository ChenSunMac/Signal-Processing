%> @file ImportHandler.m
%> @brief Class takes care of importing data from file
% ======================================================================
%> @brief ImportHandler class supports various header file versions
%
%> Current supported version is version 6
%> Class contains function for importing binary data from file and will
%> return an array of TransducerMeasurement instances. 
% ======================================================================
classdef ImportHandler < matlab.mixin.Copyable
    % Import data files
    % Contains function for importing binary data from file and
    % return transducer measurement records
    
    properties        
        header
        dataFiles
        dataFileIndex = 1;
        recRead = 0;
    end
    
    methods (Access = private)         
        [tm] = readDataFileVersion6(obj, fileId)
        [tm] = readDataFileVersion_1_0(obj, fileId, dateInSec)
        [tm, numberOfRec, header] = importDataVersion0(obj, h, fileId)
        [tm, numberOfRec, header] = importDataVersion1(obj, h, fileId)
        [tm, numberOfRec, header] = importDataVersion2(obj, h, fileId)
        [tm, numberOfRec, header] = importDataVersion3(obj, h, fileId)
        [tm, numberOfRec, header] = importDataVersion4(obj, h, fileId)        
    end

    
    methods   
        
        % ======================================================================
        %> @brief Read header file
        %>
        %> Functions read all defined fields in header file and places them
        %> in the header struct
        %>
        %> @param obj instance of the ImportHandler class.
        %> @param filename filename with path to header file
        %> @retval header returns header struct
        % ======================================================================
        function [header] = readHeader(obj, filename)
        %% Read header file for a project
        
            fileId = -1;
            errMsg = '';
                        
            % Try open file            
            [fileId,errMsg] = fopen(filename);
            if fileId < 0;
                error(errMsg);
                return
            end
            
            [pathstr,name,ext] = fileparts(filename); 
            
            % @TODO: Move this section to a separate function for handling
            % of various versions of header
            
            tline = fgetl(fileId);
            while ischar(tline)

                tempField = textscan(tline,'%s %s', 'Delimiter','=');

                field = deblank(char(tempField{1}));
                switch field
                    case 'Version'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.version = double(tempField{2});
                    case 'Project ID'
                        tempField = textscan(tline,'%s %s', 'Delimiter','=');
                        header.projectId = deblank(char(tempField{2}));
                    case 'Tool ID'
                        tempField = textscan(tline,'%s %s', 'Delimiter','=');
                        header.toolId = deblank(char(tempField{2}));     
                    case 'Operator'
                        tempField = textscan(tline,'%s %s', 'Delimiter','=');
                        header.operator = deblank(char(tempField{2}));      
                    case 'Sequence Number'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.seqNumber = double(tempField{2});       
                    case 'Pipe Diameter'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.pipeDiameter = double(tempField{2});                          
                    case 'Number of Transducers'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.numberOfTransducers = double(tempField{2});
                    case 'FW SW Version Information'
                        tempField = textscan(tline,'%s %s', 'Delimiter','=');
                        header.fwSwVersion = deblank(char(tempField{2}));                         
                    case 'Start Time'
                        tempField = textscan(tline,'%s %s', 'Delimiter','=');
                        header.startTime = deblank(char(tempField{2}));        
                    case 'Data Type'
                        tempField = textscan(tline,'%s %s', 'Delimiter','=');
                        header.dataType = deblank(char(tempField{2}));        
                    case 'Pattern'
                        tempField = textscan(tline,'%s %s', 'Delimiter','=');
                        header.pulsePattern = deblank(char(tempField{2}));        
                    case 'Pulse Length'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.pulseLength = double(tempField{2});        
                    case 'Start Frequency'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.fLow = double(tempField{2});        
                    case 'Stop Frequency'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.fHigh = double(tempField{2});        
                    case 'Gain Tx'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.gainTx = double(tempField{2});        
                    case 'Gain Rx 1'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.gainRx1 = double(tempField{2});        
                    case 'Gain Rx 2'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.gainRx2 = double(tempField{2});        
                    case 'Sampling Rate'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.sampleRate = double(tempField{2});        
                    case 'Attenuation'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.attenuation = double(tempField{2});        
                    case 'Vertical Range'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.verticalRange = double(tempField{2});        
                    case 'Number of Files'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.numFiles = double(tempField{2});        
                    case 'Number of Recordings'
                        tempField = textscan(tline,'%s %d', 'Delimiter','=');
                        header.numRec = double(tempField{2});        
                    otherwise
                        fclose(fileId);                        
                        error('Unknown field: %s', field);    
                end

                tline = fgetl(fileId);

            end

            % Close File
            fclose(fileId);
                        
            header.folderName = pathstr;
            header.fileName = name;
            
            % Return header
            h = header;
            
            obj.header = header;

            % Retrieve list of files to read.
            fileNameSearch = strcat(header.folderName,'/',header.projectId,'*');
            
            % Clear cell array
            %obj.dataFiles(:) = [];
            listing = dir(fileNameSearch);

            % Read data filename into dataFiles cell array
            fileIndex = 1;
            for index = 1:size(listing,1)
                if(0 == strcmp(listing(index).name, header.fileName))
                    dataFiles(fileIndex) = cellstr(listing(index).name);
                    fileIndex = fileIndex + 1;
                end
            end
                        
            % Sort cell array: dataFiles 
            obj.dataFiles = sort(dataFiles);
            
            % Check that the correct number of dataFiles are found
            if(obj.header.numFiles ~= length(obj.dataFiles) )                
                error('Incorrect number of data files found, expected %d, found %d', obj.header.numFiles, length(obj.dataFiles));
            end
            
            obj.dataFileIndex = 1;            
            
        end

        % ======================================================================
        %> @brief Function read all files in folder into a list
        %>
        %> This function is temp solution for bluenose project to read data
        %> file without a header file.
        %>
        %> @param obj instance of the ImportHandler class.
        %> @param folderName Folder where all the data files are located      
        % ======================================================================
        function readFolder(obj, folderName)
                        
            if(isdir(folderName))
                header.folderName = folderName;
            else
                [pathstr,name,ext] = fileparts(folderName);            
                header.folderName = pathstr;
            end            
            
            obj.header = header;
            
            disp('Supported Bluenose Data file version: 10');
            obj.header.version = 10;
            
            % Get all files in folder
            listing = dir(folderName);
            
            % Get all files that start with 'bn'
            fileIndex = 1;
            for index = 1:size(listing,1)
                if(1 == strncmp(listing(index).name, 'bn',2))
                    dataFiles(fileIndex) = cellstr(listing(index).name);
                    fileIndex = fileIndex + 1;
                end
            end
            
            % Sort cell array: dataFiles 
            obj.dataFiles = sort(dataFiles);
            obj.dataFileIndex = 1;    
        end
        
        % ======================================================================
        %> @brief Test function import data from one bluenose data file
        %>
        %> @param obj instance of the ImportHandler class.
        %> @param filename filename of file to import 
        % ======================================================================        
        function [tm] = importDataFileBlueNoseTest(obj, filename)
            fileId = -1;
            errMsg = '';
                        
            % Try open file            
            [fileId,errMsg] = fopen(filename);
            if fileId < 0;
                error(errMsg);
                return
            end 
                        
            % Time in seconds from file name
            bnDateTime = obj.getDateTimeBlueNose(filename);            
            
            % Import transducer data            
            tm = readDataFileVersion_1_0(obj, fileId, bnDateTime);
            
            
            % Close File
            fclose(fileId);                        
        end
        
        % ======================================================================
        %> @brief Function retrieves date time from filename
        %>
        %> @param obj instance of the ImportHandler class.
        %> @param filename filename to extract date time from
        % ======================================================================         
        function bnDateTime = getDateTimeBlueNose(obj, filename)

            [pathstr, name, ext] = fileparts(filename);
            
            % Get file name
            stringName = name;
            
            % Use regex to extract time from filename
            [matchDate, ~] = regexp(filename,'([0-9]){6}-([0-9]){6}','match');
            
            if(isempty(matchDate))
                
                error('Error in filename. Does not contain date time in expected syntax')
                
            else
                % Add '20' so that year is on format '2016'
                stringDate = strcat('20',matchDate);    
                
               % Convert to a datetime object
                bnDateTime = datetime(stringDate, 'InputFormat', 'yyyyMMdd-HHmmss');
            end
         
        
        end
        
        % ======================================================================
        %> @brief Function opens next file in dataFiles list and
        %>        calls correct data import function based on version
        %>        information retrieved from header file
        %>
        %> @param obj instance of the ImportHandler class.        
        % ======================================================================   
        function [tm] = importDataFile(obj)
            
            fileId = -1;
            errMsg = '';
            
            if(obj.dataFileIndex > numel(obj.dataFiles))
                error('No more data files to read')
            end
                        
            % Find next file to open
            % Using file index to get next file in list
            filename = char(strcat(obj.header.folderName,'/',obj.dataFiles(obj.dataFileIndex)));            
            
            % Try open file            
            [fileId,errMsg] = fopen(filename);
            if fileId < 0;
                error(errMsg);
                return
            end
            
            % @TODO: add check that this is the next file to process based
            % on timestamp
            
            % Based on header version use correct function for importing
            % data
            switch obj.header.version
                
                case 6
                    
                    % Alternative method for importing data using memmap
                    %tm = obj.testMemmapFileVersion6(filename);
                                                            
                    tm = obj.readDataFileVersion6(fileId);
                
                 case 10
                     
                     %error('NEED TO REMOVE TEST COMMENT in time argument')
                     bnDateTime = getDateTimeBlueNose(obj, filename);
                     
                     %tm = obj.readDataFileVersion_1_0(fileId);
                     
                     tm = readDataFileVersion_1_0(obj, fileId, bnDateTime);
                    
                otherwise
                    % Close File
                    fclose(fileId);
                    error('File header version %d, not supported', obj.header.version);                                    
            end
            
            
            obj.dataFileIndex = obj.dataFileIndex+1;

            % Close File
            fclose(fileId);
                    
        end
        
        function [tm] = splitFiles(obj)
            
            fileId = -1;
            errMsg = '';
            
            if(obj.dataFileIndex > numel(obj.dataFiles))
                error('No more data files to read')
            end
            
           
            
            for dataFileIndex = 1:numel(obj.dataFiles)


                % Find next file to open
                % Using file index to get next file in list
                filename = char(strcat(obj.header.folderName,'/',obj.dataFiles(dataFileIndex)));            

                % Try open file            
                [fileId,errMsg] = fopen(filename);
                if fileId < 0;
                    error(errMsg);
                    return
                end

                % One shot 32096, 24 shots in a package
                % 1040 packages in a file
                % 

                [pathstr, name, ext] = fileparts(filename);



                splitIndex = 1;
                while ~feof(fileId)
                    newFile = strcat(pathstr,'/',name,'_',num2str(splitIndex),ext);
                    splitIndex = splitIndex + 1;
                    [temp, n ] = fread(fileId, 32096*24*(1040/8));
                    if(n == 0)
                        
                        break;
                    end

                    [fileIdWrite, errMsg] = fopen(newFile,'w');
                    if fileIdWrite < 0;
                        error(errMsg);
                        fclose(fileId);
                        return
                    end

                    fwrite(fileIdWrite,temp);
                    fclose(fileIdWrite);

                end

                % Close File
                fclose(fileId);
                
            end
                    
        end        

        function tm = testMemmapFileVersion6(obj, filename)
            % Function test use of the function memmapfile as an
            % alternative to loading transducer recorded data into matlab
            % program. 
            import ppPkg.TransducerMeasurement
            
            % Retrieve part of header to find number of samples in each
            % shot
            mHeader = memmapfile(filename, 'Format', {... 
                'uint32', 1, 'date'; ...
                'uint32', 1, 'fireTime'; ...
                'uint32', 1, 'adcStartTime'; ...
                'uint16', 1, 'numSamples'}, 'Repeat', 1);
            
            numSamples = double(mHeader.Data.numSamples);
            
            % Memory map whole file
            m = memmapfile(filename, 'Format', {... 
                'uint32', 1, 'date'; ...
                'uint32', 1, 'fireTime'; ...
                'uint32', 1, 'startTimeRec'; ...
                'uint16', 1, 'numSamples'; ...
                'uint32', 1, 'xPos'; ...
                'uint32', 1, 'yPos'; ...
                'uint32', 1, 'zPos'; ...
                'uint32', 1, 'uPos'; ...
                'uint8', 1, 'transducerId'; ...
                'single', numSamples, 'signal' });
            
            numberOfShots = numel(m.Data);
            
            % Store data transducer data as a struct
            tm = m.Data;
            for index = 1:numberOfShots
                tm(index).sampleRate = obj.header.sampleRate;
                tm(index).fLow = obj.header.fLow;
                tm(index).fHigh = obj.header.fHigh;     
            end
            
            % Store data as transducer class. Note that this is actually
            % more time consuming. 
%             tm(numberOfShots) = TransducerMeasurement;
%             for index = 1:numberOfShots
%                 tm(index).signal = m.Data(index).signal;
%                 tm(index).date = m.Data(index).date;
%                 tm(index).fireTime = m.Data(index).fireTime;
%                 tm(index).startTimeRec = m.Data(index).adcStartTime;
%                 tm(index).transducerId = m.Data(index).transducerId;
%                 tm(index).xPos = m.Data(index).xPos;
%                 tm(index).yPos = m.Data(index).yPos;
%                 tm(index).zPos = m.Data(index).zPos;
%                 tm(index).uPos = m.Data(index).uPos;                
%                 tm(index).sampleRate = obj.header.sampleRate;
%                 tm(index).fLow = obj.header.fLow;
%                 tm(index).fHigh = obj.header.fHigh;
%             end
            
            
        end
                                
        
        % Function returns array of TM objects and a map(id,index)
        % This is an earlier version of function for importing data
        function [tm, transducerMap, header]= importData(obj, filename)
            fileId = -1;
            errMsg = '';
            
            % Create map (key=transducerId, arrayIndex)
            transducerMap = containers.Map('KeyType', 'uint32', 'ValueType', 'uint8');
            
            % Try open file            
            [fileId,errMsg] = fopen(filename);
            if fileId < 0;
                error(errMsg);
                return
            end
            
            fileId

            % Check number of transducer records in file 
            
            % Version
            [h.version, count] = fread(fileId, 1,'uint8');    
            if count < 1
                fclose(fileId);
                error(errorMsg);
            end
            
            % @TODO: Consider adding function for checking crc of whole file
            % before proceeding. 
                        
            
            if(h.version == 0)
                % Call function to read header version 0
                [tm, numberOfRec, header] = importDataVersion0(obj, h, fileId);
            elseif(h.version == 1)
                % Call function to read header version 1
                [tm, numberOfRec, header] = importDataVersion1(obj, h, fileId);
            elseif(h.version == 2)
                % Call function to read header version 2
                [tm, numberOfRec, header] = importDataVersion2(obj, h, fileId);                
            elseif(h.version == 3)
                % Call function to read header version 3
                [tm, numberOfRec, header] = importDataVersion3(obj, h, fileId);   
            elseif(h.version == 4)
                % Call function to read header version 2
                [tm, numberOfRec, header] = importDataVersion4(obj, h, fileId);                   
            else
                error('File version not supported')
            end
            fclose(fileId);
            

            % Check that number of tm object is as expected.
            if ne(numberOfRec, length(tm))                
                error('1, Error imporing transducer data'); 
            end
            
            % Iterate through array of tm objects to populate m
            numberOfTm = length(tm);
            
            for n = 1:numberOfTm;
                transducerMap(tm(n).transducerId) = n;
            end
            
            % Check that map contains expected number of values.
            if ne(transducerMap.Count,numberOfTm)
                disp('2, Error importing transducer data')
            end
                                                           
        end        
    end    
end

