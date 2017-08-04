%> @file Configuration.m
%> @brief Contains configuration parameters for the post processing
%>        application
% ======================================================================
%> @brief Contains configuration parameters for the post processing
%>        application
%
%> 
% ======================================================================
classdef Configuration < matlab.mixin.Copyable %handle
    
    properties
        APPLICATION_VERSION
        V_PIPE              = 5920      % Sound velocity pipe wall
        V_WATER             = 1500      % Sound velocity water
        DELTA_F_PERCENTAGE  = 0         % Maximum allowed frequency deviation 
                                        % in percentage
        DEVIATION_FACTOR    = 10  
        DB_BELOW_MAX        = 6         % Maximum dB below max level   
        Q_DB_ABOVE_NOISE    = 6         % Db above noise floor
        Q_DB_MAX            = 20        % Maximum allowed Q
        D_NOM               = 0.04      % Nominal thickness of pipe wall
        D_MIN               = 0.002     % Minimum expected thickness of pipe wall
        DIAMETER_TOOL       = 0.3       % Diameter of tool
        DIAMETER_INTERNAL   = 1.0       % Internal diameter of pipe
        NOMINAL_DISTANCE_TO_WALL = 0.075% Usually this will be calculated 
                                        % based on Diameter tool and Diameter internal
        ADJUST_START_TIME_RESONANCE = 0 % Delay in time before calculation of 
        ADJUST_STOP_TIME_RESONANCE = 0 
                                        % resonance spectum
        delta_delay_rec     = 3000      % Number of samples in delay before 
                                        % recording starts.
                                        % 10 cm/1500m/s * Fs = 2000        
        NUMBER_OF_CHANNELS  = 0;
        FFT_LENGTH          = 4096
        WINDOW_RESONANCE    = 'hanning' % Window function for resonance PSD
        WINDOW_MAIN         = 'rect'    % Window function for absoption PSD 
        PERIODOGRAM_OVERLAP = 0.90      % Periodogram overlap in percentage ( 1 = 100%)
        PERIODOGRAM_SEGMENT_LENGTH = 500 
        USE_PWELCH          = false        
        MAX_WELCH_LENGTH    = 500
        NUMBER_OF_PERIODOGRAM_TO_AVERAGE = 2;
        DELTA_FREQUENCY_RANGE = 0;
        REQUIRED_NO_HARMONICS = 2
        SAMPLE_RATE         = 15e6      % Default sample rate
        PROMINENCE          = 15    
        TS_ADJUST_ENABLE    = false;
        TS_ADJUST_NOISE_ENABLE = false;
        DEBUG_INFO          = false;
        RESONANCE_PSD_SEARCH_FOR_PEAKS = true;
        LOCATION_MAP                    % Transducer location map.        
    end
        
    properties(Dependent)
        TS_ARRAY                    % Transducer Sensitiviy array            
    end
    
    methods

        % Import Transducer Sensitivity
        % Based on SAMPLE_RATE and FFT_LENGTH select correct TS.
        % TODO: A test with TS array containing zeros
        function ts = get.TS_ARRAY(obj)
                        
            if(obj.FFT_LENGTH == 1024)
                temp = load('ts/ts_1024', 'ts');
            elseif(obj.FFT_LENGTH == 2048)
                temp = load('ts/ts_2048', 'ts');
            elseif(obj.FFT_LENGTH == 4096)
                %temp = load('ts/ts_4096_modified', 'ts');
                temp = load('ts/ts_4096_modified_extended_gain_around_4MHZ', 'ts');                
            else
                %error('FFT length not supported')
                temp.ts = 0;
            end
            ts = temp.ts;
                       
        end
        
        function version = get.APPLICATION_VERSION(obj)
            filename = 'VERSION.md';
            [fileId,errMsg] = fopen(filename,'r');
            if fileId < 0
                error(errMsg);
                return
            end  
                       
            tline = fgetl(fileId);
            versionField = textscan(tline,'%s %s', 'Delimiter',':');
            version = deblank(char(versionField{2}));
            fclose(fileId);
            
            %%obj.APPLICATION_VERSION = version;
        end

        % Function returns an array of configuration objects.
        function [array] = getArrayOfObjects(obj, numberOfInstances)
            
            for i = 1:numberOfInstances
                array(i) = obj.copy;
            end            
        end
    end    
end

