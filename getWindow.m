        function win = getWindow(type, length)
            % Select window 
            windowType = lower(type);

            switch windowType
                case 'rect'
                    win = rectwin(length);                    

                case 'hamming'
                    win = hamming(length);                    

                case 'hanning'
                    win = hanning(length);                    
                    
                case 'kaiser'
                    win = kaiser(length, 2.5);                    

                otherwise
                    error('Window type not supported');                    
            end                        
        end    