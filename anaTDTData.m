function [NData,lst] = anaTDTData(TDTData,last,af,sf)

% subfunction of TDTPipe to analyze raw TDT data into data format.
% Inputs    - TDTata - raw data
%           - last end of the last trial
%           - af - auditory flag
%           - sf - spike flag if==1 then use only first spike unit
% Returns   - NData.spikes (by trial)
%           - NData.codes
%           - lstp (time of last stop) + 10ms
% created by SB
% edited last: 16Aug2012

% init
global CurrentPInt
NData = [];

%% TRIAL START first find starts and stops
[Ts] = getTimeStamps(TDTData.TTL,TDTData.TTLfs,1);
Ts = Ts./TDTData.TTLfs; % sample # to time
nt = size(Ts,1); % no. of trials
% if you find no new trials, add to lst and return
if nt==0;
    lst = last+CurrentPInt;
    return
end
if Ts(nt,2)==0 % remove incomplete trial
    Ts(nt,:)=[];
    nt = size(Ts,1); % recaLc nt
end
% save last-stop + refractory
lst = last+Ts(nt,2)+0.1;
% save into NData
NData.codes.name = [{'tr_start'},{'tr_stop'}];
NData.codes.data = Ts;

%% LEV - now parse TDTData.lev by trial and save only first lever release
Lc = size(NData.codes.name,2);
NData.codes.name(:,Lc+1) = {'lev_rel'};
NData.codes.data(:,Lc+1) = nan;
Ll = getTimeStamps(TDTData.lev,TDTData.levfs,2);
if numel(Ll)>0
    Lrel = Ll(:,1); % releases
else
    Lrel = [];
end
for i=1:nt % no. trials
    % look between
    stst = ceil(Ts(i,:).*TDTData.TTLfs);
    Lri = find(Lrel > stst(1) & Lrel < stst(2));
    if ~isempty(Lri)
        NData.codes.data(i,Lc+1) = (Lrel(Lri(1))./TDTData.levfs)-Ts(i,1);
    else
        NData.codes.data(i,Lc+1) = -1; % never released
    end
end

%% AUD - now parse TDTData.Aud by trial and start of each sound upto 3 sounds per
% trial
Lc = size(NData.codes.name,2);
if af==1 % what where
    La = getTimeStamps(TDTData.Aud,TDTData.Audfs,3);
    NData.codes.name(1,Lc+1:Lc+2) = {'stim_on','stim_off'}; % init names
    NData.codes.data(1:nt,Lc+1:Lc+2) = nan; % init data
elseif af==2 % Joji/Andrew
    La = getTimeStamps(TDTData.Aud,TDTData.Audfs,6);
    NData.codes.name(1,Lc+1:Lc+2) = {'stim_on','stim_off'}; % init names
    NData.codes.data(1:nt,Lc+1:Lc+2) = nan; % init data
elseif af==3 % Tone/Noise
    La = getTimeStamps(TDTData.Aud,TDTData.Audfs,7);
    NData.codes.name(1,Lc+1) = {'stim1'}; % init names    
    NData.codes.name(1,Lc+2) = {'stim2'}; % init names
    NData.codes.data(1:nt,Lc+2) = nan; % init data
end
La = La./TDTData.Audfs;
if size(La,1)>0 % make sure there are valid trials
    if af==1 % what where
        La1 = La(:,1); % stop times
        La2 = La(:,2); % just start times
        for i=1:nt % no. trials
            % look between
            stst = ceil(Ts(i,:));
            astst = gt(La1,stst(1)) & lt(La1,stst(2));
            La1_nt = (La1(astst))-Ts(i,1); % in secs relative to tr_start
            La2_nt = (La2(astst))-Ts(i,1); % in secs relative to tr_start
            for j = 1:numel(La1_nt)
                NData.codes.data(i,Lc+j)=La1_nt(j);
                NData.codes.data(i,Lc+j+3)=La2_nt(j);
            end
        end
    elseif af==2 % Joji/Andrew
        La1 = La(:,1); % stop times
        La2 = La(:,2); % just start times
        for i=1:nt % no. trials
            % look between
            stst = ceil(Ts(i,:));
            astst = gt(La1,stst(1)) & lt(La1,stst(2));
            La1_nt = (La1(astst))-Ts(i,1); % in secs relative to tr_start
            La2_nt = (La2(astst))-Ts(i,1); % in secs relative to tr_start
            if ~isempty(La1_nt)
                NData.codes.data(i,Lc+1)=La1_nt(1);
                NData.codes.data(i,Lc+2)=La2_nt(end);
            end
        end
    elseif af==3 % Tone/Noise
        for i=1:nt % no. trials
            % look between
            stst = Ts(i,:);
            astst = gt(La,stst(1)) & lt(La,stst(2));
            Lat = La(find(astst,2)); % in secs relative to tr_start
            Lat = Lat - Ts(i,1);
            if ~isempty(Lat)
                NData.codes.data(i,Lc+1) = Lat(1);
            end
            if numel(Lat)>1
                NData.codes.data(i,Lc+2) = Lat(2);
            end
        end
    end
end

%% JOYSTICK - now parse TDTData.joy by trial and save reaction time and
% direction
if isfield(TDTData,'joy')
    Lc = size(NData.codes.name,2);
    NData.codes.name(:,Lc+1:Lc+2) = {'rt','joy_dir'};
    NData.codes.data(:,Lc+1:Lc+2) = nan;
    Jl = getTimeStamps(TDTData.joy,TDTData.joyfs,5);
    if numel(Jl)>0
        Jrel = Jl(:,1); % releases
    else
        Jrel = [];
    end
    for i=1:nt % no. trials
        % look between
        stst = ceil(Ts(i,:).*TDTData.TTLfs);
        Jri = find(Jrel > stst(1) & Jrel < stst(2));
        if numel(Jri)==1
            NData.codes.data(i,Lc+1) = (Jrel(Jri(1))./TDTData.joyfs)-Ts(i,1);
            NData.codes.data(i,Lc+2) = Jl(Jri,3);
        elseif numel(Jri)>1
            NData.codes.data(i,Lc+1) = (Jrel(Jri(1))./TDTData.joyfs)-Ts(i,1);
            NData.codes.data(i,Lc+2) = Jl(Jri(1),3);
        end
    end
