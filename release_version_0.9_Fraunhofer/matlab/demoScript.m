% First process data in RunProcessing.m script

% Demonstration on how to visualize pipe scan data from Oslo lab
scan = ViewPipeData(ctrlScan, 1)

% Plot thickness data
scan.plotThickness;
shading interp

% Plot Calliper data
scan.plotCalliper;
shading interp