function tuningCurve2

% plots frequency vs amplitude vs neural activity (Freq-Response-Amplitude 
% plot) for all units on all channels and computes a BF (best frequency)

% STIMULI:
% 500Hz to 8KHz, 0.1 octave steps
% pure tones - 100ms long with 5ms cosine ramps, 200ms inter-stim intervals
% 50db to 80db in 5dB steps, randomized
% 'nreps' repeats
% Sadagopan and Wang, J Neuroscience, 2008

% BF : Frequency and lowest intensity at which the neural response deviates
% from the background significantly p<0.05

% SB 06/2013
% randomized stim version

%% Setup

global CurrentServer;
global CurrentTank;
global CurrentBlock;
global TT;
global CN;

% Freq and amplitude setups
nreps = 2; % # of repetitions of tone sets
startF = 500; % lowest freq in calibration
Fint = 0.1;
nO = 4; % Number of Octaves
startF = startF.*(1/power(2,Fint));
Fs = cumprod(ones(1+(1/Fint*nO),1).*power(2,Fint)); % 1/32nd octave series
F = Fs.*(ones(1+(1/Fint*nO),1)*startF);
db_list = (50:5:80)';
% replicate and randomize indices of db_list and F
db_rep = repmat((1:numel(db_list))',41,1);
F_rep = repmat(1:numel(F),7,1);
F_rep = reshape(F_rep,numel(db_rep),1);
db_F = [db_rep,F_rep];
load('stim_seed');
rng(seed)
% now randperm an array the size of db_F
ord = randperm(size(db_F,1));

%% DEBUG

% Fr = repmat(F,1,7)';
% Fr = reshape(Fr,numel(ord),1);
% % randomize
% F_rand = Fr(ord);
% % reverse
% F_rand(ord) = F_rand;
% F_rand = reshape(F_rand,numel(db_list),numel(F));
% 
% % testing
% db_Fr = db_F(ord,:);
% db_Fr(ord,:) = db_Fr;
% db_Fr1 = reshape(db_Fr(:,1),numel(db_list),numel(F));
% db_Fr2 = reshape(db_Fr(:,2),numel(db_list),numel(F));

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

%% DEBUG

% figure;
% xax = 1:1:numel(tunData.Aud);
% xax = xax/tunData.Audfs;
% plot(xax,tunData.Aud)
% hold on
% % find first stim
% hilthr=0.02;
% stm_hilbert=smooth(abs(hilbert(tunData.Aud)),100);
% over = stm_hilbert > hilthr;
% tStart = (find(over,1))/tunData.Audfs; % 80dB, 8KHz
% plot([tStart tStart],[-0.3 0.3],'k-')
% plot([tStart+0.1 tStart+0.1],[-0.3 0.3],'k-')
% 
% figure
% tStartx = find(xax==tStart);
% sample = tunData.Aud(tStartx:tStartx+floor(tunData.Audfs*0.1));
% spectrogram(sample,128,120,128,tunData.Audfs); 

%% Compute

% First find start of the first tone, everything else is relative to that
% with the hilbert version for detection of stm onset & offset
hilthr=0.02;
% Threshold is highly dependant on the baseline noise and baseline voltage
% offset, if it tuning curve looks funny, check and make sure that
% threshold is above baseline-voltage+noise
% e.g. currently baseline-voltage offset is 0.01V and noise is 0.005V
stm_hilbert=smooth(abs(hilbert(tunData.Aud)),100);
over = stm_hilbert > hilthr;
tStart = (find(over,1))/tunData.Audfs; % 80dB, 8KHz
tDurn = 0.3; % interval between tone onsets is 0.3s
act_CN = find(CN); % active channels to use
% (channel#, trial#, Freq, dB)
% save spike rate
tSpikes = zeros(numel(act_CN),nreps,numel(db_list),numel(F)); 
temp_Spikes = zeros(size(ord));
% for the t-test
tt = zeros(numel(act_CN),numel(db_list),numel(F)); 
temp_PSpikes = cell(nreps,numel(db_list),numel(F));
spk_temp = cell(size(ord,2),1);
spkP = cell(1,numel(act_CN)); % for PSTH
bSpk = zeros(size(act_CN));
F_calc = zeros(size(ord,2),1);

% Spikes: (channel#, unit#)
for h=1:numel(act_CN) % active channels
    cur_CN = act_CN(h); % convert index of active channels into channel#
    spk_index = tunData.spikes{cur_CN}{2};
    if ~isempty(tunData.spikes{cur_CN})
        bSpk_temp = zeros(nreps,1);
        for i=1:nreps % reps
            % baseline firing
            bSpk_temp(i) = (sum(tunData.spikes{cur_CN}{2}<=tStart & tunData.spikes{cur_CN}{2}>=tStart-0.5))/0.5; 
            % tone timings for each set tones
            tStarts = tStart+tDurn:tDurn:tStart+tDurn+((numel(ord)-1)*tDurn);
            for j=1:numel(ord) % use our randomized list
                
                % DEBUG - Freq of tone
                % NOTE: doesnt work perfectly as many of the tones are
                % below the noise floor due to their low intensity, so
                % their calculated freq =~550Hz = freq of noise floor
                temp_aud = tunData.Aud(ceil((tStarts(j)+0.01)*tunData.Audfs):ceil((tStarts(j)+0.05)*tunData.Audfs));
                % plot(gcf,temp_aud);
                t_dft = fft(temp_aud);
                [Y,I] = max(abs(t_dft));
                freq = 0:tunData.Audfs/length(temp_aud):tunData.Audfs/2;
                F_calc(j) = freq(I);
                
                % get # of spikes
                index = tunData.spikes{cur_CN}{2} > tStarts(j) & tunData.spikes{cur_CN}{2} <= tStarts(j)+0.3;
                temp_Spikes(j) = sum(index)/tDurn; % # of spikes between tone on-off in sp/sec
                % save spikes with their t0 = tone onset
                spk_temp{j} = spk_index(index)-tStarts(j);
            end
            % reverse randomizations
            temp_Spikes(ord) = temp_Spikes;
            spk_temp(ord) = spk_temp;
            F_calc(ord) = F_calc;
            % reshape
            temp_Spikes = reshape(temp_Spikes,numel(db_list),numel(F));
            spk_temp = reshape(spk_temp,numel(db_list),numel(F));
            F_calc = reshape(F_calc,numel(db_list),numel(F));
            % save by channel # nreps
            tSpikes(h,i,:,:) = temp_Spikes;
            temp_PSpikes(i,:,:) = spk_temp;
            % calculate next tone-set onset
            nStart = floor((tStarts(end)+0.5)*tunData.Audfs); % where the last set of tones ended
            ntStart = find(over(nStart:end),1); % first tone onset for the next rep
            tStart = (ntStart+nStart)/tunData.Audfs;
        end
        % find mean background firing rate
        if mean(bSpk)==0 % try a different way for getting a mean
            tStart = (find(over,1))/tunData.Audfs; % 80dB, 8KHz
            bSpk = sum(tunData.spikes{cur_CN}{2}<=tStart)/ tStart; 
        else
            bSpk(h) = mean(bSpk_temp);
        end
        % t-test
        for m=1:numel(F) % freq
            for k=1:numel(db_list) % dB SPL
                tt_spk = tSpikes(h,:,k,m);
                tt_spk = squeeze(tt_spk);
                if ~isnan(ttest(tt_spk,bSpk(h)))
                    tt(h,k,m) = ttest(tt_spk,bSpk(h));
                    for i=1:nreps
                        % for PSTH use only frequency+intensities that are significant
                        spkP{h} = cat(2,spkP{h},temp_PSpikes{i,k,m});
                    end
                end
            end
        end
        % max spiking rate to normaize
        mSpk(h) = max(max(max(tSpikes(h,:,:,:))));
    end
end

% % DEBUG 
% for j=1:numel(ord)
%     ord(j)
%     F_calc(ord(j),4) = F_calc(j,1);
%     F_unrand(ord(j)) = F_rand(j);
% end

%% Plot

% first average spike data
mean_Sp = mean(tSpikes,2);
mean_Sp = squeeze(mean_Sp);
    
% plot params
F_ax = [500,1000,2000,4000,8000];
pmin = 0; % xmin for plot
pmax = 300; % xmax for plot
abin = 10; % bin size for smoothing in ms

for i=1:numel(act_CN)
    % #### get data #####
    if numel(act_CN)>1 % more than 1 active channel
        % first for spike rate
        tun = squeeze(mean_Sp(i,:,:));
    else
        % first for spike rate
        tun = mean_Sp;
    end
    % then for t-test
    ttt = squeeze(tt(i,:,:));
    % #### then plot ####
    figure('Name','tuningCurve','Position',[100 100 500 800])
    % PLOT tuning
    subplot(3,1,1)
    % Make sure that F & db_list are sorted from low to
    % high and 'tun' matches - otherwise image plotted maybe incorrect
    % tun is in the form of low to high frequencies (columns - left to right) 
    % and low intensities to high (rows - top to bottom)
    imagesc(F,db_list,tun);
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
    % PLOT t-test
    subplot(3,1,2)
    imagesc(F,db_list,ttt);
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
    % PLOT PSTH
    if ~isempty(spkP{i})
        temp_spk = spkP{i}.*1000;
        % Smooth spike spike density function with a guassian
        [spk2.tbin,spk2.SDF]=gauss_smooth2(temp_spk',abin,sum(sum(tt(1,:,:)))*5,pmin,pmax);
    end
    subplot(3,1,3)
    plot(spk2.tbin,spk2.SDF,'k','linewidth',2)
    hold on
    xlabel('Time(ms)')
    ylabel('Spike rate(spikes/s)')
    plot([100 100],[-0.3 0.3],'k-')
    hold off
end

% sn = CurrentBlock(1:8);
% sn = strcat('C:\Lab\Data\Mat\Nrl\',sn);
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
