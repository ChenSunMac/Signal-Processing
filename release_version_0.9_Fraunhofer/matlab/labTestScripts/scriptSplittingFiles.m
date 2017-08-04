%% Script will split data files of size ~800MB to chuncks of ~100MB files

import ppPkg.*

im = ImportHandler;

% Set folder containing data files
im.readFolder('D:\fromBlueNoseFtp\Flowloop_Test\Nov16\SplitTest\temp')

%% Split files
% by calling the following function:
im.splitFiles()