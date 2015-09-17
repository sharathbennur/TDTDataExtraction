function column_ = gDCBN(name)
% function column_ = getDATA_ColumnByName(name)
%
% gets the column number from DATA that matches the name.
% names: 'trial' 'correct' 'stim'  etc

% University of Pennsylvania

global data

% Get first occurrance
if isfield(data,'ecodes')
    column_ = find(strcmp(name, data.ecodes.name), 1);
elseif isfield(data,'codes')
    column_ = find(strcmp(name, data.codes.name), 1);
end