function combine_TN_LFP(data_b)

% combines behavior & neural data files with the same basename
% IMPORTANT: Assumes that TDT neural data acquisition started first
% followed by a new file being saved in labview, extra trials in
% labview.mat do not matter as long as the first trial in both files is the
% same

global data CurrentBlock;

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
    disp('3. LFP and behavior files match')
end

%% setup
% add stuff of interest from labview mat file to 'data' using 'b_ecodes'
% everything from labView has '_LV'
codes = { ...
    % code              type `0    source-str        index (-1:all)
    'error_LV'          'value'     'error'                1;...
    'TNR_LV'            'value'     'TNR'                  8;...
    'sound_on_LV'       'time'      'sound_on'             5;...
    'trial_type_LV'     'id'        'TrialType'            1;...
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

%% save data if needed
data_n_folder = 'C:\Lab\Data\Mat\Final\';
file_out = strcat(data_n_folder,'CL_',CurrentBlock);
uisave('data',file_out);
disp('4. Saved final data file');

end
