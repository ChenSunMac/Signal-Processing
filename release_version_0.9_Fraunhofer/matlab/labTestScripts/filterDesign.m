% Testing Filter design for shaping the emitted pulse
clear all
close all
addpath('labTestScripts')
load('psdForFilterDesign.mat')
load('psdF')

%% Use psd from transducer hydrophone measurement to create a matching signal 
% so that the signal can be as flat as possible. 
plot(psdF, psdForFilterDesign)
grid on

psdSwap = -psdForFilterDesign;

fVector = 0:0.5e6:7.5e6;
FFT_LENGTH = 4096;
SAMPLING_RATE = 15e6;

fVectorRange = 0: 0.5e6: 4e6;

index = round(fVectorRange*FFT_LENGTH/SAMPLING_RATE + 1);

psdPoints = psdSwap(index)

%% Then do some adjustments
psdPoints(1) = 23;
psdPoints(4) = 4;
psdPoints(8) = 12;
psdPoints(9) = 23;

psdPointsAdjusted = psdPoints

figure
plot(psdF, psdSwap, psdF(index), psdPointsAdjusted, 'o')
grid on
psdPointsAdjustedNormalized = psdPoints/max(psdPoints);

%% Design a filter that matches what we have calculated above

mbFilt = designfilt('arbmagfir','FilterOrder',60, ...
         'Frequencies',0:0.5e6:7.5e6,'Amplitudes',[psdPointsAdjustedNormalized ones(1,7)], ...
         'SampleRate',15e6);
h = fvtool(mbFilt)


%% Create signal that we can filter
import ppPkg.*
close all
s1 = SignalGenerator('chirp', 15e6, 30e-6, 0.3e6, 4.5e6);
%s.plotSignal
s1.plotSignal
%s1.plotPSD

%% Filter signal
figure
%x = filter( mbFilt, s1.signal);
%x = filter( mbFilt.Coefficients, 1, s1.signal);
x = filtfilt( mbFilt.Coefficients, 1, s1.signal);


%x = 
gain = max(x);
x = x * 1/gain;
subplot(2,1,1)
plot(s1.signal)
grid on
subplot(2,1,2)
plot(x)
grid on
%%
s2 = SignalGenerator('chirp', 15e6, 30e-6, 0.3e6, 3.8e6);
s2.signal = x;
s2.plotPSD;
s1.plotPSD

