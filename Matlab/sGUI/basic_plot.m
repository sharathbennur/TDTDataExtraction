function basic_plot(sess)

% basic plotting utility that plots psth and rasters for all available units 
% in available channels

global data;

% load files
data_folder = 'C:\Lab\Data\Mat\Final\';
file_in = strcat(data_folder,'C_',sess);
load(file_in);

% get column indices first
corr = gDCBN('error_LV');
TNRr = gDCBN('TNR_LV');
levr = gDCBN('lev_rel');
stmm = gDCBN('stim1');

% extract data
cor = data.codes.data(:,corr);
TNR = data.codes.data(:,TNRr);
lev = data.codes.data(:,levr);
stm = data.codes.data(:,stmm);

% extract spikes
for i=1:size(data.spikes,2)
    if ~isempty(data.spikes{i})
        spk = data.spikes{i}(:,1);
    end
end

% correct index 
cor_i = cor==0;
TNR_c = TNR(cor_i);
lev_c = lev(cor_i);
stm_c = stm(cor_i);
spk_c = spk(cor_i);

% Only Tone in Noise
TNR_i = ~isnan(TNR_c);
TNR_cT = TNR_c(TNR_i);
lev_cT = lev_c(TNR_i);
stm_cT = stm_c(TNR_i);
spk_cT = spk_c(TNR_i);

% Catch trials
TNR_cN = TNR_c(~TNR_i);
lev_cN = lev_c(~TNR_i);
stm_cN = stm_c(~TNR_i);
spk_cN = spk_c(~TNR_i);

%% plot catch trials - 

% align to stim_on
for j = 1:size(spk_cN,1)
    spk_cNs{j,1} = spk_cN{j}-stm_cN(j);
end

% plot

