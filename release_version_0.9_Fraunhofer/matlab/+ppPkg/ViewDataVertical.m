classdef ViewDataVertical < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prIndexM;
        ctrl;
        z;
        y;
        zi;
        yi;
        
    end
    
    methods
        function obj = ViewDataVertical(ctrl)
            obj.ctrl = ctrl;
            
            obj.y = double(round([ctrl.pr(:).yPos]/1000));
            obj.z = double(round([ctrl.pr(:).zPos]/1000));
            
            min_y = min(obj.y);
            min_z = min(obj.z);
            max_y = max(obj.y);
            max_z = max(obj.z);
            obj.prIndexM = zeros(max_z - min_z + 1, max_y - min_y + 1);
            
            [m, n] = size(obj.prIndexM);
            for index = 1:length(ctrl.pr)
               zPos = obj.z(index) - min_z + 1;
               yPos = obj.y(index) - min_y + 1;
               if(zPos>m ||yPos > n)
                   error('index out of bound');
               end
               

               obj.prIndexM(zPos,yPos) = index;
            end        
            zGridResolution = 1;
            yGridResolution = 1;            
            
            [obj.zi, obj.yi] = meshgrid(min_z:zGridResolution:max_z, min_y:yGridResolution:max_y);  
        end
        
        function si_thickness = plotThickness(obj)
            
            thickness = double([obj.ctrl.pr(:).thickness]);
            si_thickness = griddata(obj.z,obj.y, thickness, obj.zi,obj.yi,'cubic');
            figure
            surf(obj.zi,obj.yi,si_thickness); 
        end
        function plotCalliper(obj)
            
            calliper = double([obj.ctrl.pr(:).calliper]);
            si_calliper = griddata(obj.z,obj.y, calliper, obj.zi,obj.yi,'cubic');
            figure
            surf(obj.zi,obj.yi,si_calliper); 
        end     
        function getPr(obj, zPos, yPos)
            
            fprintf('zPos %d, yPos %d\n', zPos, yPos);
            zMin = min(obj.z);
            yMin = min(obj.y);
            
            % Convert to index
            zIndex = zPos - zMin + 1;
            yIndex = yPos - yMin + 1;
            obj.ctrl.pr(obj.prIndexM(zIndex,yIndex))
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