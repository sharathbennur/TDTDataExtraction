function reaction_time(ses,monk)

% plot reaction time

global data
make_data(ses,monk)

cor = data.ecodes.data(:,gDCBN('error'));
sof = data.ecodes.data(:,gDCBN('sound_off')); % stim on
rel = data.ecodes.data(:,gDCBN('rel_time')); % lever rel ??

ind = cor==0;
rt = sof(ind)-rel(ind);

rt = rt(rt>0);
rt_bins = 25:50:475;

rts = hist(rt,rt_bins);

bar(rt_bins,rts)