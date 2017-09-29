function varargout = MultiChnLoad(varargin)
% MULTICHNLOAD MATLAB code for MultiChnLoad.fig
% See also: GUIDE, GUIDATA, GUIHANDLES
% Last Modified by GUIDE v2.5 11-Sep-2017 15:30:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiChnLoad_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiChnLoad_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before MultiChnLoad is made visible.
function MultiChnLoad_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiChnLoad (see VARARGIN)

% Choose default command line output for MultiChnLoad
handles.output = hObject;

handles.figure2 = [];
handles.pathname = [];
handles.filename = [];
handles.metricdata.h1 = [];
handles.metricdata.h2 = [];
handles.thickness = [];
handles.markedthickness = [];
handles.LMax = [];

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes MultiChnLoad wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = MultiChnLoad_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
varargout{1} = handles.output;

% --- Executes on button press in LoadFile.
function LoadFile_Callback(hObject, eventdata, handles)
axes(handles.axes1);
cla;

Testing96D1;
Filename = strcat(PathName,filename);

handles = guidata(findobj('Name','MultiChnLoad'));

%set(handles.FilePath,'String',Filename);

msgbox('Process done!');
guidata(hObject, handles);

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

% --- Executes during object creation, after setting all properties.
function FilePath_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Plotting.
function Plotting_Callback(hObject, eventdata, handles)

if isempty(get(handles.FilePath,'String'))
    if isempty(handles.pathname)
        [filename,PathName]= uigetfile('*.mat');
    else
        [filename,PathName] = uigetfile([handles.pathname,'*.mat'],'Select the file');
    end
    dirF = dir(fullfile(PathName,filename));
    FileName = strcat(PathName,filename);
    set(handles.FilePath,'String',FileName);
    load(FileName);
    handles.pathname = PathName;
    handles.filename = filename;
    handles.signal = S;

else
    BinName = get(handles.FilePath,'String');
    FileName = strcat(BinName(1:end-4),'.mat');    
    
    if isempty(handles.filename)
        load(FileName);
%        handles.filename = FileName;
        handles.signal = S;
    else
        S = handles.signal;
    end    
end

channelValue = get(handles.listChannels,'Value');

if isempty(get(handles.ActualMapping,'String'))
%for Olympus
trLayout = [1 33 17 29 13 93 49 81 65 77 61 21 25 9 41 5 37 69 73 57 89 53 85 45 2 34 18 30 14 94 50 82 66 78 62 22 26 10 42 6 38 70 74 58 90 54 86 46 3 35 19 31 15 95 51 83 67 79 63 23 27 11 43 7 39 71 75 59 91 55 87 47 4 36 20 32 16 96 52 84 68 80 64 24 28 12 44 8 40 72 76 60 92 56 88 48];
% %for Olympus
% trLayout = 1:96;
% % for Fraunhofer.
% trLayout = [1 17 13 33 5 93 49 65 61 81 77 21 25 41 37 9 29 69 73 89 85 57 53 45 2 18 14 34 6 94 50 66 62 82 78 22 26 42 38 10 30 70 74 90 86 58 54 46 3 19 15 35 7 95 51 67 63 83 79 23 27 43 39 11 31 71 75 91 87 59 55 47 4 20 16 36 8 96 52 68 64 84 80 24 28 44 40 12 32 72 76 92 88 60 56 48];
% for Frauhofer old.
% trLayout = [54 63 72 81 90 3 12 21 60 69 78 87 96 9 18 27 66 75 84 93 6 15 24 33 48 57 36 42 45 51 30 39 53 62 71 80 89 2 11 20 58 68 77 86 95 8 17 26 65 74 83 92 5 14 23 32 47 56 35 41 44 50 29 38 46 55 64 73 82 91 4 13 52 61 70 79 88 1 10 19 58 67 76 85 94 7 16 25 40 49 28 34 37 43 22 31]
% for Frauhofer old.
% trLayout = [78 44 6 71 37 21 86 52 14 79 45 7 72 38 22 87 53 15 80 46 8 63 39 23 88 54 16 59 47 95 64 40 24 60 55 91 61 48 96 57 31 92 62 56 93 65 27 89 58 32 94 73 28 1 66 29 90 81 25 9 74 30 2 67 33 17 82 26 10 75 41 3 68 34 18 83 49 11 76 42 4 69 35 19 84 50 12 77 43 5 70 36 20 85 51 13 14];
set(handles.ActualMapping,'String',num2str(trLayout));
else
    trLayout = str2num(get(handles.ActualMapping,'String'));
end

StartChn = (channelValue-1)*12;
SNames = fieldnames(S);

PlottingChoice = get(handles.PlottingChoice,'Value');

