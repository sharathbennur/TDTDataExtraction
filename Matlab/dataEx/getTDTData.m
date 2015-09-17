function TDTData = getTDTData(t0,t1,spik)

% Function to get data from specified tank, parse it into the data struct
% and send it back.
% - Gets data from selected TANK
% - Gets data from selected block
% - Only gets data between t0 and t1
% - Returns - Spikes
%           - Lever Data
%           - TTL Data
%           - Auditory Data
%           - Reward TTL Data
% edited by SB 16Aug2012
% globals
global TT;
global CurrentEvent;
global CN; % Get data for all channels chosen
global sortNum;
% % DEBUG
% TT.ConnectServer('Local','Me')
% TT.OpenTank('Testing','R')
% TT.SelectBlock('Test-1')

% GET Spikes

%%

if nargin==3 % Offline Analysis - TPOff_All
    % extract data using filtering
    chNum = strcat('Channel=',num2str(CN));
    setC = TT.SetGlobals(chNum);
    sortName =  strcat('TankSort_',num2str(spik));
    setS = TT.SetUseSortName(sortName);
    for i = 0:1
        sortNum = strcat('SORT=',num2str(i));
        setF = TT.SetFilterWithDescEx(sortNum);
        if setC~=1 || setS~=1 || setF~=1
            error('Problems setting up sorts')
        end
        NS = TT.ReadEventsV(1e6,'eBxS',CN,0,t0,t1,'FILTERED');
        spikes = TT.ParseEvInfoV(0, NS, 6); % spike times
        if NS>1
            TDTData.spikes{i+1} = spikes; % channel#
        else
            TDTData.spikes{i+1} = {};
        end
    end
elseif strcmp(CurrentEvent,'eSpk') || strcmp(CurrentEvent,'eBxS')
    % for Online analysis multi-channel
    % get spikes from channel 1 from t0 to t1
    % all sortIDs - 0(unsorted) and 1..n
    if numel(CN)>1 % multi-channel
        for c=1:numel(CN) % channel #
            NS = TT.ReadEventsV(1e6,CurrentEvent, c, 0, t0, t1, 'ALL');
            disp(num2str(NS)) %%%%% DEBUG %%%%%
            sort_temp = TT.ParseEvInfoV(0, NS, 5); % sorting no.
            spikes_temp = TT.ParseEvInfoV(0, NS, 6); % spike times
            if max(sort_temp>0) % we have spikes
                for j=0:max(sort_temp) % Sort ID #
                    TDTData.spikes{c}{j+1} = spikes_temp(sort_temp==j); % channel#, unit#
                end
            else
                TDTData.spikes{c} = {};
            end
        end
    else % only single channel with spike data
        NS = TT.ReadEventsV(1e6,CurrentEvent, CN, 0, t0, t1, 'ALL');
        sort_temp = TT.ParseEvInfoV(0, NS, 5); % sorting no.
        spikes_temp = TT.ParseEvInfoV(0, NS, 6); % spike times
        if max(sort_temp>0) % we have spikes
            for j=0:max(sort_temp)
                TDTData.spikes{j+1} = spikes_temp(sort_temp==j);
            end
        end
    end
elseif strcmp(CurrentEvent(1:5),'eBxS_') % sorted neuron for OfflineAnalysis
    c = find(CN);
    % extract data using filtering
    chNum = strcat('Channel=',num2str(c));
    setC = TT.SetGlobals(chNum);
    sortName =  CurrentEvent(6:end);
    setS = TT.SetUseSortName(sortName);
    for i = 0:1
        sortNum = strcat('SORT=',num2str(i));
        setF = TT.SetFilterWithDescEx(sortNum);
        if setC~=1 || setS~=1 || setF~=1
            error('Problems setting up sorts')
        end
        NS = TT.ReadEventsV(1e6,'eBxS',c,0,t0,t1,'FILTERED');
        spikes = TT.ParseEvInfoV(0, NS, 6); % spike times
        if NS>1
            TDTData.spikes{i+1} = spikes; % channel#
        else
            TDTData.spikes{i+1} = {};
        end
    end
