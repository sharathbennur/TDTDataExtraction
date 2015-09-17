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

% Last Modified by GUIDE v2.5 02-Nov-2010 14:58:17

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

global data
data.GUI.cu= 2; % current unit default - unit1
% Choose default command line output for sGUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% Setup data.GUI which is used by various GUI elements
getMark;
% UIWAIT makes sGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
h=get(sGUI,'Children');
hc=findobj(h,'Tag','PriorTrial');

% set last trial to use for plot
v = get(hObject,'Value');
prior = floor((1-v).*(data.GUI.val(2)));

if prior<5
    data.GUI.val(1)=data.GUI.val(2)-5; % plot at least 5 trials
    uu = strcat('Prior trials to use = ',num2str(5));
else
    data.GUI.val(1) = data.GUI.val(2)-floor((1-v).*(data.GUI.val(2)));
    uu = strcat('Prior trials to use = ',num2str(prior));
end
set(hc,'string',uu);
chkTrials;

% % NEW
% data.GUI.val(1) = get(hObject,'Value');
% update_all;

% --- Executes on slider movement.
function currenttrial_slider_Callback(hObject, eventdata, handles)
% hObject    handle to currenttrial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global data
h=get(sGUI,'Children');
hc=findobj(h,'Tag','CurrentTrial');

% set first trial to use for plot
v = get(hObject,'Value');
current = ceil(size(data.codes.data,1).*v);

if current<5
    data.GUI.val(2)=5; % plot at least 5 trials
    uu = strcat('Current trial = ',num2str(5));
else
    data.GUI.val(2) = current;
    uu = strcat('Current trial = ',num2str(current));
end
set(hc,'string',uu);
chkTrials;

% % NEW
% data.GUI.val(2) = get(hObject,'Value');
% update_all;

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
% init to using all trials
data.GUI.val(2) = size(data.codes.data,1);

% % NEW
% data.GUI.val(1) = 0;

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
% init to starting with first trial
data.GUI.val(1) = 1;

% % NEW
% data.GUI.val(2) = 0;

% --- Executes on button press in update_button.
function update_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update_all;

% --- Executes on selection change in setzero.
function setzero_Callback(hObject, eventdata, handles)
% hObject    handle to setzero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns setzero contents as cell array
%        contents{get(hObject,'Value')} returns selected item from setzero

global data
v = get(hObject,'Value');
v2 = find(strcmp(data.GUI.markers{v},data.codes.name));

% zero spike times correctly
for i = 1:size(data.spikes,1)
    if ~isempty(data.spikes{i,data.GUI.cu})
        data.GUI.spikes{i,data.GUI.cu} = data.spikes{i,data.GUI.cu} - data.codes.data(i,v2);
    end
end
% also fill in time codes into data.GUI
data.GUI.codes = data.codes.data(:);
update_raster;

% % NEW
% data.GUI.s_zero = get(hObject,'Value');
% update_all;

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
%  data.GUI.s_zero = 1; % default


% --- Executes on selection change in marker1.
function marker1_Callback(hObject, eventdata, handles)
% hObject    handle to marker1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns marker1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from marker1

% % NEW
% data.GUI.m1 = get(hObject,'Value');
% update_all;

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


% --- Executes on selection change in marker2.
function marker2_Callback(hObject, eventdata, handles)
% hObject    handle to marker2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns marker2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from marker2

% % NEW
% data.GUI.m2 = get(hObject,'Value');
% update_all;

% --- Executes during object creation, after setting all properties.
function marker2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker2 (see GCBO)
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
 
% --- Executes during object creation, after setting all properties.
function raster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to raster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate raster
global data
data.GUI.cu= 2;

data.GUI.spikes = data.spikes;
hold on
ylim([data.GUI.val(1) data.GUI.val(2)]);
for k=data.GUI.val(1):data.GUI.val(2)
    train=data.GUI.spikes{k,data.GUI.cu};
    plot(train,k,'k+',...
        'MarkerSize',2);
end
% cur_xlim =  get(gca,'xlim');
% set(gca,'xlim',[-0.5 cur_xlim(2)])
hold off