% TimeYLimMin = 500;
% TimeYLimMax = 1200;
% SpectrumYLimMin = 200;
% SpectrumYLimMax = 1100;
TimeYLimMin = str2num(handles.TimeMin.String);
TimeYLimMax = str2num(handles.TimeMax.String);
SpectrumYLimMin = str2num(handles.SpectrumMin.String);
SpectrumYLimMax = str2num(handles.SpectrumMax.String);
scale = str2num(handles.TimeColorScale.String);
SpectrumScale = str2num(handles.SpectrumColorScale.String);
fftStart = str2num(handles.SignalStart.String);
fftEnd = str2num(handles.SignalEnd.String);


switch PlottingChoice    
    case 1
    signal = S.(SNames{trLayout(StartChn+1)});
%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes1);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+2)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes2);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+3)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes3);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+4)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes4);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+5)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes5);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+6)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes6);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+7)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes7);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+8)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes8);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+9)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes9);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+10)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes10);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+11)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes11);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    signal = S.(SNames{trLayout(StartChn+12)});

%             if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%             end
        axes(handles.axes12);
        gca,imagesc(signal');   
        set(gca,'YLim',[TimeYLimMin TimeYLimMax]);
    case 2
        nFFT = 4096;
        Fs = 15E6;
        %newSpectrogram = zeros(size(signal,1),nFFT);        
        axes(handles.axes1);
        signal = S.(SNames{trLayout(StartChn+1)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes2);
        signal = S.(SNames{trLayout(StartChn+2)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes3);
        signal = S.(SNames{trLayout(StartChn+3)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes4);
        signal = S.(SNames{trLayout(StartChn+4)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes5);
        signal = S.(SNames{trLayout(StartChn+5)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes6);
        signal = S.(SNames{trLayout(StartChn+6)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  
        
        axes(handles.axes7);
        signal = S.(SNames{trLayout(StartChn+7)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes8);
        signal = S.(SNames{trLayout(StartChn+8)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes9);
        signal = S.(SNames{trLayout(StartChn+9)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes10);
        signal = S.(SNames{trLayout(StartChn+10)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes11);
        signal = S.(SNames{trLayout(StartChn+11)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  

        axes(handles.axes12);
        signal = S.(SNames{trLayout(StartChn+12)});
%                 if max(max(signal(:,1400:2000))) > 0.8
%             signal((signal > 0.7)) = signal((signal > 0.7)) - 1;
%                 end
        for i = 1:size(signal,1)
           newSpectrogram(i,:) = abs(fft(signal(i,fftStart:fftEnd)/max(max(signal)),nFFT)); 
        end
        plotting = newSpectrogram(:,1:nFFT/2);
        gca,imagesc(plotting');
        set(gca,'YLim',[SpectrumYLimMin SpectrumYLimMax]);  
end

axesHandles = findobj(gcf,'Type','Axes');

StepofData = handles.StepofData.Value;
set(axesHandles(1:12),'XLim',[0 StepofData]);

if SpectrumScale == 0 && handles.PlottingChoice.Value == 2; 
 set(axesHandles(1:12),'CLimMode','auto');
 handles.SpectrumScale = get(axesHandles(1:12),'CLim');
elseif SpectrumScale ~= 0 && handles.PlottingChoice.Value == 2; 
    set(axesHandles(1:12),'CLim',[0 SpectrumScale]);
%set(axesHandles(1:12),'CLim',[0 SpectrumScale*handles.SpectrumScale]);
elseif scale == 0 && handles.PlottingChoice.Value == 1; 
 set(axesHandles(1:12),'CLimMode','auto');
 handles.SpectrumScale = get(axesHandles(1:12),'CLim');
else
    set(axesHandles(1:12),'CLim',[-scale scale]);
end

%update the channel numbers.

handles.ch1.String = num2str(StartChn+1);
handles.ch2.String = num2str(StartChn+2);
handles.ch3.String = num2str(StartChn+3);
handles.ch4.String = num2str(StartChn+4);
handles.ch5.String = num2str(StartChn+5);
handles.ch6.String = num2str(StartChn+6);
handles.ch7.String = num2str(StartChn+7);
handles.ch8.String = num2str(StartChn+8);
handles.ch9.String = num2str(StartChn+9);
handles.ch10.String = num2str(StartChn+10);
handles.ch11.String = num2str(StartChn+11);
handles.ch12.String = num2str(StartChn+12);

guidata(hObject, handles);


% --- Executes on button press in PlottingChoice.
function PlottingChoice_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of PlottingChoice
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

% --- Executes on selection change in listChannels.
function listChannels_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns listChannels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listChannels
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

% --- Executes on slider movement.
function StepofData_Callback(hObject, eventdata, handles)
handles.text7.String = num2str(get(hObject,'Value'));
Plotting_Callback(hObject, eventdata, handles);

% --- Executes on button press in LinkX.
function LinkX_Callback(hObject, eventdata, handles)
axesHandles = [handles.axes1 handles.axes2 handles.axes3 handles.axes4...
    handles.axes5 handles.axes6 handles.axes7 handles.axes8...
    handles.axes9 handles.axes10 handles.axes11 handles.axes12];

if get(hObject,'Value') == 1
    linkaxes(axesHandles,'x');
    
h = zoom;
h.Motion = 'horizontal';
h = pan;
h.Motion = 'horizontal';
end

% --- Executes on button press in LinkY.
function LinkY_Callback(hObject, eventdata, handles)
axesHandles = [handles.axes1 handles.axes2 handles.axes3 handles.axes4...
    handles.axes5 handles.axes6 handles.axes7 handles.axes8...
    handles.axes9 handles.axes10 handles.axes11 handles.axes12];

if get(hObject,'Value') == 1
    linkaxes(axesHandles,'y');
    linkaxes([handles.axes13 handles.axes14],'off');
h = zoom;
h.Motion = 'vertical';
h = pan;
h.Motion = 'vertical';
end

% --- Executes on button press in LinkOff.
function LinkOff_Callback(hObject, eventdata, handles)
axesHandles = [handles.axes1 handles.axes2 handles.axes3 handles.axes4...
    handles.axes5 handles.axes6 handles.axes7 handles.axes8...
    handles.axes9 handles.axes10 handles.axes11 handles.axes12];

if get(hObject,'Value') == 1
    linkaxes(axesHandles,'off');
h = zoom;
h.Motion = 'both';
h = pan;
h.Motion = 'both';
end

% --- Executes on button press in LinkXY.
function LinkXY_Callback(hObject, eventdata, handles)
axesHandles = [handles.axes1 handles.axes2 handles.axes3 handles.axes4...
    handles.axes5 handles.axes6 handles.axes7 handles.axes8...
    handles.axes9 handles.axes10 handles.axes11 handles.axes12];

if get(hObject,'Value') == 1
h = zoom;
h.Motion = 'both';
h = pan;
h.Motion = 'both';
    linkaxes(axesHandles,'xy');
end

function TimeColorScale_Callback(hObject, eventdata, handles)
% hObject    handle to TimeColorScale (see GCBO)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end


function SpectrumColorScale_Callback(hObject, eventdata, handles)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end


function TimeMin_Callback(hObject, eventdata, handles)
% hObject    handle to TimeMin (see GCBO)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

function TimeMax_Callback(hObject, eventdata, handles)
% hObject    handle to TimeMax (see GCBO)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

function SpectrumMin_Callback(hObject, eventdata, handles)
% hObject    handle to SpectrumMin (see GCBO)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

function SpectrumMax_Callback(hObject, eventdata, handles)
% hObject    handle to SpectrumMax (see GCBO)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

% --- Executes on button press in getTime.
function getTime_Callback(hObject, eventdata, handles)
% hObject    handle to getTime (see GCBO)
[x,~] = ginput(1);
axesObjs = gca;
dataObjs = axesObjs.Children;

data = dataObjs.CData;
XLim = axesObjs.YLim;

point = round(x);

pointData = data(:,point);

switch handles.PlottingChoice.Value
    case 1
        figure,plot(pointData);set(gca,'XLim',XLim);title('plot Time');
        Position = get(gcf,'Position');Position(3) = 800; Position(4) = 300;
        set(gcf,'Position',Position);
    case 2
        figure,plot(pointData);set(gca,'XLim',XLim);title('plot Spectrum');
        Position = get(gcf,'Position');Position(3) = 800; Position(4) = 300;
        set(gcf,'Position',Position);

        %figure,plot(mag2db(pointData));set(gca,'XLim',XLim);title('plot Spectrum');
        %figure,plot(runMean(mag2db(pointData),5)-runMean(mag2db(pointData),200));axis tight; title('plot Spectrum');
        ylabel('Magnitude (dB)');
end


function SignalStart_Callback(hObject, eventdata, handles)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

function SignalEnd_Callback(hObject, eventdata, handles)
axesHandles = findobj(gcf,'Type','Axes');
for i = 1:length(axesHandles)
XLim(i,:) = get(axesHandles(i),'XLim');
end
Plotting_Callback(hObject, eventdata, handles);
for i = 1:length(axesHandles)
set(axesHandles(i),'XLim',XLim(i,:));
end

% --- Executes on button press in Normalization.
function Normalization_Callback(hObject, eventdata, handles)
% hObject    handle to Normalization (see GCBO)
if isempty(handles.filename)
    Testing96D1;
else
    BinName = get(handles.FilePath,'String');
    FileName = strcat(BinName(1:end-4),'.mat');    
            load(FileName);
        handles.filename = FileName;
end

%% normalize to the main energy envelope.
if isempty(get(handles.ActualMapping,'String'))
trLayout = [1 33 17 29 13 2 49 81 65 77 61 21 25 9 41 5 37 69 73 57 89 53 85 45 93 34 18 30 14 94 50 82 66 78 62 22 26 10 42 6 38 70 74 58 90 54 86 46 3 35 19 31 15 95 51 83 67 79 63 23 27 11 43 7 39 71 75 59 91 55 87 47 4 36 20 32 16 96 52 84 68 80 64 24 28 12 44 8 40 72 76 60 92 56 88 48];
trLayout = 1:96
set(handles.ActualMapping,'String',num2str(trLayout));
else
    trLayout = str2num(get(handles.ActualMapping,'String'));
end

SNames = fieldnames(S);

for i = 1:numel(trLayout)
    signal = S.(SNames{trLayout(i)});
    lengthOfPoints = size(signal,1);
    
    for j = 1:lengthOfPoints
        tempSignal = signal(j,:);
        maximum = max(tempSignal);
        NormSignal(j,:) = tempSignal/maximum; % normalized the signal to have maximum at 1.        
    end    
    normalizedS.(SNames{trLayout(i)}) = NormSignal;    
end

filename = handles.FilePath.String;

S = normalizedS;

save(strcat(filename(1:end-4),'_Normalized.mat'),'S');

msgbox('Normalization done!');


% --- Executes on button press in PlotSpecEnergy.
function PlotSpecEnergy_Callback(hObject, eventdata, handles)
S = handles.signal;
trLayout = str2num(get(handles.ActualMapping,'String'));
SNames = fieldnames(S);
fftStart = str2double(handles.SignalStart.String);
fftEnd = str2double(handles.SignalEnd.String);

nFFT = 4096;
Fs = 15E6;

freqTolerance = 5; %frequency tolerance in filtering the desired frequency interal, in data points.
materialV = str2num(handles.materialV.String); % sound velocity of the material.

Direction = handles.Direction.Value;
startThickness = str2double(handles.SlicingStart.String);
endThickness = str2double(handles.SlicingEnd.String);

BaseFreqStartThickness = materialV/startThickness; %calculate using thickness equals to half wavelength.
BaseFreqEndThickness = materialV/endThickness;
BaseFreqStartPoints = round((nFFT/2)*BaseFreqStartThickness/Fs); % FFT is double sided.
BaseFreqEndPoints = round((nFFT/2)*BaseFreqEndThickness/Fs); % FFT is double sided.
    
% nFreqStart = floor((nFFT/2)/BaseFreqStartPoints); % number of harmonics in spectrum of the start thickness.
% nFreqEnd = floor((nFFT/2)/BaseFreqEndPoints); % number of harmonics in spectrum of the end thickness.
    
WeightFreqStart = BaseFreqStartPoints:BaseFreqStartPoints:nFFT/2;
WeightFreqEnd = BaseFreqEndPoints:BaseFreqEndPoints:nFFT/2;
    
WeightFreqInterval = [WeightFreqEnd(1:length(WeightFreqStart));WeightFreqStart];
   % calculate the energy slicing only for the central frequency band,
   % roughly at 200-1400 points (10%-70% of 2048 points).
nStartSlicing = floor(0.1*length(WeightFreqEnd));
nEndSlicing = floor(0.7*length(WeightFreqEnd));

newSpectrogram = zeros(4096,520);
NormalizedSpectrum = zeros(4096,520);
energySlicing = zeros(1,nEndSlicing-nStartSlicing+1);
EnergySlicing = zeros(96,520);

for chn = 1:96
signal = S.(SNames{trLayout(chn)});
        for i = 1:size(signal,1)
           newSpectrogram(:,i) = abs(fft(signal(i,fftStart:fftEnd),nFFT));
           % NormalizedSpectrum(:,i) = preprocessSpectrum(newSpectrogram(:,i));  
           if ~isequal(handles.CoatThickness.String,'CoatThk')&&~isequal(handles.CoatThickness.String,'0');
                NormalizedSpectrum(:,i) = newSpectrogram(:,i);  
           else
               baseline = envelope(newSpectrogram(:,i),120,'rms');
               NormalizedSpectrum(:,i) = baseline-newSpectrogram(:,i); % use the teeth rather than peaks.
           end
            %% slicing spectrum.
           for nSlicing = nStartSlicing:nEndSlicing
            energySlicing(nSlicing-nStartSlicing+1) = sum(NormalizedSpectrum(WeightFreqInterval(1,nSlicing)-freqTolerance:WeightFreqInterval(2,nSlicing)+freqTolerance,i));
           end
        EnergySlicing(chn,i) = sum(energySlicing)/sum(NormalizedSpectrum(:,i));              
        end
EnergySlicing(chn,:) = size(signal,1)*EnergySlicing(chn,:)/sum(EnergySlicing(chn,:)); %normalization.
%figure(111),plot(WeightFreqStart,zeros(length(WeightFreqStart),1)+i,'r*'),hold on;plot(WeightFreqEnd,zeros(length(WeightFreqEnd),1)+i,'bo');axis tight;
end

ToolSpeed = str2double(handles.FlowRate.String)/3.28; % convert from ft/s to m/s.
Aligned = lineupRings(ToolSpeed,EnergySlicing,Direction);

% figure(111);
% imagesc(EnergySlicing,[0.2 1.5]);
% figure(112);
% imagesc(Aligned,[0.2 1.5]);
axes(handles.axes13);
imagesc(Aligned);

handles.SpecEnergyMap = EnergySlicing;
guidata(hObject, handles);


% --- Executes on button press in PlotTimeEnergy.
function PlotTimeEnergy_Callback(hObject, eventdata, handles)
% hObject    handle to PlotTimeEnergy (see GCBO)
S = handles.signal;
trLayout = str2num(get(handles.ActualMapping,'String'));
SNames = fieldnames(S);
Direction = handles.Direction.Value;

Fs = 15E6;
materialV = str2double(handles.materialV.String); % sound velocity of the material.
coatingV = str2double(handles.coatingV.String); % sound velocity of the material.

newSignal = zeros(2000,520);
LMax = zeros(96,520);
PulseLength = 20; % length of the first pulse reflection.
startThickness = str2double(handles.SlicingStart.String);
endThickness = str2double(handles.SlicingEnd.String);

RefInterval = round(((startThickness+endThickness)*Fs/materialV)*1);  % calculate use the nominal thickness plus 20% tolerance.
energySlicing1 = zeros(1,520);
energySlicing2 = zeros(1,520);
EnergySlicing1 = zeros(96,520);
EnergySlicing2 = zeros(96,520);

if isequal(handles.CoatThickness.String,'CoatThk')
    CoatingPoints = 0;
elseif isequal(handles.CoatThickness.String,'0')
        CoatingPoints = 0;
else 
    CoatThickness = str2double(handles.CoatThickness.String);
    CoatingPoints = round(CoatThickness*2*Fs/coatingV);
end

for chn = 1:96
    Signal = S.(SNames{trLayout(chn)});
        for i = 1:520
           newSignal(:,i) = abs(Signal(i,:));%.*Signal(i,:);
           %NormalizedSignal(:,i) = newSignal(:,i)-runMean(newSignal(:,i),80);  
            %% slicing spectrum.
        Max = max(newSignal(:,i));
        LMax(chn,i) = find(newSignal(:,i)>0.6*Max,1); % find the first incline that has 60% of max value.
                
            if LMax(chn,i)<1800
                        energySlicing1(i)  = sum(newSignal(LMax(chn,i)+CoatingPoints+PulseLength:LMax(chn,i)+CoatingPoints+RefInterval-5,i))/sum(newSignal(:,i)); % Energy calculation for in between 1st and 2nd reflections.
                if LMax(chn,i) < 1300
                        energySlicing2(i)  = sum(newSignal(LMax(chn,i)+81:LMax(chn,i)+150,i))/sum(newSignal(:,i)); % Energy calculation the next 600 points as resonance.
                elseif LMax(chn,i) > 1300 && LMax(chn,i) < 1800
                        energySlicing2(i)  = sum(newSignal(LMax(chn,i)+201:end,i))/sum(newSignal(:,i)); % Energy calculation the next 600 points as resonance.    

                end
            else
            msgbox('one signal starts after data points 1800, check data');
            return
            end
        end 
    EnergySlicing1(chn,:) = 1000*energySlicing1/sum(energySlicing1);
    EnergySlicing2(chn,:) = 1000*energySlicing2/sum(energySlicing2);

end
handles.LMax = LMax;
ToolSpeed = str2double(handles.FlowRate.String)/3.28; % convert from ft/s to m/s.

switch handles.TimeSlicingChoice.Value
    case 1
        Aligned = lineupRings(ToolSpeed,EnergySlicing1,Direction);
        axes(handles.axes14);
        imagesc(Aligned,[0 4]);
    case 2
        Aligned = lineupRings(ToolSpeed,EnergySlicing2,Direction);
        axes(handles.axes14);
        imagesc(Aligned,[0 3.5]);
end

handles.TimeEnergyMap1 = EnergySlicing1;
handles.TimeEnergyMap2 = EnergySlicing2;

guidata(hObject, handles);

% --- Executes on selection change in TimeSlicingChoice.
function TimeSlicingChoice_Callback(hObject, eventdata, handles)


function SlicingStart_Callback(hObject, eventdata, handles)
% hObject    handle to SlicingStart (see GCBO)

function SlicingEnd_Callback(hObject, eventdata, handles)
% hObject    handle to SlicingEnd (see GCBO)

% --- Executes on button press in SaveEnergyPlot.
function SaveEnergyPlot_Callback(hObject, eventdata, handles)
PathName = handles.pathname;
FileName = handles.filename;
TimeEnergyMap1 = handles.TimeEnergyMap1;   
TimeEnergyMap2 = handles.TimeEnergyMap2;   
SpecEnergyMap = handles.SpecEnergyMap;   

[tok,rem]=strtok(FileName,'.');

mkdir(strcat(PathName,'MapResults'));
save(strcat(PathName,'MapResults\',tok,'_EnergyMap.mat'),'TimeEnergyMap1','TimeEnergyMap2','SpecEnergyMap');


% --- Executes on button press in LoadEneryPlot.
function LoadEneryPlot_Callback(hObject, eventdata, handles)

% --- Executes on button press in StitchMultiple.
function StitchMultiple_Callback(hObject, eventdata, handles)
%%
 if isempty(handles.pathname)
        [filename,PathName]= uigetfile('*.mat','MultiSelect', 'on');
    else
        [filename,PathName] = uigetfile([handles.pathname,'*.mat'],'Select the file','MultiSelect', 'on');
    end
%[filename,PathName]= uigetfile('*.mat','MultiSelect', 'on');
Direction = handles.Direction.Value;

datapointsPerFile = 520;
toolSpeed = str2double(handles.FlowRate.String)/3.28; % convert from ft/s to m/s.; % tool speed in m/s.

for i = 1:length(filename)
    Energymap = load(fullfile(PathName,cell2mat(filename(i))));
    
    TimeEnergyMap1 = Energymap.TimeEnergyMap1;
    newTimeEnergyMap1(:,datapointsPerFile*(i-1)+1:datapointsPerFile*i) = TimeEnergyMap1;
    TimeEnergyMap2 = Energymap.TimeEnergyMap2;
    newTimeEnergyMap2(:,datapointsPerFile*(i-1)+1:datapointsPerFile*i) = TimeEnergyMap2;
    SpecEnergyMap = Energymap.SpecEnergyMap;
    newSpecEnergyMap(:,datapointsPerFile*(i-1)+1:datapointsPerFile*i) = SpecEnergyMap;    
end

AlignedTimeEnergyMap1 = lineupRings(toolSpeed,newTimeEnergyMap1,Direction);
AlignedTimeEnergyMap2 = lineupRings(toolSpeed,newTimeEnergyMap2,Direction);
AlignedSpecEnergyMap = lineupRings(toolSpeed,newSpecEnergyMap,Direction);

%%
pipeDia = 36; % in inches.
physicalWidth= toolSpeed*5*40*length(filename); % in inches, every file is 5 second, 1m = 40 inches.
physicalCircumference = pipeDia*pi; % in inches.

height = 800;
width = round(height*(physicalWidth/physicalCircumference));
figure(4);
set(4,'Name','Harmonics Energy Map','Position',[350 60 width height]);
imagesc(AlignedSpecEnergyMap,[0.2 1.5]);
figure(5);
set(5,'Name','Time Energy Map 1','Position',[350 60 width height]);
imagesc(AlignedTimeEnergyMap1,[0 10]);
figure(6);
set(6,'Name','Time Energy Map 2','Position',[350 60 width height]);
imagesc(AlignedTimeEnergyMap2,[0 3.5]);

save(strcat(PathName,'stitchedEnergyMap.mat'),'newSpecEnergyMap','newTimeEnergyMap1','newTimeEnergyMap2');
savefig(4,strcat(PathName,'stitchedSpecEnergyMap-Aligned.fig'));
savefig(5,strcat(PathName,'stitchedTimeEnergyMap1-Aligned.fig'));
savefig(6,strcat(PathName,'stitchedTimeEnergyMap2-Aligned.fig'));


function FlowRate_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function FlowRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Aligned = lineupRings(ToolSpeed,MatrixNeedAlign,Direction)
%% Offset and line up the array
if nargin<2
    error('at least two argin is required');
    return
elseif nargin<3
    Direction = 1;    
end

    
% 
transducerPingRate = 104.1667;
% Position offset for each ring (in mm)
posArray = [0, 55.88, 111.76, 27.94, 83.82, 139.7]';
% if scan direction is opposite.
if Direction == 2
posArray = max(posArray)-posArray;
end

% Position offset for each transducer
posOffset = [posArray; posArray; posArray; posArray; ...
    posArray; posArray; posArray; posArray; ...
    posArray; posArray; posArray; posArray; ...
    posArray; posArray; posArray; posArray];

% Convert from mm to meter
posOffset = posOffset/1000;
numberOfSamplesOffsetPrChannel = round((posOffset/ToolSpeed)*transducerPingRate);

RefElementsToAdd = max(numberOfSamplesOffsetPrChannel);
allElementsToAdd = RefElementsToAdd-numberOfSamplesOffsetPrChannel;
    tempM = zeros(96,size(MatrixNeedAlign,2)+RefElementsToAdd);
    Aligned = tempM;
    
for index = 1:96
    elementsToRemove = numberOfSamplesOffsetPrChannel(index);
    elementsToAdd = allElementsToAdd(index);
    
    tempM = MatrixNeedAlign(index,:);
    
   %if(elementsToRemove > 0)
        % Remove elements in front
        %tempM(1:elementsToRemove) = [];
        
        % Append same amount of zeros to the end
        tempM = [zeros(1,elementsToAdd)+median(median(MatrixNeedAlign)) tempM zeros(1,elementsToRemove)+median(median(MatrixNeedAlign))];
    %end
     Aligned (index,:) = tempM;
end


% --- Executes on button press in updateThickness.
function updateThickness_Callback(hObject, eventdata, handles)
% hObject    handle to updateThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

S = handles.signal;
PlottingChoice = get(handles.PlottingChoice,'Value');
LMax = handles.LMax; % if there is saved calculation of first reflection peak.
trLayout = str2num(get(handles.ActualMapping,'String'));
SNames = fieldnames(S);

Fs = 15E6;
materialV = str2double(handles.materialV.String); % sound velocity of the material.
newSignal = zeros(2000,520);
startThickness = str2double(handles.SlicingStart.String);
timeFlight = round(startThickness*2*Fs/materialV); 

if isequal(get(handles.CoatThickness,'String'),'CoatThk');
coating = 0;
coatingThickness = 0;
elseif isequal(get(handles.CoatThickness,'String'),'0');
coating = 0;
coatingThickness = 0;    
else
    coating = 1;
coatingThickness = str2double(get(handles.CoatThickness,'String'));
end


coatingV = str2double(handles.coatingV.String);
%coatingThickness = 0.0024; % 3mm coating for mortar in DI.
coatingFlight = round(coatingThickness*2*Fs/coatingV); 
signalEnd = 1400; % where signal ends, for 12"DI there might be a 2nd set of reflections in the 2000 points range.

% button = questdlg('Choose 10 points from the first reference line',...
%         'Point Selection','Yes','No','Yes');
%     if button ~= 'Yes'
%         return
%         msgbox('user cancelled');
%     else
%         [x1,y1] = ginput(10);
%         axes1 = gca;
%     end
% button = questdlg('Choose 10 points from the second reference line',...
%         'Point Selection','Yes','No','Yes');  
%     if button ~= 'Yes'
%         return
%         msgbox('user cancelled');
%     else
%         [x2,y2] = ginput(10);
%         axes2 = gca;
% 
%     end
% 
%     if axes1 ~=axes2;
%         msgbox('both lines should be from the same channel');
%         return
%     else
%         Axes = axes1;
%     end
%     

if isempty(LMax)
    LMax = zeros(96,520);
    for chn = 1:96
    Signal = S.(SNames{trLayout(chn)});
        for i = 1:520
           newSignal(:,i) = abs(Signal(i,:));%.*Signal(i,:);
           %NormalizedSignal(:,i) = newSignal(:,i)-runMean(newSignal(:,i),80);  
            %% slicing spectrum.
        Max = max(newSignal(:,i));
        LMax(chn,i) = find(newSignal(:,i)>0.6*Max,1); % find the first incline that has 30% of max value.
        end
    end
    handles.LMax = LMax;
end

axesObjs = gca;
dataObjs = axesObjs.Children;
data = dataObjs.CData;
XLim = axesObjs.YLim;
Direction = handles.Direction.Value; % if scan with opposite direction.

switch PlottingChoice    
    case 1 % in time domain.
        [thickPoints,coatPoints] = Thickness(coating,S,trLayout,timeFlight,coatingFlight,signalEnd); % selecting 0 for coating as no coating, 1 as with coating.
        %%
        ToolSpeed = str2double(handles.FlowRate.String)/3.28; % convert from ft/s to m/s.; % tool speed in m/s.
        AlignedThickPoints = lineupRings(ToolSpeed,thickPoints,Direction); 
        %%
        thickness = thickPoints*materialV/(2*Fs);
        figure(3),imagesc(thickness,[0.008 0.012]);
        AlignedThickness = lineupRings(ToolSpeed,thickness,Direction); 
        figure(4),imagesc(AlignedThickness,[0.008 0.012]);

        %%
        gca;hold on;
        plot(x1,y1,'ro');plot(x2,y2,'go');
        p1 = spline(x1,y1);p2 = spline(x2,y2);
        Xmin1 = round(min(x1));Xmin2 = round(min(x2));
        Xmax1 = round(max(x1));Xmax2 = round(max(x2));
        X1 = linspace(Xmin1,Xmax1,Xmax1-Xmin1+1);
        f1 = ppval(p1,X1);
        X2 = linspace(Xmin2,Xmax2,Xmax2-Xmin2+1);
        f2 = ppval(p2,X2);
        gca;hold on;plot(X1,f1,'r');plot(X1,f1,'g');
        %%
    case 2 % in frequency domain.
        
        
end

guidata(hObject, handles);


% --- Executes on button press in saveThickness.
function saveThickness_Callback(hObject, eventdata, handles)
% hObject    handle to saveThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PCA.
function PCA_Callback(hObject, eventdata, handles)

%% -------------------- preparation of plotting -----------------------
if isempty(handles.figure2) || ~ishandle(handles.figure2)     
handles.figure2 = figure;
%handles.metricdata.figure2 = handles.figure2;

set(handles.figure2,'Position',[10 50 1400 800],'Name','Data Plotting','Units','Points',...
    'NumberTitle','off',... % clip of figure number.
    'WindowButtonDownFcn',@figure2_WindowButtonDownFcn,...
    'WindowButtonUpFcn',@figure2_WindowButtonUpFcn,...
    'WindowScrollWheelFcn',@figure2_WindowScrollWheelFcn);
handles.lbutton = uicontrol('Parent',handles.figure2,...
    'Units','normalized',...
    'Position',[0.02 0.94 0.05 0.05],...
    'Style','pushbutton',...
    'String','load Map',...
    'Callback','loadMap');
handles.lbutton = uicontrol('Parent',handles.figure2,...
    'Units','normalized',...    
    'Position',[0.07 0.94 0.05 0.05],...
    'Style','pushbutton',...
    'String','load Marker',...
    'Callback','loadMarker');
handles.lbutton = uicontrol('Parent',handles.figure2,...
    'Units','normalized',...    
    'Position',[0.02 0.02 0.05 0.05],...
    'Style','pushbutton',...
    'String','save Marker',...
    'Callback','saveMarker');
end

%% draw uilines on figure 2. 
% set up axes 1.  
if isempty(handles.metricdata.h1) || ~ishandle(handles.metricdata.h1)||isempty(handles.metricdata.h2) || ~ishandle(handles.metricdata.h2)    
h1 = axes('Parent',handles.figure2,...
    'Units','normalized','Position',[0.045 0.12 0.92 0.8],...
    'Color',[1 1 1],'FontName','Arial','FontSize',8, ...
    'Tag','OriAxis',...
    'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0],...
    'XLim',[0 1],'YLim',[0 1]);
    
title(h1,'Amplitude','FontName','Arial');
ylabel(h1,'Normalized amp','FontName','Arial');
set(h1, 'XLim',[min(XData) max(XData)],'YLim',[0.5 1.5]);

handles.metricdata.h1 = h1; 

% set up axes 2. 
    h2 = axes('Parent',handles.figure2,...
    'Units','normalized','Position',[0.0466 0.0584 0.919 0.429],...
    'Color',[1 1 1],'FontName','Arial','FontSize',8, ...
    'Tag','SmoAxis',...
    'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0],...
        'XLim',[0 1],'YLim',[0.5 1.5]);

namedisplay = strcat('Path: ',handles.metricdata.path,'   Name:',handles.metricdata.name(1,:));
title(h2,namedisplay,'FontName','Arial');

xlabel(h2,'Phase','FontName','Arial');
ylabel(h2,'Normalized phase','FontName','Arial');

set(h2, 'XLim',[min(XData) max(XData)],'YLim',[0.5 1.5]);
handles.metricdata.h2 = h2;
else
    % load data directly from storage.
    h1 = handles.metricdata.h1; 
    h2 = handles.metricdata.h2; 
end
%%


% --- Executes on button press in Debug.
function Debug_Callback(hObject, eventdata, handles)
% hObject    handle to Debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard
