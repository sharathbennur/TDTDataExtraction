function varargout = sGUI(varargin)
% SGUI MATLAB code for sGUI.fig
%      SGUI, by itself, creates a new SGUI or raises the existing
%      singleton*.
%
%      H = SGUI returns the handle to a new SGUI or the handle to
%      the existing singleton*.
%
%      SGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SGUI.M with the given input arguments.
%
%      SGUI('Property','Value',...) creates a new SGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sGUI

% Last Modified by GUIDE v2.5 21-Jan-2013 16:39:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @sGUI_OutputFcn, ...
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

% --- Executes just before sGUI is made visible.
function sGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sGUI (see VARARGIN)

global data;
data.GUI.cu=1; % current unit default - unsorted
% Choose default command line output for sGUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% Setup data.GUI which is used by various GUI elements
getMark;
% UIWAIT makes sGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% This sets up the initial plot - only do when we are invisible
% so window can get raised using trial1.

% --- Outputs from this function are returned to the command line.
function varargout = sGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function priortrial_slider_Callback(hObject, eventdata, handles)
% hObject    handle to priortrial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global data

% NEW
data.GUI.val(1) = get(hObject,'Value');
update_all;

% --- Executes on slider movement.
function currenttrial_slider_Callback(hObject, eventdata, handles)
% hObject    handle to currenttrial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global data

% NEW
data.GUI.val(2) = get(hObject,'Value');
update_all;

% --- Executes during object creation, after setting all properties.
function priortrial_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to priortrial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global data
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% NEW
data.GUI.val(1) = 0;

% --- Executes during object creation, after setting all properties.
function currenttrial_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currenttrial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global data
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% NEW
data.GUI.val(2) = 1;

% --- Executes on button press in update_button.
function update_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_all;

% --- Executes on selection change in setzero.
function setzero_Callback(hObject, eventdata, handles)
% hObject    handle to setzero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns setzero contents as cell array
%        contents{get(hObject,'Value')} returns selected item from setzero

global data

% NEW 
data.GUI.s_zero = get(hObject,'Value');
update_all;

% --- Executes during object creation, after setting all properties.
function setzero_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setzero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global data
getMark;

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% fill it
 set(hObject,'string',data.GUI.markers)

 % NEW
 data.GUI.s_zero = 0; % init


% --- Executes on selection change in marker1.
function marker1_Callback(hObject, eventdata, handles)
% hObject    handle to marker1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns marker1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from marker1
global data

% NEW 
data.GUI.m1 = get(hObject,'Value');
update_all;

% --- Executes during object creation, after setting all properties.
function marker1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global data
getMark;

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% fill it
set(hObject,'string',data.GUI.markers)
data.GUI.m1 = 0; % first time

% --- Executes on selection change in marker2.
function marker2_Callback(hObject, eventdata, handles)
% hObject    handle to marker2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns marker2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from marker2
global data
% NEW
data.GUI.m2 = get(hObject,'Value');
update_all;

% --- Executes during object creation, after setting all properties.
function marker2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global data
getMark;

% fill it
set(hObject,'string',data.GUI.markers)
data.GUI.m2 = 0; % first time


% --- Executes during object creation, after setting all properties.
function raster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to raster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate raster

% --- Executes on selection change in unitpicker.
function unitpicker_Callback(hObject, eventdata, handles)
% hObject    handle to unitpicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns unitpicker contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unitpicker
global data
% NEW
data.GUI.cu = get(hObject,'Value');
update_all;


% --- Executes during object creation, after setting all properties.
function unitpicker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unitpicker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global data
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% init
for i=1:size(data.spikes,2)
    if i==1
        data.GUI.units{1} = 'unsorted';
    else
        data.GUI.units{i} = strcat('unit-',num2str(i-1));
    end
end
set(hObject,'string',data.GUI.units)


% UTILITY FUNCTIONS
% get & fill markers
function getMark
    global data
    
    if isfield(data,'GUI')
        if isfield(data.GUI,'markers')
            return
        else
            % remove non-timing codes
            data.GUI.markers = data.codes.name(4:6);
        end
    else
        % remove non-timing codes
        data.GUI.markers = data.codes.name(4:6);
    end
        
% MAIN FUNCTION 
% compute everything and update all plots
function update_all
global data

