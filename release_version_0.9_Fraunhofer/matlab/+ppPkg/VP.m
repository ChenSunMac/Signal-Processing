%> @file VP.m
%> @brief Enumeration class for validation parameter types
% ======================================================================
classdef VP < double   
    % Validation Parameter
    enumeration
        ABSOLUTE_NUM_HARMONICS (1)
        RELATIVE_NUM_HARMONICS (2)
        AVERAGE_DEVIATION (3)
        RELATIVE_Q_ABOVE_NOISE (4)
        TOTAL_RESONANCE_ENERGY (5)
        AVERAGE_RESONANCE_ENERGY (6)                  
    end   
end

