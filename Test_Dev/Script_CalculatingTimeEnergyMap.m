%> @file Script_CalculatingTimeEnergyMap.m
%> @brief calculate a Time Energy map for one file - 96 x 520 x 2000 mat
% ======================================================================
%> @

%> @brief Author: Chen Sun;
%
%> @brief Date: Sept 27, 2017 
% ======================================================================
                        if Trigger < signalEnd
                            energySlicing1(i)  = sum(Signal(Trigger + CoatingPoints + PulseLength : Trigger+CoatingPoints+RefInterval-5,i))/sum(Signal(:)); % Energy calculation for in between 1st and 2nd reflections.
                            if Trigger < signalEnd - 500
                                energySlicing2(i)  = sum(Signal(Trigger + 81 : Trigger+150))/sum(Signal(:)); % Energy calculation the next 600 points as resonance.
                            elseif  Trigger  > 1300 && Trigger < 1800
                                energySlicing2(i)  = sum(Signal(Trigger + 201 : signalEnd))/sum(Signal(:)); % Energy calculation the next 600 points as resonance.    
                            end
                        end                        
                        TimeEnergyMap1(k,:) = 1000*energySlicing1/sum(energySlicing1);
                        TimeEnergyMap2(k,:) = 1000*energySlicing2/sum(energySlicing2);