% Spike Extraction test function

TT = actxcontrol('TTank.X');
CurrentServer = 'Local';
CurrentTank = 'C:\Lab\Data\Tanks\TestTetrode';
CurrentBlock = 'Sl121213a';
CurrentEvent = 'eBxS';
c = 2; % Use Channel

if isempty(CurrentBlock)
    error('Please choose Tank and Block to get data from')
end

% Connect to currently selected Server/Tank/Block
TT.ConnectServer(CurrentServer, 'Me');
TT.OpenTank(CurrentTank, 'R');
% Automatically generate an epoch index for CurrentBlock
rt = TT.SelectBlock(['~' CurrentBlock]);
if rt
    disp('Getting Initial Data...')
end

start_t = TT.CurBlockStartTime;
stop_t = TT.CurBlockStopTime;
total_t = stop_t-start_t;
t0 = 0;
t1 = total_t;

% extract data using filtering
ch_str = strcat('Channel=',num2str(c));
setC = TT.SetGlobals(ch_str);
setS = TT.SetUseSortName('TankSort_1');
setF = TT.SetFilterWithDescEx('SORT=0');
if setC~=1 || setS~=1 || setF~=1
    error('Problems setting up sorts')
end
NS = TT.ReadEventsV(1e6,CurrentEvent,c,0,t0,t1,'FILTERED');
% NS = TT.ReadEventsV(1e6,CurrentEvent,2,0,t0,t1,'FILTERED');
sort = TT.ParseEvInfoV(0, NS, 5); % sorting no.
spikes = TT.ParseEvInfoV(0, NS, 6); % spike times
if size(spikes,2)>1
    TDTData.spikes{c} = spikes; % channel#
end
