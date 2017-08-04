classdef AlgorithmSet < handle
    % Class containing a set of algorithms
    %  
    
    properties
        callipAlg
        thicknessAlg
        noiseAlg
        NUMBER_OF_TRANSDUCERS = 10;
        config
        % pulse transmitted
        % pulse length
    end
    
    methods
        % @TODO specify needed arguments
        function obj = AlgorithmSet(configuration)
            import ppPkg.*;
            
            if(isa(configuration,'Configuration'))
                obj.config = configuration;
            else
                error('AlgorithmSet constructor: config object is of wrong type')
            end  
            
            % Construct Noise algorithm instance
            obj.noiseAlg = Noise(obj.NUMBER_OF_TRANSDUCERS, obj.config.FFT_LENGTH, obj.config.SAMPLE_RATE, obj.config.TS_ARRAY);
            
            % Construct Calliper algorithm instance
            obj.callipAlg = CalliperAlgorithm(obj.config.SAMPLE_RATE, obj.config.V_WATER);
            
            % Construct Thickness algorithm instance
            obj.thicknessAlg = ThicknessAlgorithm(obj.config);
        end
        
        % Run method:
        % Check data type; noise or shot data.
        % Noise:
        %   Run noise algorithm
        % Shot data:
        %   Run calliper algorithm
        %   Run thickness algorithm
    end    
end

