classdef ConfigurationTest < matlab.unittest.TestCase
    % Test for the Configuration class
    %   
    
    properties
    end
    
    methods (Test)
        function testConstuctorDefaultValues(testCase)
            import ppPkg.Configuration;
            config = Configuration();            
            testCase.verifyEqual(5100,config.V_PIPE);
        end
    end
    
end

