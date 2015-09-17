function spikeGUI
 
% Plots spike raster & PSTH vs time for chosen trials
% Choose trials using two sliders 
%   - one to choose how many trials
%   - another to choose the wrt trial, all other trials are picked wrt this
%   one
% List of variables that are used to sort spike/behavior data (for future
% versions
% 1. Correct/Incorrect
% 2. Trial-ID

% Declare all variables used
global f
global toplot
global data
 
% check to see if 'data' exists, if not abort
if ~exist('data')
   error('use loadGUI or load "data" first') 
end 
 
% Setup data.GUI which is used by various GUI elements
data.GUI.val(1) = 0; data.GUI.val(2) = 0;
data.GUI.filters = {};
data.GUI.markers = [];

% load whats needed
toplot.codes1 = data.codes.data;
toplot.spikes1 = data.spikes;
data.GUI.markers = gDCC;
 
% width and height of commonly used elements
tw=130; % totwl width
th=45; % total height
bh=1.5; % button height
lh=4;
bw=[7 14 21]; % button width
panelColor = get(0,'DefaultUicontrolBackgroundColor');
 
%% Set up the figure and panels
f = figure('Units','characters',...
        'Position',[10 5 tw th],...
        'Color',panelColor,...
        'HandleVisibility','callback',...
        'IntegerHandle','off',...
        'Renderer','painters',...
        'Toolbar','figure',...
        'NumberTitle','off',...
        'Name','SpikeGUI',...
        'Resize', 'off');
 
% Create top panel 1
axesPanel = uipanel('bordertype','etchedin',...
    'BackgroundColor',[1 1 1],...
    'Units','characters',...
    'Tag', 'axesPanel',...
    'Position', [30 4 tw-30 th],...
    'Parent',f);
 
% Create top panel 2
leftPanel = uipanel('bordertype','etchedin',...
    'BackgroundColor',panelColor,...
    'Units','characters',...
    'Tag', 'leftPanel',...
    'Position', [1/20 1/20 30 th],...
    'Parent',f);
 
%% Left panel stuff
    
    % First up the filters button for all the data filters to use
    fButton = uicontrol(f,'Style','pushbutton','Units','characters',...
    'Position',[2 th-3 bw(1,3) bh],...
    'String','dataFilters',...
    'Parent',leftPanel,...
    'Tag','filterButton',...
    'Callback',@fButton_Callback);
 
    % Marker 1 label setup
    text1 = uicontrol(f,'Style','text','Units','characters',...
    'Position',[2 th-11 bw(1,3) bh],...
    'String','Marker #1',...
    'Parent',leftPanel);
    
    pmenuL3 = uicontrol(f,'Style','popupmenu','Units','characters',...
        'Position',[2 th-12 bw(1,3) bh],...
        'String',data.GUI.markers,...
        'Parent',leftPanel,...
        'Tag','popupmenu3',...
        'Callback',@pmenuL3_Callback);
 
    % Marker 2 label setup
    text2 = uicontrol(f,'Style','text','Units','characters',...
    'Position',[2 th-14 bw(1,3) bh],...
    'String','Marker #2',...
    'Parent',leftPanel);
 
    pmenuL4 = uicontrol(f,'Style','popupmenu','Units','characters',...
    'Position',[2 th-15 bw(1,3) bh],...
    'String',data.GUI.markers,...
    'Parent',leftPanel,...
    'Tag','popupmenu4',...
    'Callback',@pmenuL4_Callback);
    
% Menu callbacks
 
    function pmenuL3_Callback(hObject, eventdata, handles)
        str = get(hObject, 'String');
        val = get(hObject,'Value');
        updateplot2(str(val,1),1);
    end
 
    function pmenuL4_Callback(hObject, eventdata, handles)
        str = get(hObject, 'String');
        val = get(hObject,'Value');
        updateplot2(str(val,1),2);
    end
 
% Button callbacks
 
    function fButton_Callback(hObject, eventdata, handles)
        filter_data
        updateplot
    end
 
%% AxesPanel Stuff
 
% Add an axes to the top panel
A = axes('parent',axesPanel,...
    'Position', [0.1 0.08 0.8 0.4]);
set(get(A,'XLabel'),'String','Time(secs)');
B = axes('parent',axesPanel,...
    'Position', [0.1 0.55 0.8 0.4]);
set(get(B,'XLabel'),'String','Time(secs)');
 
updatePlot;
 
 
%% Utility functions
 
    function updatePlot
        figure(f);
        hold(A);
        ylim(A,[0 size(toplot.spikes1,1)]);
        for k=1:size(toplot.spikes1,1)
            train=toplot.spikes1{k,1};
            plot(A,train,k,'k+',...
                'MarkerSize',2);
        end
        hold off
    end

% Utility function to parse data.codes.names and pass the names of the
% codes to use as markers
    function marks = gDCC
            marks = unique(data.codes.name)';
    end

%         %       Nice looking but slow raster plot
%         figure1=figure(1);              % raster plot
%         axes1 = axes('FontSize',16,'Parent',figure1);
%         hold on
%         for k=1:10
%             train=[];
%             train=ceil(toplot.spikes1{k});
%             for i=1:length(train)
%                 plot([train(i) train(i)], [k-.5 k+.5])
%             end
%         end
%         title('Raster plot of analyzed data')
%         xlim([0 L])
%         ylim([k1-.5 k2+.5])
%         xlabel('Time (msec)')
%         ylabel('Trial Number')
%         hold off
 
end