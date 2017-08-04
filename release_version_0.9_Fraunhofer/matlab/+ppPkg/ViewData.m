classdef ViewData < handle
   %% ViewData can visualize recording of plate, scanned in x-y plane
   % Default grid resolution is 1 mm
   % 
   % Constructor:
   % Usage: scan = ViewData(ctrl)
   % 
   % For a different grid resolution:
   % 4mm grid:s
   % Usage: scan = ViewData(ctrl, 'gridX', 4, 'gridY', 4)
    
    properties
        ctrl
        x
        y
        xi
        yi
        thickness
        calliper
        prIndexM
    end
    
    properties (Access = private)
    
        min_x
        min_y
        min_z
        max_x
        max_y
        max_z
        
    end
    
    methods
        
        function obj = ViewData(ctrl, varargin)
            
            % Create function input parser object
            p = inputParser;
            
            % Default transducerId is set to 0, meaning all tranducers should be
            % used
            defaultGridX = 1;
            defaultGridY = 1;
                        
            addParameter(p,'gridX', defaultGridX, @isnumeric);
            addParameter(p,'gridY', defaultGridY, @isnumeric);

            % Parse function input
            parse(p, varargin{:})
            
            
            obj.ctrl = ctrl;  
            obj.x = (round([obj.ctrl.pr(:).xPos]/1000));
            obj.y = (round([obj.ctrl.pr(:).yPos]/1000));
            obj.thickness = [obj.ctrl.pr(:).thickness];
            obj.calliper = [obj.ctrl.pr(:).calliper];
            obj.min_x = (min(obj.x));
            obj.min_y = (min(obj.y));
            obj.max_x = (max(obj.x));
            obj.max_y = (max(obj.y));

            obj.prIndexM = zeros(obj.max_x - obj.min_x, obj.max_y - obj.min_y);

            for index = 1:length(obj.ctrl.pr)
               xPos = obj.x(index) - obj.min_x + 1;
               yPos = obj.y(index) - obj.min_y + 1;

               obj.prIndexM(xPos,yPos) = index;
            end                
                     

            [obj.xi, obj.yi] = meshgrid(obj.min_x:p.Results.gridX:obj.max_x, obj.min_y:p.Results.gridY:obj.max_y);  
        end 
        
        function adjustGrid(obj, varargin)
            % Change grid size
            % Usage: To change to a 5mm grid in x-y direction
            % obj.adjustGrid('gridX', 5, 'gridY', 5)
            
            % Create function input parser object
            p = inputParser;
            
            % Default transducerId is set to 0, meaning all tranducers should be
            % used
            defaultGridX = 1;
            defaultGridY = 1;
                        
            addParameter(p,'gridX', defaultGridX, @isnumeric);
            addParameter(p,'gridY', defaultGridY, @isnumeric);

            % Parse function input
            parse(p, varargin{:})
            
            [obj.xi, obj.yi] = meshgrid(obj.min_x:p.Results.gridX:obj.max_x, obj.min_y:p.Results.gridY:obj.max_y);  
            
        end
        
        
        function h = plotThickness(obj)
            % Plot a surf plot of thickness using current grid resolution
            si_thickness = griddata(obj.x, obj.y, obj.thickness, obj.xi, obj.yi,'cubic');                
            figure
            surf(obj.xi, obj.yi, si_thickness);
            title('Thickness plot')
        end
        
        function h = plotCalliper(obj)
            % Plot a surf plot of calliper using current grid resolution
            si_calliper = griddata(obj.x, obj.y, obj.calliper, obj.xi, obj.yi,'cubic');                
            figure
            surf(obj.xi, obj.yi, si_calliper);            
            title('Calliper plot')
        end           

        function pr = getPr(obj, xPos, yPos)
            % Get information about a point on the plots
            % Usage:
            % getPr(1,2)
            
            fprintf('xPos %d, yPos %d\n', xPos, yPos);
            x_min = min(obj.x);
            y_min = min(obj.y);            
            
            % Convert to index
            xIndex = xPos - x_min + 1;
            yIndex = yPos - y_min + 1;
            
            pr = obj.ctrl.pr( obj.prIndexM(xIndex,yIndex));
        end
            
    end
    
end

