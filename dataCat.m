function dataCat(data_temp,sf)

% utility function to concatanate data_temp to the end of the global data

global data;

if isempty(data) || isempty(data_temp)
    disp('nothing to concatenate. data empty!')
    return
elseif nargin>1 && sf==1 % TDTPipeOnline_4/16 - Offline
    data.codes.data = vertcat(data.codes.data,data_temp.codes.data);
    data.spikes = vertcat(data.spikes,data_temp.spikes);
elseif nargin>1 && sf==2 % TDTPipeOnline_4/16
    data.codes.data = vertcat(data.codes.data,data_temp.codes.data);
    for i=1:size(data.spikes,2)
        data.spikes{i} = vertcat(data.spikes{i},data_temp.spikes{i});
    end
else
    % data
    data.codes.data = vertcat(data.codes.data,data_temp.codes.data);
    if isfield(data,'spikes')
        % spikes  -temp fix in case more units are added mid-way, exclude them
        data.spikes = vertcat(data.spikes,data_temp.spikes(:,1:size(data.spikes,2)));
    end
    if isfield(data,'LFP')
        % spikes  -temp fix in case more units are added mid-way, exclude them
        data.LFP = vertcat(data.LFP,data_temp.LFP);
    end
end