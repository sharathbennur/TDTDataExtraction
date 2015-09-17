%% TPOff_All
% Script to extract data files from non-errorFlag sessions and convert them
% into mat files that contain both neural and behavioral data
%%
function TPOff_All

% This is the analysis function called by TDTPipeOnline**
% edited by sb (Mar 2014) for TDTPipeOnline_4 & _16

global TT;
global data data_b;
CurrentServer = 'Local';
global CurrentBlock;
global CurrentPEnd; % end-time of last tank read
global CurrentPInt; % polling interval
global CN;

% Set Flags
sf=1; % spike-flag sf=1 for OfflineSorting
af=3; % auditory flag af=3 for Tone-Noise

% get fileList
fileList = ALB_TIN;
% fileList = ALB_TIN;

% call TDTPipeOnline_4 to set up the rest of the components correctly
TDTPipeOnline_16;
% Connect to currently selected Server
TT.ConnectServer(CurrentServer, 'Me');

% for all the sessions in fileList
for i = 1:size(fileList,1)
    % Setup
    CurrentPEnd = 0;
    CurrentBlock = fileList{i,1};
    CurrentTank = fileList{i,2};
    sortNum = fileList{i,3};
    skip = fileList{i,4};
    CN = fileList{i,5};
    if skip~=1
        % Open Stuff
        TT.OpenTank(CurrentTank, 'R');
        % Automatically generate an epoch index for CurrentBlock
        rt = TT.SelectBlock(['~' CurrentBlock]);
        if rt
            disp(strcat('Getting Initial Data from: ',CurrentBlock))
        end
        
        % how long is the block, then split it up
        start_t = TT.CurBlockStartTime;
        stop_t = TT.CurBlockStopTime;
        total_t = stop_t-start_t;
        
        % all you do here is call the parsing scripts and cat the data
        while CurrentPEnd < total_t
            if CurrentPEnd==0 % first time
                TDTData = getTDTData(0,CurrentPInt,sortNum);
                % get NData from analysis
                % [NData,lst] = anaTDTData(TDTData,last,audflag,flag)
                % using flag=3 for Tone-Noise
                % using audflag=7 for Tone-Noise
                [data,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af,sf);
                if isempty(data) && CurrentPEnd==0 % no trials
                    CurrentPEnd = CurrentPEnd+CurrentPInt;
                end
                u_update = strcat('Collected- ',num2str(ceil(CurrentPEnd)),'s of data');
                disp(u_update)
            elseif CurrentPEnd+CurrentPInt > total_t % last time
                TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt,sortNum);
                % get NData from analysis
                [data_temp,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af,sf);
                if isempty(data_temp) % no trials
                    CurrentPEnd = total_t;
                else
                    dataCat(data_temp,sf); % cat new data with old
                end
                u_update = strcat('Total data collected- ',num2str(ceil(CurrentPEnd)),' s');
                disp(u_update)
            else
                TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt,sortNum);
                % get NData from analysis
                [data_temp,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af,sf);
                if isempty(data_temp) % no trials
                    CurrentPEnd = CurrentPEnd+CurrentPInt;3
                elseif isempty(data)
                    data = data_temp;
                else
                    dataCat(data_temp,sf);
                end
                u_update = strcat('Collected- ',num2str(ceil(CurrentPEnd)),'s of data');
                disp(u_update)
            end
        end
        
        % Now that you have the latest data, close tank
        TT.CloseTank
        disp('Closing Tank & cleaning up')
        
        % Get behavioral data
        [data_b] = makeData_TN(CurrentBlock);
        if isempty(data_b)
            error('Need behavior file to continue!!')
        end
        
        % Combine neural and behavior files and save them
        combine_TN(data_b,sortNum,fileList{i,6});
    end
end
TT.ReleaseServer

display('All Files Done');