%> @file Script_CalculatingCalliperMap.m
%> @brief calculate a calliper map for one file - 96 x 520 x 2000 mat
% ======================================================================
%> @

%> @brief Author: Chen Sun;
%
%> @brief Date: Sept 21, 2017 
% ======================================================================
%% Script for Calculating CalliperMap

            [envTop] = findEnvelopeUsingDiff(Signal);
            % find the maximum point of the envelope
            [valueMax,startMax] = max(envTop);
            % In case there is a decent peak before the maximum we found
            startPoint1 = round(startMax-deltaPoints*1.2);
            [valueM1,startM1] = max(envTop(startPoint1:startMax-10));
            startM1 = startPoint1 + startM1;            
            if valueM1>0.3*valueMax
                startMax = startM1;
            end
            CalliperMap(k,i) = (6601+startMax)/2/15000000*1480;