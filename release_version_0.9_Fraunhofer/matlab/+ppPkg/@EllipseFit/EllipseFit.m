classdef EllipseFit < handle
    % Class containing ellipse fit algorithms
    % A wrapper class for the algorithms
    
    properties
        aMajor      % Semi-major axis
        bMinor      % Semi-minor axis
        angle       % Angle from the positive horizontal axis to the ellipse major axis.  
        xc, yc      % Ellipse center        
        params      % Parameters of the general quadratic curve represented:
                    %  ax^2 + bxy + cy^2 + dx + ey + f = 0
    end
    
    % Wrapper functions. Implementation is in separate files
    methods (Access = private)         
        [theta] = compute_guaranteedellipse_estimates(obj, data_points)
        [newpts, T] = normalise2dpts(obj, pts)
        a = direct_ellipse_fit(obj, data)
        [theta]  = compute_directellipse_estimates(obj, data_points)
        [theta] = guaranteedEllipseFit(obj, t, data_points )
        struct = levenbergMarquardtStep(obj, struct )
        struct = lineSearchStep( obj, struct )
        
        [RSS, XYproj] = residualsEllipse(obj, XY, ParG)
            
        varargout = plotellipse(obj, varargin)
    end
     
    methods
        function obj = EllipseFit()
            obj.aMajor = 0;
            obj.bMinor = 0;
            obj.angle = 0;
            obj.xc = 0;
            obj.yc = 0;
        end
        
        function obj = computeEllipseEstimate(obj, dataPoint)
            %% Function compute ellipse estimate and returns ellipse
            % parameters for the general quadratic curve represented by:
            % ax^2 + bxy + cy^2 + dx + ey + f = 0
            
            % Compute ellipse estimate
            obj.params = compute_guaranteedellipse_estimates(obj, dataPoint');
            
            % Copy
            a = obj.params(1);
            b = obj.params(2);
            c = obj.params(3);
            d = obj.params(4);
            e = obj.params(5);
            f = obj.params(6);
                        
            % calculated ellipse center    
            % See functions https://en.wikipedia.org/wiki/Ellipse
            obj.xc = (2*c*d - b*e) / ( b^2 -4*a*c);
            obj.yc = (2*a*e - b*d) / ( b^2 -4*a*c);

            % Calculate semi-major and semi-minor axis    
            obj.aMajor = -sqrt(2*(a*(e^2) + c*(d^2) - b*d*e + (b^2-4*a*c)*f)*(a+c + sqrt((a-c)^2 + b^2))) / (b^2 - 4*a*c);
            obj.bMinor = -sqrt(2*(a*(e^2) + c*(d^2) - b*d*e + (b^2-4*a*c)*f)*(a+c - sqrt((a-c)^2 + b^2))) / (b^2 - 4*a*c);

            % Calculate angle from the positive horizontal axis to the ellipse major axis.    
            obj.angle =( atan((c-a-sqrt((a-c)^2+b^2))/b));
                       
        end
        
        function distance = computeDistanceToEllipse(obj, dataPoint)
        %% Function computes distance from dataPoint to ellipse. 
        %  This distance representens deviation in calliper compared to
        %  nominel distance from center of pipe
            
            ellipseParam = [[obj.xc obj.yc], [obj.aMajor obj.bMinor], obj.angle]';
            
            distance = zeros(1, length(dataPoint));
            dataPointProj = zeros(length(dataPoint), 2);
            
            for index = 1:length(dataPoint)                
                [rss, dataPointProj(index,:)] = residualsEllipse(obj, ...
                                                       dataPoint(index,:), ...
                                                       ellipseParam);
                                                   
                distance(index) = sqrt(rss);
                
                % Calculate distance from ellipse center to projection 
                % point on the ellipse curve                                      
                distanceCenterToProjPoint = sqrt((obj.xc-dataPointProj(index,1))^2 + ...
                                                        (obj.yc-dataPointProj(index,2))^2);

                % Calculate distance from ellipse center to dataPoint                                       
                distanceCenterToPoint = sqrt( (obj.xc-dataPoint(index,1))^2 + ...
                                              (obj.yc-dataPoint(index,2))^2 );                                
                % Plot lines representing distance to ellipse
                line([dataPointProj(index,1) dataPoint(index, 1)], [dataPointProj(index,2) dataPoint(index, 2)])                
                
                % Inside or outside of ellipse
                if( distanceCenterToPoint < distanceCenterToProjPoint)
                    distance(index) = -distance(index);
                end
                
            end
            
        end
        
        
                               
        function h = plotParametric(obj)
            disp('Plot using parametric form')

            % Plot using parametric form  
            t = linspace(0, 2*pi, 2000);
            xt = obj.aMajor * cos(t);
            yt = obj.bMinor * sin(t);

            % Apply rotation by angle theta
            cot = cos(obj.angle); 
            sit = sin(obj.angle);

            x = obj.xc + xt * cot - yt * sit;
            y = obj.yc + xt * sit + yt * cot;

            
            h = plot(x, y, 'r-', obj.xc, obj.yc,'r*');           
            axis equal
            grid on
        end
        
        function plotEzplot(obj)
            disp('Plot using function ezplot')
            a = obj.params(1);
            b = obj.params(2);
            c = obj.params(3);
            d = obj.params(4);
            e = obj.params(5);
            f = obj.params(6);    
            
            minX = -0.1;
            maxX = 0.1;
            minY = -0.1;
            maxY = 0.1;
            fh = @(x,y) (a*x.^2 + b*x.*y + c*y.^2 + d*x + e*y + f);
            ezplot(fh, [minX maxX minY maxY]);
            axis([minX maxX minY maxY]);
            axis equal    
            grid on
        end
        
        function plotEllipse(obj)            
            plotellipse(obj, [obj.xc; obj.yc], obj.aMajor, obj.bMinor, obj.angle)
            grid on            
        end
        
        function plotData(obj, datapoint)
            
           
            obj.plotParametric();
            hold on                                    
            plot(datapoint(:,1),datapoint(:,2),'b*');                
        end
        
        function plotToolCircle(obj, diameter)
            % Plot using parametric form  
            t = linspace(0, 2*pi, 2000);
            xt = (diameter/2) * cos(t);
            yt = (diameter/2) * sin(t);

            % Apply rotation by angle theta
            cot = cos(obj.angle); 
            sit = sin(obj.angle);

            x = xt * cot - yt * sit;
            y = xt * sit + yt * cot;

            
            h = plot(x, y);                   
        end
        
        function plotPerfectCircle(obj)
            
            diameter = (obj.aMajor + obj.bMinor);
            % Plot using parametric form  
            t = linspace(0, 2*pi, 2000);
            xt = (diameter/2) * cos(t);
            yt = (diameter/2) * sin(t);

            % Apply rotation by angle theta
            cot = cos(obj.angle); 
            sit = sin(obj.angle);

            x = obj.xc + xt * cot - yt * sit;
            y = obj.yc + xt * sit + yt * cot;

            
            h = plot(x, y);                   
        end
    end
    
end

