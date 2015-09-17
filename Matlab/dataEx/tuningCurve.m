function tuningCurve

% plots frequency vs amplitude vs neural activity (Freq-Response-Amplitude 
% plot) for all units on all channels and computes a BF (best frequency)

% STIMULI:
% 500Hz to 16KHz, 0.1 octave steps
% pure tones - 100ms long with 5ms cosine ramps, 200ms intervals
% 40db to 80db in 10dB steps
% 5 repeats
% Sadagopan and Wang, J Neuroscience, 2008

% BF : Frequency and lowest intensity at which the neural response deviates
% from the background significantly p<0.05

% SB 08/2012

%% Setup

global CurrentServer;
global CurrentTank;
global CurrentBlock;
global TT;
global CN;

% Freq and amplitude setups
startF = 500; % lowest freq in calibration
Fint = 0.1;
nO = 4; % Number of Octaves
startF = startF.*(1/power(2,Fint));
Fs = cumprod(ones(1+(1/Fint*nO),1).*power(2,Fint)); % 1/32nd octave series
F = Fs.*(ones(1+(1/Fint*nO),1)*startF);
F = flipud(F);
db_list = fliplr(50:5:80);

%% TDT Server 

% Connect to currently selected Server/Tank/Block
TT.ConnectServer(CurrentServer, 'Me');
TT.OpenTank(CurrentTank, 'R');
% Automatically generate an epoch index for CurrentBlock
rt = TT.SelectBlock(['~' CurrentBlock]);
if rt
    disp('Getting Tuning Data...')
end
start_t = TT.CurBlockStartTime;
stop_t = TT.CurBlockStopTime;

% Get Data first
tunData = getTDTData(start_t,stop_t);

% Close tank and release server
TT.CloseTank
TT.ReleaseServer

%% Compute

% First find start of the first tone, everything else is relative to that
% with the hilbert version for detection of stm onset & offset
hilthr=0.004;
stm_hilbert=smooth(abs(hilbert(tunData.Aud)),100);
over = stm_hilbert > hilthr;
tStart = (find(over,1))/tunData.Audfs; % first tone onset
tDurn = 0.3; % interval between tone onsets is 0.3s
act_CN = find(CN); % active channels to use
% (channel#, trial#, Freq, dB)
tSpikes = zeros(numel(act_CN),5,numel(F),numel(db_list));
tt = zeros(numel(act_CN),numel(F),numel(db_list));
spk = cell(1,numel(act_CN));

% Spikes: (channel#, unit#)
for h=1:numel(act_CN) % active channels
    cur_CN = act_CN(h); % convert index of active channels into channel#
    if ~isempty(tunData.spikes{cur_CN})
        bSpk(h) = (sum(tunData.spikes{cur_CN}{2} <= tStart))/tStart; % baseline firing
        for i=1:5 % reps
            % tone timings for each set tones
            tStarts = tStart:tDurn:tStart+(((numel(F).*numel(db_list))-1)*tDurn);
            ri=1;
            for j=1:numel(F) % freq
                for k=1:numel(db_list) % dB SPL
                    index = tunData.spikes{cur_CN}{2} > tStarts(ri) & tunData.spikes{cur_CN}{2} <= tStarts(ri)+0.3;
                    tSpikes(h,i,j,k) = sum(index)/0.3; % # of spikes between tone on-off in sp/sec
                    % save spikes with their t0 = tone onset
                    spk_index = tunData.spikes{cur_CN}{2};
                    spk_index = spk_index(index)-tStarts(ri);
                    spk{h} = cat(2,spk{h},spk_index);
                    ri = ri+1; % update running index
                end
            end
            nStart = floor((tStarts(end)+0.5)*tunData.Audfs); % where the last set of tones ended
            tStart = (find(over(nStart:end),1))/tunData.Audfs; % first tone onset
        end
        % t-test
        for j=1:numel(F) % freq
                for k=1:numel(db_list) % dB SPL
                    tt_spk = tSpikes(h,:,j,k);
                    tt_spk = squeeze(tt_spk);
                    tt(h,j,k) = ttest(tt_spk,bSpk(h));
                end
        end
        % max spiking rate to normaize
        mSpk(h) = max(max(max(tSpikes(h,:,:,:))));
    end
end

% first average spike data
mean_Sp = mean(tSpikes,2);
mean_Sp = squeeze(mean_Sp);

%% Plot
scrsz = get(0,'ScreenSize');
F_flip = fliplr(F);
F_ax = [500,1000,2000,4000,8000];
pmin = 0; % xmin for plot
pmax = 300; % xmax for plot
abin = 10; % bin size for smoothing in ms

for i=1:numel(act_CN)
    % #### get data #####
    if numel(act_CN)>1 % more than 1 active channel
        % first for spike rate
        tun = squeeze(mean_Sp(i,:,:));
        tun = tun';
        tun = fliplr(tun); % to match flipped F_flip
    else
        % first for spike rate
        tun = mean_Sp;
        tun = tun';
        tun = fliplr(tun); % to match flipped F_flip.
    end
    % then for t-test
    ttt = squeeze(tt(i,:,:));
    ttt = ttt';
    ttt = fliplr(ttt); % to match flipped F_flip
    % #### then plot ####
    figure('Name','tuningCurve','Position',[100 100 500 800])
    % plot tuning
    subplot(3,1,1)
    % Make sure that F & db_list are sorted from low to
    % high and 'tun' matches - otherwise image plotted maybe incorrect
    pcolor(F_flip,db_list,tun);
    hold on
    set(gca,'Xscale','log');
    set(gca,'XTick',F_ax)
    set(gca,'XTickLabel',{})
    set(gca,'XTickLabel',{'500','1000','2000','4000','8000'})    
    set(gca,'Ydir','normal');
    xlabel('Frequency (Hz)')
    ylabel('Intensity (dB SPL)')
    title(['Channel #',num2str(act_CN(i))]);
    title(['Channel #',num2str(act_CN(i))]); % repeated to make it work
    colorbar;
    hold off
    % plot t-test
    subplot(3,1,2)
    pcolor(F_flip,db_list,ttt);
    hold on
    set(gca,'Xscale','log');
    set(gca,'XTick',F_ax)
    set(gca,'XTickLabel',{})
    set(gca,'XTickLabel',{'500','1000','2000','4000','8000'})    
    set(gca,'Ydir','normal');
    xlabel('Frequency (Hz)')
    ylabel('Intensity (dB SPL)')
    colorbar;
    hold off
    % plot PSTH
    if ~isempty(spk{i})
        temp_spk = spk{i}.*1000;
        % Smooth spike spike density function with a guassian
        [spk2.tbin,spk2.SDF]=gauss_smooth2(temp_spk',abin,(numel(db_list)*5*numel(F)),pmin,pmax);
    end
    subplot(3,1,3)
    plot(spk2.tbin,spk2.SDF,'k','linewidth',2)
end

sn = CurrentBlock(1:8);
sn = strcat('C:\Lab\Data\Mat\Nrl\',sn);
% saveas(h,sn,'eps') 

%% Compute Best Frequency

% for h=1:numel(act_CN)
%     % each channel separately
%     hSpk = squeeze(tSpikes(h,:,:,:));
%     [hyp,p] = ttest(hSpk,bSpk(h));
%     hyp = squeeze(hyp); 
%     p = squeeze(p);
%     tun = squeeze(mean_Sp(h,:,:));
% 
% end