% UTILITY FUNCTIONS
% get & fill markers
function getMark
    global data
    
    if isfield(data,'GUI')
        if isfield(data.GUI,'markers')
            return
        else
            data.GUI.markers = unique(data.codes.name)';
            % remove start-stop
            data.GUI.markers(numel(data.GUI.markers)-1:numel(data.GUI.markers))=[];
        end
    else
        data.GUI.markers = unique(data.codes.name)';
        % remove start-stop
        data.GUI.markers(numel(data.GUI.markers)-1:numel(data.GUI.markers))=[];
    end
        
% error check plot start and stop indices
function chkTrials
    if data.GUI.val(1)>=data.GUI.val(2)
        data.GUI.val(1)=1;
    end
            
% update the raster plot
function update_raster
    global data
    min_t=10;
    
    h=get(sGUI,'Children');
    hc=findobj(h,'Tag','raster');
    axes(hc);
    cla;
    hold on
    for k=data.GUI.val(1):data.GUI.val(2)
        train=data.GUI.spikes{k,data.GUI.cu};
        plot(train,k,'k+',...
            'MarkerSize',2);
        min_t = min(min_t,min(train));
    end
    cur_xlim =  get(gca,'xlim');
    set(gca,'xlim',[min_t-0.5 cur_xlim(2)])
    plot([0 0],[0 k],'b:')
    hold off
    
% recalc everything and update all plots
function update_all
global data

% first get everything
data.GUI.cu= 2;
spk = data.spikes; % make copy of spikes
nt = size(data.codes.data,1);
start = data.GUI.val(1); % prior
stop = data.GUI.val(2); % current
cu = data.GUI.cu; % current unit
nc = size(data.codes.data,2);
codes = data.codes.data(3:nc);

% figure out which trials to use
if start==0 && stop==0
    trial_st = 1;
    trial_stp = nt;
else
    trial_stp = ceil(nt.*stop);
    trial_st = ceil(trial_stp.*start);
end

% zero spikes appropriately
zer = data.GUI.markers{data.GUI.s_zero};
v = strcmp(zer,data.codes.name);

% zero spike times correctly
for i = 1:nt
    if ~isempty(spk{i,cu})
        spk{i,cu} = spk{i,cu} - data.codes.data(i,v);
    end
end
% also zero codes correctly
codes = codes-data.codes.data(:,v);

% set out markers
marks = zeros(trial_st-trial_stp,2);
m = data.GUI.markers{data.GUI.m1};
m1 = strcmp(m,data.codes.name);
marks(:,1) = codes(:,m1);
m = data.GUI.markers{data.GUI.m2};
m2 = strcmp(m,data.codes.name);
marks(:,2) = codes(:,m2);

% compute psth
psth_sp = [];
for k=trial_st:trial_stp
    temp_psth=spk{k,cu};
    psth_sp = horzcat(psth,temp_psth);
end
[psth,xout] = hist(psth_sp,200);
psth = nanrunmean(psth,5);

% Update all the text boxes
% current trial
h=get(sGUI,'Children');
hct=findobj(h,'Tag','CurrentTrial');
if trial_stp<=5
    trial_stp=5; % plot at least 5 trials
    uu = strcat('Current trial = ',num2str(5));
else
    uu = strcat('Current trial = ',num2str(trial_stp));
end
set(hct,'string',uu);
% prior trials
hpt=findobj(h,'Tag','PriorTrial');
if trial_st>trial_stp-5
    trial_st = trial_stp-5; % plot at least 5 trials
    uu = strcat('Prior trials to use = ',num2str(5));
else
    uu = strcat('Prior trials to use = ',num2str(trial_stp-trial_st));
end
set(hpt,'string',uu);

% update raster
hr=findobj(h,'Tag','raster');
cla(hr);
hold on
ylim(hr,[trial_st trial_stp]);
for k=trial_st:trial_stp
    train=spk{k,cu};
    plot(hr,train,k,'k+',...
        'MarkerSize',2);
end
set(hr,'xlim',[min(xout)-0.5 max(xout)+0.5])
plot(hr,[0 0],[0 k],'b:')
% plot markers
plot([trial_st trial_stp],marks(:,1))
plot([trial_st trial_stp],marks(:,2))

hold off

% update psth
hp=findobj(h,'Tag','psth');
cla(hp);
hold on
plot(xout,psth);
set(hp,'xlim',[min(xout)-0.5 max(xout)+0.5]);
plot(hr,[0 0],[0 max(psth)+0.1.*(max(psth))],'b-');
hold off
    