end

%% REWARD & CORRECT
% now parse TDTData.rew by trial, figure out if  there were rewards, save
% correct and number of rewards
%   0: Correct
%   1: Incorrect
%  -1: Release Error
% Nan: Start Error
Lc = size(NData.codes.name,2);
NData.codes.name(1,Lc+1:Lc+2) = [{'r_num'},{'r_correct'}]; % init names
NData.codes.data(1:nt,Lc+1:Lc+2) = nan; % init data
Lr = getTimeStamps(TDTData.rew,TDTData.rewfs,4);
if size(Lr,1)>0 % make sure there are valid trials
    for i=1:nt % no. trials
        % look between
        stst = ceil(Ts(i,:).*TDTData.TTLfs);
        rstst = gt(Lr,stst(1)) & lt(Lr,stst(2));
        % only save rew #
        rn = sum(rstst);
        NData.codes.data(i,Lc+1)=rn;
        if rn>0
            NData.codes.data(i,Lc+2)=0; % correct
        elseif ~isnan(NData.codes.data(i,4)) && rn==0
            NData.codes.data(i,Lc+2)=1; % choice error
        else
            NData.codes.data(i,Lc+2)=-1; % error
        end
    end
end

%% SPIKES
% TDTData.spikes{sortID#,channel#}
% NData.spikes(channel#,trial#,sortID#)
% NData.spikes(trial#,sortID#)
if isfield(TDTData,'spikes') % if there are spikes
    % now sort spikes by trial
    Ls = TDTData.spikes; % copy original
    if nargin>3 && sf==1  % Use with TDTPipeOnline_* OfflineMode
        % Used only for Offline Sorting - assumes Single channel with
        % single sorted Neuron SortID#1, SortID#0 has unsorted waveforms 
        for j=1:size(Ls,2) % sortIDs
            for i=1:nt % trial#
                temp_Ls = Ls{j};
                if ~isempty(temp_Ls)
                    stst = Ts(i,:)+last; % look between times
                    sst = gt(temp_Ls,stst(1)) & lt(temp_Ls,stst(2)); % selection array
                    NData.spikes{i,j}=(temp_Ls(sst))-Ts(i,1)-last;
                else
                    NData.spikes{i,j}=[];
                end
            end
        end
    elseif nargin>3 && sf==2  % USE with TDTPipeOnline_4/16     
        for c=1:size(Ls,2) % Channel #
            if isempty(Ls{c})
                NData.spikes{c} = {};
            else
                for i=1:nt % trial#
                    stst = Ts(i,:)+last; % look between times
                    for j=1:size(Ls{c},2) % sortIDs
                        temp_Ls = Ls{c}(j);
                        temp_Ls = temp_Ls{1}(:); % extract struct from cell
                        sst = gt(temp_Ls,stst(1)) & lt(temp_Ls,stst(2));
                        % make spike timing relative to trial start
                        NData.spikes{c}{i,j}=(temp_Ls(sst))-Ts(i,1)-last;
                    end
                end
            end
        end
    elseif nargin>3 && size(TDTData.spikes,2)>1 % multiple channels with multiple neurons
        % Online sorting - Multi-Channel
        for c=1:size(TDTData.spikes,2) % Channel #
            for i=1:nt % trial#
                stst = Ts(i,:)+last; % look between times
                for j=1:size(Ls,2) % sortIDs
                    sst = gt(Ls{c,j},stst(1)) & lt(Ls{j},stst(2));
                    NData.spikes{c,i,j}=(Ls{c,j}(sst))-Ts(i,1)-last;
                end
            end
        end
    elseif nargin>3  % Online sorting - Single-Channel
        for i=1:nt % trials#
            % look between
            stst = Ts(i,:)+last;
            for j=1:size(Ls,2) % sortID
                sst = gt(Ls{j},stst(1)) & lt(Ls{j},stst(2));
                NData.spikes{i,j}=(Ls{j}(sst))-Ts(i,1)-last;
            end
        end
    end
else
    NData.spikes{nt,1}=[]; % put in blank cells to keep track of trials
end

%% LFPs: Save raw LFP values seperated by trial

% go through the trials
if nt>0 % make sure there are valid trials
    % convert time into sample number
    Ts_LFP_sn = ceil(Ts.*TDTData.LFPfs);
    for i=1:nt % no. trials
        NData.LFP{i} = TDTData.LFP(Ts_LFP_sn(i,1):Ts_LFP_sn(i,2));
    end
    NData.LFP_fs = TDTData.LFPfs;
end

NData.LFP = NData.LFP';

%% final bit - for global computations

NData.codes.data(:,1:2) = NData.codes.data(:,1:2)+last;

%% test plots
% 
% % X-axes
% xt = (1:1:numel(TDTData.TTL))./TDTData.TTLfs;
% xa = (1:1:numel(TDTData.Aud))./TDTData.Audfs;
% 
% % plot
% plot(xt,TDTData.TTL,'k')
% hold on
% plot(xt,TDTData.lev,'b')
% plot(xt,TDTData.rew,'g')
% % legend('TTl','lever','reward')
% figure
% plot(xa,TDTData.Aud,'r')
% 
% %
% plot(TDTData.TTL)
% hold on
% plot(TDTData.lev)