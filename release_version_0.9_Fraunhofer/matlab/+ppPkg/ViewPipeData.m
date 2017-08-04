classdef ViewPipeData < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Standard deltaAngle is 0.370, but when we did measurment from 
        % the outside of the pipe we changed to 0.347 so that we got 1mm
        % resolution from the outside
        deltaAngle = 0.190;%0.370;%0.347;
        diameterPipe = 0.41;% 0.31;
        distancePrAngleStep;
        prIndexM;
        ctrl;
        angleDist;
        radialDist;
        heigthDist;
        anglei;
        radiali;
        heigthi;
        calliper;
        thickness;
        snr;
        useRadialDist;
        
    end
    
    methods
        function obj = ViewPipeData(ctrl, useRadialDist)
            z = double([ctrl.pr(:).zPos]);
            u = double([ctrl.pr(:).uPos]);
            
            obj.useRadialDist = useRadialDist;
            
            obj.ctrl = ctrl;
            
            obj.calliper =  double([obj.ctrl.pr(:).calliper]);
            obj.thickness = double([obj.ctrl.pr(:).thickness]);
            obj.snr = double([obj.ctrl.pr(:).snr]);
            
            if(obj.useRadialDist)
                obj.distancePrAngleStep = 2*pi*(obj.diameterPipe/2)*(obj.deltaAngle/360);
                obj.radialDist = round(obj.distancePrAngleStep*u/(obj.deltaAngle));
                obj.heigthDist = round(z./(1000));
                
                radialDistMin = min(obj.radialDist);
                radialDistMax = max(obj.radialDist);
                heigthDistMin = min(obj.heigthDist);
                heigthDistMax = max(obj.heigthDist);
                                    
                obj.prIndexM = zeros(radialDistMax - radialDistMin, heigthDistMax - heigthDistMin);

    %            radialDist = zeros(1,length());
                for index = 1:length(obj.ctrl.pr)
                   radialPos = obj.radialDist(index) - radialDistMin + 1;
                   heigthPos = obj.heigthDist(index) - heigthDistMin + 1;

                   obj.prIndexM(radialPos,heigthPos) = index;

                end

                heigthGridResolution = 1;
                radialGridResolution = 1;


                [obj.radiali,obj.heigthi] = meshgrid(radialDistMin:radialGridResolution:radialDistMax, heigthDistMin:heigthGridResolution:heigthDistMax);  
 
            else
                % Use angle and z
                
                obj.angleDist = u./1000;
                obj.heigthDist = round(z./1000);                                
                angleGridResolution = 0.370;
                heigthGridResolution = 1;
                
                angleDistMin = min(obj.angleDist);
                angleDistMax = max(obj.angleDist);
                heigthDistMin = min(obj.heigthDist);
                heigthDistMax = max(obj.heigthDist);                
                
                [obj.anglei,obj.heigthi] = meshgrid(angleDistMin:angleGridResolution:angleDistMax, heigthDistMin:heigthGridResolution:heigthDistMax);    
            end                                                          
            
        end
        
        function addData(obj, ctrl)
            z = [ctrl.pr(:).zPos];
            u = [ctrl.pr(:).uPos];
            
            obj.ctrl(end + 1) = ctrl;
            callip = [ctrl.pr(:).calliper];
            obj.calliper = [obj.calliper callip];
                
            if(obj.useRadialDist)
            
                obj.radialDist = [obj.radialDist round(obj.distancePrAngleStep*u/(obj.deltaAngle))];
                obj.heigthDist = [obj.heigthDist round(z./(1000))];
                           
                radialDistMin = min(obj.radialDist);
                radialDistMax = max(obj.radialDist);
                heigthDistMin = min(obj.heigthDist);
                heigthDistMax = max(obj.heigthDist);

                heigthGridResolution = 1;
                radialGridResolution = 1;

                [obj.radiali,obj.heigthi] = meshgrid(radialDistMin:radialGridResolution:radialDistMax, heigthDistMin:heigthGridResolution:heigthDistMax);  
            else
                
                obj.angleDist = [obj.angleDist u./1000];
                obj.heigthDist = [obj.heigthDist z./1000];                                
                angleGridResolution = 0.370;
                heigthGridResolution = 1; 
                
                angleDistMin = min(obj.angleDist);
                angleDistMax = max(obj.angleDist);
                heigthDistMin = min(obj.heigthDist);
                heigthDistMax = max(obj.heigthDist);                     
                
                [obj.anglei,obj.heigthi] = meshgrid(angleDistMin:angleGridResolution:angleDistMax, heigthDistMin:heigthGridResolution:heigthDistMax);  
            end
            
        end
        
        function angleAdjust(obj, angle)
            if(~obj.useRadialDist)
                obj.angleDist = obj.angleDist + angle;
                angleGridResolution = 0.370;
                heigthGridResolution = 1; 
                
                angleDistMin = min(obj.angleDist);
                angleDistMax = max(obj.angleDist);
                heigthDistMin = min(obj.heigthDist);
                heigthDistMax = max(obj.heigthDist);                     
                
                [obj.anglei,obj.heigthi] = meshgrid(angleDistMin:angleGridResolution:angleDistMax, heigthDistMin:heigthGridResolution:heigthDistMax);  
                
            end
        end

        function gridAdjust(obj, angleMin, angleMax, zMin, zMax)
            if(~obj.useRadialDist)
                angleGridResolution = 0.370;
                heigthGridResolution = 1; 
                
                angleDistMin = angleMin;
                angleDistMax = angleMax;
                heigthDistMin = zMin;
                heigthDistMax = zMax;                     
                
                [obj.anglei,obj.heigthi] = meshgrid(angleDistMin:angleGridResolution:angleDistMax, heigthDistMin:heigthGridResolution:heigthDistMax);  
                
            end

            
            
        end
        
        
        function si_thickness = plotThickness(obj)
                        
            figure
            
            if(obj.useRadialDist)
                si_thickness = griddata(obj.radialDist,obj.heigthDist, obj.thickness, obj.radiali,obj.heigthi,'cubic');
                surf(obj.radiali,obj.heigthi,si_thickness); 
            else
                si_thickness = griddata(obj.angleDist, obj.heigthDist, obj.thickness, obj.anglei,obj.heigthi,'cubic');                
                surf(obj.anglei,obj.heigthi,si_thickness);

                
            end
        end
        function si_calliper = plotCalliper(obj)
            
            figure
            
            if(obj.useRadialDist)
                
                %calliper = [obj.ctrl.pr(:).calliper];
                si_calliper = griddata(obj.radialDist, obj.heigthDist, obj.calliper, obj.radiali,obj.heigthi,'cubic');
                surf(obj.radiali,obj.heigthi,si_calliper); 
                
            else
                
                si_calliper = griddata(obj.angleDist, obj.heigthDist, obj.calliper, obj.anglei,obj.heigthi,'cubic');                
                surf(obj.anglei,obj.heigthi,si_calliper);
                
            end                        
            
        end     
        function si_snr = plotSNR(obj)
            
            figure
            
            if(obj.useRadialDist)
                
                %calliper = [obj.ctrl.pr(:).calliper];
                si_snr = griddata(obj.radialDist, obj.heigthDist, obj.snr, obj.radiali,obj.heigthi,'cubic');
                surf(obj.radiali,obj.heigthi,si_snr); 
                
            else
                
                si_snr = griddata(obj.angleDist, obj.heigthDist, obj.snr, obj.anglei,obj.heigthi,'cubic');                
                surf(obj.anglei,obj.heigthi,si_snr);
                
            end                        
            
        end          
                
        function si_callip = plotCalliperStraight(obj)

            figure
            
            %calliper = [obj.ctrl.pr(:).calliper];
            
            if(obj.useRadialDist)
                si_calliper = griddata(obj.radialDist,obj.heigthDist, obj.calliper, obj.radiali,obj.heigthi,'cubic');
            else
                si_calliper = griddata(obj.angleDist, obj.heigthDist, obj.calliper, obj.anglei,obj.heigthi,'cubic');                    
            end
            
            % Hack to get rid of NaN numbers
            si_calliper(isnan(si_calliper)) = 0.075;
            
            % Selected a line that goes through pipe in U direction
            callipLineUDirection = si_calliper(6,:);
            %callipLineZDirection = si_calliper(:,50);

            % Filter line get rid of random noise
            N = 10;
            b = (1/N)*ones(1, N);
            a = 1;            
            yU = filtfilt(b, a, callipLineUDirection);

            ydU = yU-max(yU);
            [N, M] = size(si_calliper);

            % Create a matrix of size (N,M) based on one row vector.
            ydMU = ydU;
            for i = 1:N-1
                ydMU  = cat(1, ydMU , ydU);
            end

            % Straigthen calliper surface:
            si_callip = si_calliper-ydMU;

           if(obj.useRadialDist)                
                surf(obj.radiali,obj.heigthi, si_calliper-ydMU);             
           else
               surf(obj.anglei,obj.heigthi,si_calliper-ydMU);
           end
            
        end
        
        function getPr(obj, uPos, zPos)
            
            fprintf('uPos %d, zPos %d\n', uPos, zPos);
            radialMin = min(obj.radialDist);
            heightMin = min(obj.heigthDist);
            
            % Convert to index
            uIndex = uPos - radialMin + 1;
            zIndex = zPos - heightMin + 1;
            obj.ctrl.pr(obj.prIndexM(uIndex,zIndex))
        end
        
        function pr = getPrFromFileIndex(obj, fileIndex)
            
            import ppPkg.ProcessingResult;
            pr = ProcessingResult; 

            prIndex = 1;
            for i = 1:length(obj.ctrl.pr)
                if(obj.ctrl.pr(i).fileIndex == fileIndex)
                    pr(prIndex) = obj.ctrl.pr(i);
                    prIndex = prIndex + 1;
                end
            end
        end        
    end
    
end

