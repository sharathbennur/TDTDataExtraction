function TPOff_LFP

% This is the analysis function called by TDTPipeOnline**
% edited by sb (Oct 2013) for TDTPipeOnline_4 & _16

global CurrentServer;
global CurrentTank;
global CurrentBlock;
global CurrentEvent;
global TT;
global data;
global CurrentPEnd; % end-time of last tank read
global CurrentPInt; % polling interval

% Set Flags
sf=1; % spike-flag sf=1 for OfflineSorting
af=3; % auditory flag af=3 for Tone-Noise
CurrentPEnd = 0;

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

% how long is the block, then split it up
start_t = TT.CurBlockStartTime;
stop_t = TT.CurBlockStopTime;
total_t = stop_t-start_t;

% all you do here is call the parsing scripts and cat the data
while CurrentPEnd < total_t
    if CurrentPEnd==0 % first time
        TDTData = getTDTData(0,CurrentPInt);
        % get NData from analysis
        % [NData,lst] = anaTDTData(TDTData,last,audflag,flag)
        % using flag=3 for Tone-Noise
        % using audflag=7 for Tone-Noise
        [data,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af);
        if isempty(data) % no trials
            CurrentPEnd = CurrentPEnd+CurrentPInt;
        end
        u_update = strcat('Collected- ',num2str(ceil(CurrentPEnd)),'s of data');
        disp(u_update)
    elseif CurrentPEnd+CurrentPInt > total_t % last time
        if flag==1 % offline - use Sorted Tank
            TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt,CurrentEvent);
        else
            TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt);
        end
        % get NData from analysis
        [data_temp,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af);
        if isempty(data_temp) % no trials
            CurrentPEnd = total_t;
        else
            dataCat(data_temp); % cat new data with old
        end
        u_update = strcat('Total data collected- ',num2str(ceil(CurrentPEnd)),' s');
        disp(u_update)
    else
        TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt);
        % get NData from analysis
        [data_temp,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af);
        if isempty(data_temp) % no trials
            CurrentPEnd = CurrentPEnd+CurrentPInt;
        else
            dataCat(data_temp);
        end
        u_update = strcat('Collected- ',num2str(ceil(CurrentPEnd)),'s of data');
        disp(u_update)
    end
end

% Now that you have the latest data, close tank
TT.CloseTank
TT.ReleaseServer
disp('Closing Tank & cleaning up')

% try to save file
data_n_folder = 'C:\Lab\Data\Mat\Nrl\';
save(strcat(data_n_folder,'LFP_',CurrentBlock),'data');
disp('1. Saved LFP data file');

% Get behavioral data
[data_b] = makeData_TN(CurrentBlock);
if isempty(data_b)
    error('Need behavior file to continue!!')
end

% Combine neural and behavior files and save them
combine_TN_LFP(data_b);
