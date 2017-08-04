%> @file PeakMethod.m
%> @brief Enumeration class for Peak find methods
% ======================================================================
%> @brief Enumeration class for Peak find methods
% ======================================================================
classdef PeakMethod
   enumeration
      MIN_DB_ABOVE_NOISE, 
      MIN_PEAK_DISTANCE_AND_MIN_DB_ABOVE_NOISE, 
      MIN_PEAK_PROMINENCE_AND_MIN_DB_ABOVE_NOISE, 
      N_HIGEST_PEAKS, 
      N_HIGEST_PROMINENCE,
      TEST
   end
end