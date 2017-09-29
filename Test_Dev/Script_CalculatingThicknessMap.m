%> @file Script_CalculatingThicknessMap.m
%> @brief calculate a thickness map for one file - 96 x 520 x 2000 mat
% ======================================================================
%> @

%> @brief Author: Chen Sun;
%
%> @brief Date: Sept 27, 2017 
% ======================================================================
%% Script for Calculating CalliperMap
                        MainReflection = Signal(Trigger: j + 279);
                        C=abs(conv(MainReflection,s));
                        %C=envelope(SS,8,'rms');
                        [pksP,locsP] = findpeaks(C,'MinPeakDistance',0.2*timeFlight);
                        envlop = interp1(t(locsP),C(locsP),t,'spline');
                        %,min peak distance to be 20% of timeFlight, assuming most defects within 80% of loss.
                        [pksa,locsa] = findpeaks(envlop,'MinPeakProminence',0.8,'MinPeakDistance',0.2*timeFlight);
                        df=diff(locsa);
                        if(size(df,2)>0) %means find at least two peaks and have 1 diff.                       
                            if hasCoating == 0
                                coatPoints(k,i)=0;
                                n = median(df);
                                if n<timeFlight*1.2 % calculated points must not be over 120% of nominal.
                                    thickPoints(k,i)=n;
                                end
                            elseif hasCoating ==1
                            %% if coating fell at this point, assumuing bare metal at least 5 peaks can be found.
                                if df(1) < coatingFlight-7 && df(1)> coatingFlight+7 % if df(1) doesnt match with nominal coating thickness.
                                    coatPoints(k,i)=0;
                                    thickPoints(k,i)=df(1);
                                    % if coating is there
                                else
                                    coatPoints(k,i)=df(1);
                                    if(size(df,2)>1)&&(pksa(3)>pksa(2)) % if pksa 3 is metal and pksa 2 is coating, and metal signal stronger than coating.
                                        thickPoints(k,i)=df(2);
                                    elseif (size(df,2)>2)&&(pksa(4)>pksa(3)) % if pksa 4 is metal and pksa 2 and 3 is coating, and metal signal stronger than coating.
                                        thickPoints(k,i)=df(2)+df(3);
                                    elseif (size(df,2)>3)&&(pksa(5)>pksa(4))
                                        thickPoints(k,i)=df(2)+df(3)+df(4);
                                    elseif (size(df,2)>1)&&(abs(df(1)-df(2))>3) %if df(1) and df(2) are not the same reflection, ex. one for coating one for metal. means only one detected coating before metal.
                                        thickPoints(k,i)=df(2);
                                    elseif(size(df,2)>2)&&(abs(df(2)-df(3))>3) % means two detected coating before metal.
                                        thickPoints(k,i)=df(2)+df(3);
                                    elseif (size(df,2)>3)&& (abs(df(3)-df(4))>3) % means three detected coating before metal.
                                        thickPoints(k,i)=df(2)+df(3)+df(4);
                                    end
                                
                                end
                            end
                        end