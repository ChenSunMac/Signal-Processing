classdef TransducerMeasurementTest < matlab.unittest.TestCase
    % Test class for TransducerMeasurement class
    %   
    
    properties
    end
    
    methods (Test)
        function testConstuctorValidData(testCase)
            N = 100;
            x = 0:1:N-1;
            Fs = 15e6;
            F_high = 3e6;
            F_low = 1e6;
            import ppPkg.TransducerMeasurement;
            tm = TransducerMeasurement(x, Fs, F_high, F_low);  
            testCase.verifyEqual(N,tm.numSamples);
        end
    end
    
end

