function tuningCurve3

% plots frequency vs amplitude vs neural activity (Freq-Response-Amplitude 
% plot) for all units on all channels and computes a BF (best frequency)

% STIMULI:
% 500Hz to 8KHz, 0.1 octave steps
% pure tones - 100ms long with 5ms cosine ramps, 200ms inter-stim intervals
% 50db to 80db in 5dB steps, in ascending intensity and frequency
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
nt = numel(db_list).*numel(F);

%% DEBUG - reshape

% % there
% Fr = repmat(F,1,7)';
% Fr = reshape(Fr,nt,1);
% % and back again
% Fr = reshape(Fr,numel(db_list),numel(F));

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

%% DEBUG - plot computed times for each Stim Onset and Offset

% xax = 1:1:numel(tunData.Aud);
% xax = xax/tunData.Audfs;
% % find first stim
% hilthr=0.05;
% stm_hilbert=smooth(abs(hilbert(tunData.Aud)),100);
% over = stm_hilbert > hilthr;
% tStart = (find(over,1))/tunData.Audfs; % 80dB, 8KHz
% 
% % plot
% figure;
% plot(xax,tunData.Aud)
% hold on
% plot([tStart tStart],[-0.3 0.3],'r-')
% plot([tStart+0.1 tStart+0.1],[-0.3 0.3],'k-')
% for i=1:nt
%     plot([tStart+0.3*i tStart+0.3*i],[-0.3 0.3],'k-')
% end
% hold off
% 
% figure
% plot(xax,stm_hilbert)
% 
% % if everything works correctly, the first tone freq should be 8KHz
% figure
% tStartx = find(xax==tStart);
% sample = tunData.Aud(tStartx:tStartx+floor(tunData.Audfs*0.1));
% spectrogram(sample,128,120,128,tunData.Audfs); 

%% Compute

% First find start of the first tone, everything else is relative to that
hilthr=0.05;

% Threshold is highly dependant on the baseline noise and baseline voltage
% offset, if it tuning curve looks funny, check and make sure that
% threshold is above baseline-voltage+noise
stm_hilbert=smooth(abs(hilbert(tunData.Aud)),100);
over = stm_hilbert > hilthr;
tStart = (find(over,1))/tunData.Audfs; % 80dB, 8KHz
tDurn = 0.3; % interval between tone onsets is 0.3s
act_CN = find(CN); % active channels to use
% (channel#, trial#, Freq, dB)
% save Spike Rate
SpR = zeros(numel(act_CN),numel(db_list),numel(F),nreps);
SpR_PS = cell(numel(act_CN),numel(db_list),numel(F),nreps); % for PSTH
bSpR = zeros(size(act_CN)); % background firing rate
tTest = zeros(numel(act_CN),numel(db_list),numel(F)); % for t-test
spkP = cell(1,numel(act_CN)); % for overall PSTH by channel

% Spikes: (channel#, unit#)
for h=1:numel(act_CN) % active channels
    cur_CN = act_CN(h); % convert index of active channels into channel#
    spk_index = tunData.spikes{cur_CN}{2};
    if ~isempty(tunData.spikes{cur_CN})
        for i=1:nreps % reps
            % setup
            t_Spikes = nans(nt,1);
            tc_Spikes = cell(nt,1);
            % tone timings for each set tones
            tStarts = tStart+tDurn:tDurn:tStart+tDurn+(nt*tDurn);
            for j=1:nt   
                % get # of spikes
                spI = tunData.spikes{cur_CN}{2} > tStarts(j) & tunData.spikes{cur_CN}{2} <= tStarts(j)+0.3;
                t_Spikes(j) = sum(spI)/tDurn; % # of spikes between tone on-off in sp/sec
                % save spikes with their t0 = tone onset
                tc_Spikes{j} = spk_index(spI)-tStarts(j);
            end
            
            % reshape
            t_Spikes = reshape(t_Spikes,numel(db_list),numel(F));
            tc_Spikes = reshape(tc_Spikes,numel(db_list),numel(F));
            % save by channel # nreps
            SpR(h,:,:,i) = t_Spikes;
            SpR_PS(h,:,:,i) = tc_Spikes;
            % calculate next tone-set onset
            nStart = floor((tStarts(end)+0.5)*tunData.Audfs); % where the last set of tones ended
            ntStart = find(over(nStart:end),1); % first tone onset for the next rep
            tStart = (ntStart+nStart)/tunData.Audfs;
        end
        % find mean background firing rate
        tStart = (find(over,1))/tunData.Audfs; % 80dB, 8KHz
        bSpR(h) = sum(tunData.spikes{cur_CN}{2}<=tStart)/ tStart;
        % t-test
        for m=1:numel(F) % freq
            for k=1:numel(db_list) % dB SPL
                SpR_tt = SpR(h,k,m,:);
                SpR_tt = squeeze(SpR_tt);
                if ~isnan(ttest(SpR_tt,bSpR(h)))
                    tTest(h,k,m) = ttest(SpR_tt,bSpR(h));
                    for i=1:nreps
                        % for PSTH use only frequency+intensities that are significant
                        spkP{h} = cat(2,spkP{h},SpR_PS{h,k,m,i});
                    end
                end
            end
        end
        % max spiking rate to normaize
        SpR_m(h) = max(max(max(SpR(h,:,:,:))));
    end
end

%% DEBUG - compute frequency from auditory waveform

% F_calc = zeros(nt),1);

% % Spikes: (channel#, unit#)
% for h=1:numel(act_CN) % active channels
%     cur_CN = act_CN(h); % convert index of active channels into channel#
%     spk_index = tunData.spikes{cur_CN}{2};
%     if ~isempty(tunData.spikes{cur_CN})
%         bSpk_temp = zeros(nreps,1);
%         for i=1:nreps % reps
%             % baseline firing
%             bSpk_temp(i) = (sum(tunData.spikes{cur_CN}{2}<=tStart & tunData.spikes{cur_CN}{2}>=tStart-0.5))/0.5; 
%             % tone timings for each set tones
%             tStarts = tStart+tDurn:tDurn:tStart+tDurn+(nt*tDurn);
%             for j=1:nt
%                 
%                 % DEBUG - Freq of tone
%                 % NOTE: doesnt work perfectly as many of the tones are
%                 % below the noise floor due to their low intensity, so
%                 % their calculated freq =~550Hz = freq of noise floor
%                 temp_aud = tunData.Aud(ceil((tStarts(j)+0.01)*tunData.Audfs):ceil((tStarts(j)+0.05)*tunData.Audfs));
%                 % plot(gcf,temp_aud);
%                 t_dft = fft(temp_aud);
%                 [Y,I] = max(abs(t_dft));
%                 freq = 0:tunData.Audfs/length(temp_aud):tunData.Audfs/2;
%                 F_calc(j) = freq(I);
%             end
%             F_calc = reshape(F_calc,numel(db_list),numel(F));
%         end
%     end
% end

%% Plot

% first average spike data
mean_Sp = mean(SpR,4);
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
    ttt = squeeze(tTest(i,:,:));
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
%     set(gca,'XTickLabel',{})
%     set(gca,'XTickLabel',{'500','1000','2000','4000','8000'})
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
        [spk2.tbin,spk2.SDF]=gauss_smooth2(temp_spk',abin,sum(sum(tTest(1,:,:)))*5,pmin,pmax);
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