else
    % get spikes from channel 1 from t0 to t1
    NS = TT.ReadEventsV(1e6, 'Spik', 1, 0, t0, t1, 'ALL');
    sort_temp = TT.ParseEvInfoV(0, NS, 5); % sorting no.
    spikes_temp = TT.ParseEvInfoV(0, NS, 6); % spike times
    if max(sort_temp>0) % we have spikes
        for j=0:max(sort_temp)
            TDTData.spikes{j+1} = spikes_temp(sort_temp==j);
        end
    end
end

% Lever data
NL = TT.ReadEventsV(1e6, 'TTLv', 2, 0, t0, t1, 'ALL');
% lev_temp = TT.ParseEvInfoV(0, NL, 8); % data_type
lev_temp = int8(TT.ParseEvV(0,NL));
TDTData.lev = reshape(lev_temp,[],1);
levfs = TT.ParseEvInfoV(0, NL, 9);
TDTData.levfs = levfs(1);

% Get Joystick data if present
NJ = TT.ReadEventsV(1e6, 'TTLv', 4, 0, t0, t1, 'ALL');
% lev_temp = TT.ParseEvInfoV(0, NL, 8); % data_type
if NJ~=0
    joy_temp = int8(TT.ParseEvV(0,NJ));
    TDTData.joy = reshape(joy_temp,[],1);
    levfs = TT.ParseEvInfoV(0, NJ, 9);
    TDTData.joyfs = levfs(1);
end

% Rew data
NR = TT.ReadEventsV(1e6, 'TTLv', 3, 0, t0, t1, 'ALL');
% lev_temp = TT.ParseEvInfoV(0, NL, 8); % data_type
rew_temp = int8(TT.ParseEvV(0,NR));
TDTData.rew = reshape(rew_temp,[],1);
rewfs = TT.ParseEvInfoV(0, NL, 9);
TDTData.rewfs = rewfs(1);

% Start-Stop TTL
NT = TT.ReadEventsV(1e6, 'TTLv', 1, 0, t0, t1, 'ALL');
TTL_temp = int8(TT.ParseEvV(0,NT));
TDTData.TTL = reshape(TTL_temp,[],1);
TTLfs = TT.ParseEvInfoV(0, NT, 9);
TDTData.TTLfs = TTLfs(1);

% Aud data
NA = TT.ReadEventsV(1e6, 'Audt', 1, 0, t0, t1, 'ALL');
Aud_temp = double(TT.ParseEvV(0,NA));
TDTData.Aud = reshape(Aud_temp,[],1);
Audfs = TT.ParseEvInfoV(0, NA, 9);
TDTData.Audfs = Audfs(1);

% Task-trial information
NB1 = TT.ReadEventsV(1e6,'EPTg',1,0,0,0,'All');
NB2 = TT.ReadEventsV(1e6,'BLTg',1,0,0,0,'All');
Beh_temp = double(TT.ParseEvV(0,NB2));
TDTData.Beh = reshape(Beh_temp,[],1);

% LFPs
NLFP = TT.ReadEventsV(1e6, 'LFPs', 1, 0, t0, t1, 'ALL');
LFP_temp = double(TT.ParseEvV(0,NLFP));
TDTData.LFP = reshape(LFP_temp,[],1);
LFPfs = TT.ParseEvInfoV(0, NLFP, 9);
TDTData.LFPfs = LFPfs(1);

%% test plots

% x1 = 0:1/TDTData.Audfs:numel(TDTData.Aud)/TDTData.Audfs;
% x1 = x1(2:end)';
% figure;
% subplot(3,1,1)
% plot(x1,TDTData.Aud,'DisplayName','TDTData.Aud','YDataSource','TDTData.Aud');
% x2 = 0:1/TDTData.TTLfs:numel(TDTData.TTL)/TDTData.TTLfs;
% x2 = x2(2:end)';
% title('Auditory Signal')
% subplot(3,1,2)
% plot(x2,TDTData.TTL,'DisplayName','TDTData.TTL','YDataSource','TDTData.TTL');
% title('TTL Signal')
% subplot(3,1,3)
% plot(x2,TDTData.lev,'DisplayName','TDTData.lev','YDataSource','TDTData.lev');
% title('Lever Signal')
% 
