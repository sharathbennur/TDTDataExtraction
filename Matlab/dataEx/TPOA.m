function TPOA(flag)

% This is the analysis function called by TDTPipeOnline

global CurrentServer;
global CurrentTank;
global CurrentBlock;
global TT;
global data;
global CurrentPEnd; % end-time of last tank read
global CurrentPInt; % polling interval

% Set Falgs
sf=2; % spike-flag sf=2 for TDTPipeOnline_4/16
af=3; % auditory flag af=3 for Tone-Noise

if flag==1 % first time get all the data already in tank-block
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
            % TDTData = getTDTData(t0,t1,spik)
            TDTData = getTDTData(0,CurrentPInt);
            % get NData from analysis 
            % [NData,lst] = anaTDTData(TDTData,last,audflag,flag)
            % using flag=3 for Tone-Noise            
            % using audflag=7 for Tone-Noise
            [data,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af,sf);
            if isempty(data) % no trials
                CurrentPEnd = CurrentPEnd+CurrentPInt;
            end
            u_update = strcat('Collected- ',num2str(ceil(CurrentPEnd)),'s of data');
            disp(u_update)
        elseif CurrentPEnd+CurrentPInt > total_t % last time
            TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt);
            % get NData from analysis
            [data_temp,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af,sf);
            if isempty(data_temp) % no trials
                CurrentPEnd = total_t;
            else
                dataCat(data_temp,sf); % cat new data with old
            end
            u_update = strcat('Total data collected- ',num2str(ceil(CurrentPEnd)),' s');
            disp(u_update)
            return
        else
            TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt);
            % get NData from analysis
            [data_temp,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af,sf);
            if isempty(data_temp) % no trials
                CurrentPEnd = CurrentPEnd+CurrentPInt;
            else
                dataCat(data_temp,sf);
            end
            u_update = strcat('Collected- ',num2str(ceil(CurrentPEnd)),'s of data');
            disp(u_update)
        end
    end
    
    % Now that you have the latest data, close tank
    TT.CloseTank
    TT.ReleaseServer
    
elseif flag==2 % poll tank and get newest data from where we left off
    if isempty(data.codes)
        TPOA(1);
    end
    % Connect to currently selected Server/Tank/Block
    TT.ConnectServer(CurrentServer, 'Me');
    TT.OpenTank(CurrentTank, 'R');
    % Automatically generate an epoch index for CurrentBlock
    rt = TT.SelectBlock(['~' CurrentBlock]);
    if rt
        disp('')
        disp('Getting New Data...')
    end
    
    % how long is the block, then split it up
    start_t = TT.CurBlockStartTime;
    stop_t = TT.CurBlockStopTime;
    total_t = stop_t-start_t;
    
    % parse & cat the data
    if total_t > CurrentPEnd+CurrentPInt
        TDTData = getTDTData(CurrentPEnd,CurrentPEnd+CurrentPInt);
        % get NData from analysis
        [data_temp,CurrentPEnd] = anaTDTData(TDTData,CurrentPEnd,af,sf);
        dataCat(data_temp,sf);
%         u_update = strcat('Retrieved- ',num2str(ceil(CurrentPEnd)),' s of data');
%         disp(u_update)
    end 
    disp(strcat(num2str(size(data.codes.data,1)),' trials collected'))
    disp('')
    % Close tank and server
    TT.CloseTank
    TT.ReleaseServer
    return
    
elseif flag==0 % close and delete
    disp('Closing Tank & cleaning up')
    % Close tank and server if open
    TT.CloseTank
    TT.ReleaseServer
    CurrentPEnd = 0; % end-time of last tank read
    return
end