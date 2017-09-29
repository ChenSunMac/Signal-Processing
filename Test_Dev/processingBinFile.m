%> @file processingBinFile.m
%> @brief transform one .bin file to 96 x 520 x 2000 .mat file
% ======================================================================
%> @brief Input: 
%       - PathName, Filename 
%       - round_per_read = 520
%
%> @brief Output:
%       - Signal in .mat format
%
%> @brief Author: Chen Sun; Yingjian Liu
%
%> @brief Date: Sept 13, 2017 
% ======================================================================

function [SignalMatrix] = processingBinFile(PathName,FileName)
        SignalMatrix = zeros(96,520,2000);
        dirF = dir(fullfile(PathName,FileName));
        sizeAll = dirF.bytes; % total bytes of 96 x 520 x 2000 data
        round_per_read = floor(sizeAll/32096/12); % = 520 
        fid=fopen(fullfile(PathName,FileName));
        status = fseek(fid,0,'bof');
        raw_data = fread(fid,32096*12*round_per_read,'uint8');
        fclose(fid);
%          % Check if is the last read
SignalMatrix = zeros(96,520,2000);
%         if size(raw_data,1)<32096
%             break
%         end
        sb=0;
        rp_i=0;
        ii=zeros(1,128);
        for i = 1:fix(size(raw_data,1)/32096) %128
            gain(i)   = uint8(raw_data(sb+24:sb+24)');
            raw_fireTime = uint8(raw_data(sb+25:sb+32)');
            fireTimeA(i)= typecast(raw_fireTime,'uint64');

            roll_b =typecast(uint8(raw_data(sb+17:sb+18)'),'int16');
            pitch_b =typecast(uint8(raw_data(sb+19:sb+20)'),'int16');
            if((roll_b~=8224)||(pitch_b~=8224))
                rp_i=rp_i+1;
                rp_locs(rp_i)=i;
                roll_r(i)=roll_b;
                pitch_r(i)=pitch_b;
            end

            for k=0:7

                raw_signal = uint8(raw_data(sb+k*4008+41:sb+k*4008+4040)');
                signal0 = (typecast(raw_signal, 'uint16'));
                signal0 = (double(signal0)-32768)/32768;

                % signal0(1)=32768;
                raw_firstRef = uint8(raw_data(sb+k*4008+33:sb+k*4008+34)');
                firstRef = typecast(raw_firstRef,'uint16');
                ch= uint8(raw_data(sb+k*4008+39));
                j=ch+1;
                ii(j)=ii(j)+1;

                SignalMatrix(j,ii(j),:)=signal0;  
            end
            %   Increment starting bit. Needed
            sb = sb + 32096;
        end
