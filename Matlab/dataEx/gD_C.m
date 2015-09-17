function column_ = gD_C(name,var)

% gets the column number from DATA that matches the name.
% names: 'trial' 'correct' 'stim'  etc

% University of Pennsylvania
global data_b;
global data;

% Get first occurrance
if strcmp(var,'data_b')
    if isfield(data_b,'ecodes')
        column_ = find(strcmp(name,data_b.ecodes.name), 1);
    elseif isfield(data_b,'codes')
        column_ = find(strcmp(name,data_b.codes.name), 1);
    end
elseif strcmp(var,'data')
    if isfield(data,'ecodes')
        column_ = find(strcmp(name,data.ecodes.name), 1);
    elseif isfield(data,'codes')
        column_ = find(strcmp(name,data.codes.name), 1);
    end
end