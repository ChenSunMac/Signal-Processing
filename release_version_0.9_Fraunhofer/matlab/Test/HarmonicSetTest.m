classdef HarmonicSetTest < matlab.unittest.TestCase
    % Test for the Configuration class
    %   
    
    properties
        h
    end
    
    methods (Test)
        function testConstuctorDefaultValues(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation);            
            testCase.verifyEqual(f1, set.freqArray(1));
            testCase.verifyEqual(v1, set.valueArray(1));
        end
        
        function testVPClassA_1(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 6;
            VP2 = 0.8;
            VP3 = 6000;
            VP4 = 0.4;
            VP5 = 0;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'A');
            
           
        end
        
        function testVPClassA_2(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 5;
            VP2 = 0.8;
            VP3 = 6000;
            VP4 = 0.51;
            VP5 = 0;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'A');
                       
        end  
        
        function testVPClassA_3(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 5;
            VP2 = 0.7;
            VP3 = 6000;
            VP4 = 0.61;
            VP5 = 0;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'A');
                       
        end  
        
        function testVPClassA_4(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 3;
            VP2 = 1;
            VP3 = 6000;
            VP4 = 0.61;
            VP5 = 0;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'A');
                       
        end    
        
        function testVPClassA_5(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 2;
            VP2 = 1;
            VP3 = 6000;
            VP4 = 0.81;
            VP5 = 0;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'A');                       
        end    
        
        function testVPClassA_6(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 2;
            VP2 = 1;
            VP3 = 6000;
            VP4 = 0.51;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'A');                       
        end         

        function testVPClassB_1(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 6;
            VP2 = 0.4;
            VP3 = 6000;
            VP4 = 0.51;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'B');                       
        end   
        
        function testVPClassB_2(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 6;
            VP2 = 0.9;
            VP3 = 8000;
            VP4 = 0.51;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'B');                       
        end    
        
        function testVPClassB_3(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 6;
            VP2 = 0.4;
            VP3 = 8000;
            VP4 = 0.61;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'B');                       
        end      

        function testVPClassB_4(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 3;
            VP2 = 1;
            VP3 = 8000;
            VP4 = 0.61;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'B');                       
        end    

        function testVPClassB_5(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 2;
            VP2 = 1;
            VP3 = 8000;
            VP4 = 0.81;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'B');                       
        end      
        
        function testVPClassB_6(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 2;
            VP2 = 1;
            VP3 = 8000;
            VP4 = 0.51;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'B');                       
        end    
        
        function testVPClassB_7(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 3;
            VP2 = 0.5;
            VP3 = 8000;
            VP4 = 0.51;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'C');                       
        end  
        
        function testVPClassB_8(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 2;
            VP2 = 1;
            VP3 = 8000;
            VP4 = 0.4;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'C');                       
        end
        
        function testVPClassB_9(testCase)
            import ppPkg.*;
            f1 = 2; f2 = 3; index1 = 1; index2= 2;
            v1 = 2; v2 = 3; deviation = 1;
            set = HarmonicSet(f1, v1, index1, f2, v2, index2, deviation); 
            
            sampleRate = 15e6;
            fftLength = 1024;
            VP1 = 2;
            VP2 = 1;
            VP3 = 8000;
            VP4 = 0.1;
            VP5 = 30;
            set.validationParameter = [VP1, VP2, VP3, VP4, VP5];           
            testCase.verifyEqual(set.findVpClass(sampleRate, fftLength), 'C');                       
        end          
%         end        
    end
    
end


