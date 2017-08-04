%% Retrieve data using datastore to access ProcessingResult
fds = fileDatastore('C:\Users\Processing PC 01\Documents\MATLAB\pureRelease\matlab\results\test1','ReadFcn',@load,'FileExtensions','.mat')


%%
pr = readall(fds)

%% Create full ctrlScan object with pr data
for index = 1:numel(fds.Files)
    if(index == 1)
        ctrlScan = pr{index}.ctrlScan;
    elseif(index == 2)
        ctrlScan.pr = [ pr{index}.prRes ];
    else
        ctrlScan.pr = [ctrlScan.pr pr{index}.prRes ];
    end
    
end