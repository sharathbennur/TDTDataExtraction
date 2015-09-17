function combine_BN(bn)

% combines behavior & neural data files with the same basename
% IMPORTANT: Assumes that TDT neural data acquisition started first
% followed by a new file being saved in labview, extra trials in
% labview.mat do not matter as long as the first trial in both files is the
% same

global data;
n_folder = 'C:\Documents and Settings\Cohen\My Documents\MATLAB\D_nrl\';
b_folder = 'C:\Documents and Settings\Cohen\My Documents\MATLAB\D_beh\';

disp(strcat('loading:',n_folder,bn))
load(strcat(n_folder,bn)); % load neural data thats already in a 'data' struct
disp(strcat('loading:',b_folder,bn))
load(strcat(b_folder,bn)); % load the labview .mat file

%% error check

if numel(eval(bn))~=size(data.spikes,1)
    disp('Mismatch in number of trials between files')
    yn = input('Continue (y/n)? -','s');
    if ~strcmp(yn,'y')
        disp('Stopping');
        return;
    end
end

%% setup
% add stuff of interest from labview mat file to 'data' using 'b_ecodes'
codes = { ...
    % code         type `0    source-str        index (-1:all)
    'error'         'value'  'Error'                1;...
    'tm1'           'time'   'TimeStamp'            2;...
    'tm2'           'time'   'TimeStamp'            3;...
    'tm3'           'time'   'TimeStamp'            4;...
    'tm4'           'time'   'TimeStamp'            5;...
    'trial_type'    'id'     'TrialType'            1;...
    'param'         'id'     'CurrentParam'         1;...
    };

% setup all the basics
tn = size(data.codes.data,1);
temp = eval(bn);
% current ecode index
cec = size(data.codes.data,2);

%% Actually add stuff
k=0; % index for params
for j = 1:size(codes,1);
    % special treatment of id's
    if strcmp(codes(j,2),'id')
        k=k+1; % increment param index
        % add name
        data.codes.param_name(k) = codes(j,1);
        disp(['Adding ecode ',codes{j,1}])
        for tt=1:tn
            temp_t = cellstr(temp(tt).(codes{j,3}));
            data.codes.params{tt,k} = temp_t{1};
        end
    else % just extract these numbers
        % first add column to ecode.name
        data.codes.name(cec+j) = codes(j,1);
        % get relative index
        d_in = codes{j,4};
        disp(['Adding ecode ',codes{j,1}])
        for tt = 1:tn
            % get data
            if size(temp(1,tt).(codes{j,3})(:),1) < d_in % error-check
                data.codes.data(tt,j+cec) = NaN;
            elseif strcmp(codes{j,2},'time')
                data.codes.data(tt,j+cec) = temp(1,tt).(codes{j,3})(d_in)./1000;
            else
                data.codes.data(tt,j+cec) = temp(1,tt).(codes{j,3})(d_in);
            end
        end
    end
end

% Special section to interpret data.ecodes.curr_params for Baldre
s3col = find(strcmp('s3',data.codes.name));
data.codes.param_name(k+1:k+3) = {'sn1','sn2','sn3'};
for tt=1:tn
    tp = data.codes.params{tt,2};
    di = strfind(tp,'.');
    data.codes.params{tt,3}=tp(1:di(1)-1);
    data.codes.params{tt,4}=tp(di(1)+1:di(2)-1);
    if isnan(data.codes.data(tt,s3col))
        data.codes.params{tt,5} = NaN;
    elseif size(di,2)>2
        data.codes.params{tt,5}=tp(di(2)+1:di(3)-1);
    else
        data.codes.params{tt,5}=tp(di(2)+1:numel(tp));
    end
end

%% save data if needed

uisave('data',strcat('C_',bn))
