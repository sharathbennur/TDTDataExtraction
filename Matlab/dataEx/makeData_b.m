function [data_b] = makeData_b(file_in,exp)

% Function to convert selected parts of the cohen data struct into
% a new struct 'data_b' similar to data
% INPUT:    file_in - filename
%           exp  - expirement name
%           flag - if you want to save the file

data_b = [];

%% setup the data structs and figure out what to extract
% the data_id struct sets up how the data from the origal mat file is to be
% read and interpreted. Its setup as follows.
%   data.ecodes : contains all the ecodes to be extracted, there are 4
%   categories of these
%       value: extract a number - usually an integer
%       time : typically a timestamp (double)
%       comp : something that needs to be computed, after other ecodes have
%              been extracted, this has to be listed last in data_id after
%              the other two categories
%   spikes      : extracts spike train from each trial and saves as cell in
%                 data.spikes
%   lever       : extracts lever analog data from each trial & puts in into
%                 data.lever
%
% NOTES : lever release level is not always 15000, so the 15K*2/3
%       : there is a lag between when the sound is actually turned off and
%       when its recorded, so the 'sof-10'

disp('Converting LabView matlab file...')

if strcmp(exp,'TNT')
    data_id = struct(...
        'ecodes',{{ ...
        % ecode         type     source-str        index (-1:all)
        'error'         'value'  'Error'                1;...
        'error_time'    'time'   'Error'                2;...
        'start'         'time'   'StartOfBehavior'      1;...
        'end'           'time'   'EndOfBehavior'        1;...
        'sound_on'      'time'   'TimeStamp'            1;...
        'sound_off'     'time'   'TimeStamp'            2;...
        'lev_rel'       'comp'   'LeverTarget'          1;...
        'trial_type'    'id'     'TrialType'            1;...
        'curr_param'    'id'     'CurrentParam'         1;...
        }},...
        'lever', 'LeverStatus');
    data_b_folder = 'C:\Lab\Data\Mat\Beh\';
elseif strcmp(exp,'Bld') % default: Baldre
    data_id = struct(...
        'ecodes',{{ ...
        % ecode         type     source-str        index (-1:all)
        'error'         'value'  'Error'                1;...
        'start'         'time'   'StartOfBehavior'      1;...
        'end'           'time'   'EndOfBehavior'        1;...
        'sn1'           'time'  'StimulusOn'           2;...
        'sn2'           'time'  'StimulusOn'           3;...
        'sn3'           'time'  'StimulusOn'           4;...
        'tm1'           'time'   'TimeStamp'            2;...
        'tm2'           'time'   'TimeStamp'            3;...
        'tm3'           'time'   'TimeStamp'            4;...
        'tm4'           'time'   'TimeStamp'            5;...
        'trial_type'    'id'     'TrialType'            1;...
        'param'         'id'     'CurrentParam'         1;...
        }},...
        'lever', 'LeverStatus');
    data_b_folder = 'C:\Documents and Settings\Cohen\My Documents\MATLAB\D_beh\';
end

%% load file and get stuff

if ischar(file_in)
    temp_l = load(strcat(data_b_folder,file_in));
end

% setup all the basics
temp = temp_l.(file_in);
tn = size(temp,2);
dt = fieldnames(data_id);

% make subfields
for d = 1:size(dt,1)
    data_b.(dt{d}) = [];
end

% Collect spikes
if isfield(data_b,'spikes')
    for tt = 1:tn
        data_b.spikes{tt,1} = temp(1,tt).SpikeTrain(:);
    end
end

% Collect lever data
if isfield(data_b,'lever')
    for tt = 1:tn
        data_b.lever{tt,1} = temp(1,tt).LeverStatus(:);
    end
end

% ecodes
k=0; % index for params
if isfield(data_b,'ecodes')
    for j = 1:size(data_id.ecodes,1);
        % special treatment of id's
        if strcmp(data_id.ecodes(j,2),'id')
            k=k+1; % increment param index
            % add name
            data_b.ecodes.param_name(k) = data_id.ecodes(j,1);
            disp(strcat('getting ecode:',data_id.ecodes{j,1}))
            for tt=1:tn
                temp_t = cellstr(temp(tt).(data_id.ecodes{j,3}));
                data_b.ecodes.params{tt,k} = temp_t{1};
            end
            % compute stuff - typically each one is different
        elseif strcmp(data_id.ecodes(j,2),'comp')
            % first add column to ecode.name
            data_b.ecodes.name(j) = data_id.ecodes(j,1);
            disp(strcat('getting ecode:',data_id.ecodes{j,1}))
            % then compute
            if strcmp(data_id.ecodes(j,1),'lev_rel') % Compute release time
                for tt=1:tn
                    hol = temp(tt).(data_id.ecodes{j,3})(1)/2; % lever release level
                    % look for lever release only after sound on/off
                    sof = data_b.ecodes.data(tt,gD_C('sound_off')); % sound off
                    sof = sof-10; % to compensate for TimeStamp lag
                    rel = find(data_b.lever{tt,1}(abs(sof):length(data_b.lever{tt,1}))<=hol); % release
                    if sof > 0 && ~isempty(rel)
                        data_b.ecodes.data(tt,j) = rel(1);
                    else
                        data_b.ecodes.data(tt,j) = NaN;
                    end
                end
            end
        else % just extract these numbers
            % first add column to ecode.name
            data_b.ecodes.name(j) = data_id.ecodes(j,1);
            % get relative index
            d_in = data_id.ecodes{j,4};
            disp(strcat('getting ecode:',data_id.ecodes{j,1}))
            for tt = 1:tn
                % get data
                if size(temp(1,tt).(data_id.ecodes{j,3})(:),1) < d_in % error-check
                    data_b.ecodes.data(tt,j) = NaN;
                else
                    data_b.ecodes.data(tt,j) = temp(1,tt).(data_id.ecodes{j,3})(d_in);
                end
            end
        end
    end
end

% Special section to interpret data.ecodes.curr_params for Baldre
if strcmp(exp,'Bld')
    s3col = find(strcmp('sn3',data_b.ecodes.name));
    data_b.ecodes.param_name(k+1:k+3) = {'sn1','sn2','sn3'};
    for tt=1:tn
        tp = data_b.ecodes.params{tt,2};
        di = strfind(tp,'.');
        data_b.ecodes.params{tt,3}=tp(1:di(1)-1);
        data_b.ecodes.params{tt,4}=tp(di(1)+1:di(2)-1);
        if isnan(data_b.ecodes.data(tt,s3col))
            data_b.ecodes.params{tt,5} = NaN;
        elseif size(di,2)>2
            data_b.ecodes.params{tt,5}=tp(di(2)+1:di(3)-1);
        else
            data_b.ecodes.params{tt,5}=tp(di(2)+1:numel(tp));
        end
    end
end

% % save using GUI
% uisave('data_b',strcat(file_in,'_b'))

%% Utility functions

    function column_ = gD_C(name)
        
        % gets the column number from DATA that matches the name.
        % names: 'trial' 'correct' 'stim'  etc
        
        % University of Pennsylvania
        
        % Get first occurrance
        if isfield(data_b,'ecodes')
            column_ = find(strcmp(name,data_b.ecodes.name), 1);
        elseif isfield(data_b,'codes')
            column_ = find(strcmp(name,data_b.codes.name), 1);
        end
        
    end

end