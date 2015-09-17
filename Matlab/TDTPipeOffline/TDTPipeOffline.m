function varargout = TDTPipeOffline(varargin)
% TDTPIPEOFFLINE MATLAB code for TDTPipeOffline.fig
%      TDTPIPEOFFLINE, by itself, creates a new TDTPIPEOFFLINE or raises the existing
%      singleton*.
%
%      H = TDTPIPEOFFLINE returns the handle to a new TDTPIPEOFFLINE or the handle to
%      the existing singleton*.
%
%      TDTPIPEOFFLINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TDTPIPEOFFLINE.M with the given input arguments.
%
%      TDTPIPEOFFLINE('Property','Value',...) creates a new TDTPIPEOFFLINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TDTPipeOffline_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TDTPipeOffline_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TDTPipeOffline

% Last Modified by GUIDE v2.5 18-Dec-2012 15:55:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TDTPipeOffline_OpeningFcn, ...
                   'gui_OutputFcn',  @TDTPipeOffline_OutputFcn, ...
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


% --- Executes just before TDTPipeOffline is made visible.
function TDTPipeOffline_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TDTPipeOffline (see VARARGIN)

% Choose default command line output for TDTPipeOffline
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global CurrentTank;
global CurrentBlock;
global CurrentEvent;
CurrentTank = handles.activex5.ActiveTank;
CurrentBlock = handles.activex10.ActiveBlock;
CurrentEvent = handles.activex7.ActiveEvent;

% Set server to 'Local'
handles.activex5.UseServer = 'Local';
handles.activex5.Refresh;
global CurrentServer;
CurrentServer = 'Local';
global TT;
TT = actxcontrol('TTank.X');

% UIWAIT makes TDTPipeOffline wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TDTPipeOffline_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function activex5_TankChanged(hObject, eventdata, handles)
% hObject    handle to activex2 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% Process Server and Tank selection information for TTankInterfaces.BlockSelect
handles.activex10.UseServer = eventdata.ActServer;
handles.activex10.UseTank = eventdata.ActTank;

% Deselects the previously selected Block if the current Tank is changed
handles.activex10.ActiveBlock = '';
handles.activex10.Refresh;

% Deselects the previously selected Event and clears the event list if the current Tank is changed
handles.activex7.UseBlock = '';
handles.activex7.ActiveEvent = '';
handles.activex7.Refresh;

global CurrentTank;
CurrentTank = eventdata.ActTank;


% --------------------------------------------------------------------
function activex10_BlockChanged(hObject, eventdata, handles)
% hObject    handle to activex10 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% Process Server, Tank, and Block selection information for TTankInterfaces.EventSelect
handles.activex7.UseServer = eventdata.ActServer;
handles.activex7.UseTank = eventdata.ActTank;
handles.activex7.UseBlock = eventdata.ActBlock;

% Deselects the previously selected Event if the current Block is changed
handles.activex7.ActiveEvent = '';
handles.activex7.Refresh;
global CurrentBlock;
CurrentBlock = eventdata.ActBlock;
global CurrentEvent;
CurrentEvent = handles.activex4.ActiveEvent;

% --------------------------------------------------------------------
function activex7_ActEventChanged(hObject, eventdata, handles)
% hObject    handle to activex4 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

% Process Event Selection and refresh
global CurrentEvent;
CurrentEvent = eventdata.NewActEvent;
handles.activex7.Refresh;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TDTPipeOffline_Analysis

function channo_Callback(hObject, eventdata, handles)
% hObject    handle to channo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channo as text
%        str2double(get(hObject,'String')) returns contents of channo as a double

global CN;
CN = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function channo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global CN;

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

CN = str2double(get(hObject,'String'));

