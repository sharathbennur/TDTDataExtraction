function combine_CH(data_b,sortNum,varargin)

% combines behavior & neural data files with the same basename
% IMPORTANT: Assumes that TDT neural data acquisition started first
% followed by a new file being saved in labview, extra trials in
% labview.mat do not matter as long as the first trial in both files is the
% same

% File Mismatch compensating mechanism - uses the inputs in varargin to figure out if
% trials from the start (s), middle (m) or end (e) should be removed from
% the neural (n) or behavioral (b) file, and the last argument specifies
% how many files are to be removed.
global data CurrentBlock CN CurrentEvent;
if ~isempty(varargin{1})
    rt = varargin{1}(3);
    rt = rt{1};
    if strcmp(varargin{1}(1),'b') && strcmp(varargin{1}(2),'s')
        data_b.ecodes.data(1:rt,:) = [];
        data_b.lever(1:rt,:) = [];
        data_b.params(1:rt,:) = [];
    elseif strcmp(varargin{1}(1),'b') && strcmp(varargin{1}(2),'e')
        data_b.ecodes.data(end-rt+1:end,:) = [];
        data_b.lever(end-rt+1:end,:) = [];
        data_b.params(end-rt+1:end,:) = [];
    elseif strcmp(varargin{1}(1),'b') && strcmp(varargin{1}(2),'m')
        lt = varargin{1}(4);
        lt = lt{1};
        data_b.ecodes.data(rt:lt,:) = [];
        data_b.lever(rt:lt,:) = [];
        data_b.params(rt:lt,:) = [];
    elseif strcmp(varargin{1}(1),'n') && strcmp(varargin{1}(2),'s')
        data.codes.data(1:rt,:) = [];
        data.spikes(1:rt,:) = [];
    elseif strcmp(varargin{1}(1),'n') && strcmp(varargin{1}(2),'e')
        data.codes.data(end-rt+1:end,:) = [];
        data.spikes(end-rt+1:end,:) = [];
    elseif strcmp(varargin{1}(1),'n') && strcmp(varargin{1}(2),'m') && size(varargin{1},2)~=4
        data.codes.data(rt,:) = [];
        data.spikes(rt,:) = [];   
    end
end

%% error check
if size(data_b.ecodes.data,1)~=size(data.codes.data,1)
    disp('Mismatch in number of trials between files')
    % if the trials at the end of the file are to be excluded from the
    % combined file - choose y
    yn = input('Continue (y/n)? -','s');
    if ~strcmp(yn,'y')
        disp('Stopping');
        disp(strcat('Behavioral Trials:',num2str(size(data_b.ecodes.data,1))))
        disp(strcat('Neural Trials:',num2str(size(data.codes.data,1))))
        return;
    end
else
    disp('1. Neural and behavior files match')
end

%% setup
% add stuff of interest from labview mat file to 'data' using 'b_ecodes'
% everything from labView has '_LV'
codes = { ...
    % code              type `0    source-str        index (-1:all)
    'error_LV'          'value'     'error'                1;...
    't1_LV'             'time'      't1'                   5;...
    't2_LV'             'time'      't2'                   6;...
    'VCR_LV'            'value'     'VCR'                  8;...
    'Chorus#_LV'        'value'     'Chorus#'              9;...
    'VocTime_LV'        'time'      'VocTime'              10;...
    'param_LV'          'id'        'CurrentParam'         1;...
    };

% setup all the basics
tn = size(data.codes.data,1);
% current ecode index
cec = size(data.codes.data,2);

%% Actually add stuff
k=0; % index for params
for j = 1:size(codes,1);
    % special treatment of id's
    if strcmp(codes(j,2),'id')
        k=k+1; % increment param index
        % add name
        data.param_name(k) = codes(j,1);
        disp(['Adding ecode ',codes{j,1}])
        data.params(:,k) = data_b.params(1:tn,codes{j,4});
    else % just extract these numbers
        % first add column to ecode.name
        data.codes.name(cec+j) = codes(j,1);
        disp(['Adding ecode ',codes{j,1}])
        if strcmp(codes{j,2},'value')
            data.codes.data(:,cec+j) = data_b.ecodes.data(1:tn,codes{j,4});
        elseif strcmp(codes{j,2},'time')
            data.codes.data(:,cec+j) = data_b.ecodes.data(1:tn,codes{j,4})./1000;
        end
    end
end

%% Special section for Chorus task, add a new column with Voc_on (Vocalization Onset) times

c = size(data.codes.name,2);
data.codes.name(c+1) = {'Voc_on'};
data.codes.data(:,c+1) = data.codes.data(:,gD_C('chorus_on','data'))+...
    data.codes.data(:,gD_C('VocTime_LV','data'));

%% save data files - behavioral, neural and combined

% save to correct folders
data_n_folder = 'C:\Lab\Data\Mat\Nrl\CH\';
data_b_folder = 'C:\Lab\Data\Mat\Beh\CH\';
data_f_folder = 'C:\Lab\Data\Mat\Final\CH\';

if size(CN,1)>1
    save(strcat(data_n_folder,'N_',CurrentBlock,'_',...
        num2str(find(CN)),'.',num2str(sortNum),'.mat'),'data');
    disp('2. Saved neural data file');
    save(strcat(data_b_folder,'B_',CurrentBlock),'data_b')
    disp('3. Converted and saved behavior data file');
    
    % Filename
    file_out = strcat(data_f_folder,'C_',CurrentBlock,'_',...
    num2str(find(CN)),'.',num2str(sortNum),'.mat');
    
    save(file_out,'data');
    disp(strcat('4. Saved final data file: ',file_out));
else
    save(strcat(data_n_folder,'N_',CurrentBlock,'_',...
        num2str(CN),'.',CurrentEvent(end),'.mat'),'data');
    disp('2. Saved neural data file');
    save(strcat(data_b_folder,'B_',CurrentBlock),'data_b')
    disp('3. Converted and saved behavior data file');
    
    % Filename
    file_out = strcat(data_f_folder,'C_',CurrentBlock,'_',...
    num2str(CN),'.',CurrentEvent(end),'.mat');
    
    uisave('data',file_out);
    disp('4. Saved final data file');
end