% first get everything
spk = data.spikes; % make copy of spikes
nt = size(data.codes.data,1);
start = data.GUI.val(1); % prior
stop = data.GUI.val(2); % current
cu = data.GUI.cu; % current unit
codes = data.codes.data(:,4:6);

% figure out which trials to use
if data.GUI.s_zero==0 % init
    trial_st = 1;
    trial_stp = nt;
else
    trial_stp = ceil(nt.*stop);
    trial_st = ceil(trial_stp.*start);
end

% error check trial settings
if trial_stp<5
    trial_stp=5; % at least 5 trials
end
if trial_st==0
    trial_st=1;
elseif trial_stp-trial_st<5
    trial_st = trial_stp-5+1;
end

% % debug
% disp(num2str(data.GUI.s_zero))
% disp(strcat('trial_st_val=',num2str(data.GUI.val(1))))
% disp(strcat('trial_stp_val=',num2str(data.GUI.val(2))))
% disp(strcat('trial-st=',num2str(trial_st)))
% disp(strcat('trial-stp=',num2str(trial_stp)))

% zero spikes appropriately
if data.GUI.s_zero~=0 % ~init
    zer = data.GUI.markers{data.GUI.s_zero};
    v = strcmp(zer,data.codes.name);
    % zero spike times correctly
    for i = 1:nt
        if ~isempty(spk{i,cu})
            spk{i,cu} = spk{i,cu} - data.codes.data(i,v);
        end
    end
    % also zero codes correctly
    vcol = repmat(data.codes.data(:,v),1,3);
    codes = codes-vcol;
end

% set out markers
marks = [];
if data.GUI.m1~=0 % not init
    marks(:,1) = codes(:,data.GUI.m1);
else
    marks(:,1) = nan(nt,1);
end
if data.GUI.m2~=0 % not init
    marks(:,2) = codes(:,data.GUI.m2);
else
    marks(:,2) = nan(nt,1);
end
% filter
marks = marks(trial_st:trial_stp,:);

% compute psth
psth_sp = [];
for k=trial_st:trial_stp
    temp_psth=spk{k,cu};
    psth_sp = horzcat(psth_sp,temp_psth);
end
[psth,xout] = hist(psth_sp,200);
psth = nanrunmean(psth,5);

% Update all the text boxes
% current trial
h=get(sGUI,'Children');
hct=findobj(h,'Tag','CurrentTrial');
uu = strcat('Current trial = ',num2str(trial_stp));
set(hct,'string',uu);
% prior trials
hpt=findobj(h,'Tag','PriorTrial');
uu = strcat('Prior trials to use = ',num2str(trial_stp-trial_st+1));
set(hpt,'string',uu);

% update raster
hr=findobj(h,'Tag','raster');
axes(hr);
hold on
cla;
ylim([trial_st trial_stp]);
for k=trial_st:trial_stp
    train=spk{k,cu};
    if ~isempty(train)
        plot(train,k,'k+',...
            'MarkerSize',2);
    end
end
set(gca,'xlim',[min(xout)-0.5 max(xout)+0.5])
plot(zeros(k,1),trial_st:1:trial_stp,'b*','MarkerSize',4)
% plot markers
if ~isempty(marks)
    plot([marks(:,1) marks(:,1)],trial_st:1:trial_stp,'r*','MarkerSize',4)
    plot([marks(:,2) marks(:,2)],trial_st:1:trial_stp,'g*','MarkerSize',4)
end
hold off

% update psth
hp=findobj(h,'Tag','psth');
axes(hp);
hold on
cla;
plot(xout,psth,'k-','LineWidth',1);
set(gca,'xlim',[min(xout)-0.5 max(xout)+0.5]);
% plot zero
plot([0 0],[0 max(psth)+0.1.*(max(psth))],'b--','LineWidth',2);
% plot markers
if ~isempty(marks)
    plot([nanmean(marks(:,1)) nanmean(marks(:,1))],[0 max(psth)+0.1.*(max(psth))],'r--','LineWidth',2);
    plot([nanmean(marks(:,2)) nanmean(marks(:,2))],[0 max(psth)+0.1.*(max(psth))],'g--','LineWidth',2);
end
hold off
    

% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filemenufcn(hObject,'FileSave')


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10


% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
