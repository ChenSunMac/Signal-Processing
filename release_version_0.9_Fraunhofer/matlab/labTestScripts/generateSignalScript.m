%% Create signals
import ppPkg.*

timeArray = 10e-6:10e-6:60e-6;

chirpFreq = [ 0.3e6 3.8e6;...
              0.3e6 3.0e6;...
              0.3e6 2.5e6;...
              0.3e6 2.0e6;...
              0.3e6 1.5e6;...
              0.3e6 1.0e6;...
              0.1e6 1.0e6]
          
for timeIndex = 1:length(timeArray)    
    for freqIndex = 1:length(chirpFreq)
        fLow = chirpFreq(freqIndex,1);
        fHigh = chirpFreq(freqIndex,2);

        s = SignalGenerator('sinc', 15e6, timeArray(timeIndex), fLow, fHigh);
        %s.saveToFile()
        %s.plotFFT;
        %pause() 
        %close all;
        
    end    
end
%%
s = SignalGenerator('chirp', 15e6, 20e-6, 1.5e6, 3.8e6);
s.saveToFile()
s.plotFFT;



%%
import ppPkg.*
close all
s = SignalGenerator('chirp', 15e6, 30e-6, 0.3e6, 3.8e6);
%s.plotSignal
s.plotSignal
s.plotPSD
%%
mbFilt = designfilt('arbmagfir','FilterOrder',60, ...
         'Frequencies',0:0.5e6:7.5e6,'Amplitudes',[0.6000    1.000    0.2667    0.33    0.3000    0.4667    0.3333    0.3000    0.7667 1 1 1 1 1 1 1], ...
         'SampleRate',15e6);
fvtool(mbFilt)


%%
% bpFilt = designfilt('bandpassfir','FilterOrder',10, ...
%          'CutoffFrequency1',1e6,'CutoffFrequency2',3e6, ...
%          'SampleRate',15e6);
     
bpFile = designfilt('bandpassiir', 'StopbandFrequency1', 1.5e6, 'PassbandFrequency1', 2e6, 'PassbandFrequency2', 3e6, 'StopbandFrequency2', 3.5e6, 'StopbandAttenuation1', 6, 'PassbandRipple', 1, 'StopbandAttenuation2', 3, 'SampleRate', 15000000, 'MatchExactly', 'passband');     
%%     
%y = filtfilt(mbFilt, s.signal);  
y = filter(mbFilt, s.signal);  
plot(y)
grid on
%%
fvtool(bpFile)
%%
signal = y;%s.signal;
FFT_LENGTH = 4096;%length(obj.signal);            

Y = fft( signal, FFT_LENGTH);
f = 15e6*(0:(FFT_LENGTH/2))/FFT_LENGTH;
P2 = abs(Y/FFT_LENGTH);
P1 = P2(1:FFT_LENGTH/2+1);
P1(2:end-1) = 2*P1(2:end-1);                        
plot(f,P1);            


xlabel('Frequency (f)')
ylabel('|P(f)|')  
grid on