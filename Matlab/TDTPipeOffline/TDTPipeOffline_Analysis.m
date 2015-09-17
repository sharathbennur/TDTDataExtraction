function TDTPipeOffline_Analysis()

% This is the analysis function called by TDTPipeOffline
% Notes:
%       - Scripts will extract neural data from chosen event 
%         (TT.SetUseSortName(CurrentEvent));
%       - Only the first unit from chosen EvID (SortEventName) will be saved
%         into the 'data' struct (TT.SetFilterWithDescEx('sort=1'))
%       - If no event is chosen, it will not run

    global CurrentServer;
    global CurrentTank;
    global CurrentBlock;
    global CurrentEvent; % for offline analysis, pick
    global TT;
    global data;
    global CurrentPInt; % polling interval
    global data_temp;
    global CN; % channel number
    
    if isempty(CurrentBlock)
        disp('Cannot continue! Choose Block!')
        return;
    end
    
    if isempty(CurrentEvent)
        disp('Cannot continue! Choose Spike-Event')
        return;
    end
    
    % Connect to currently selected Server/Tank/Block
    TT.ConnectServer(CurrentServer, 'Me');
    TT.OpenTank(CurrentTank, 'R');
    % Automatically generate an epoch index for CurrentBlock
    rt = TT.SelectBlock(['~' CurrentBlock]);
    if rt
        disp('Block selection successful')
    end
    % Set channel number
    TT.SetGlobalV('Channel', CN); 
    % Analysis code here:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % how long is the block, then split it up
    start_t = TT.CurBlockStartTime; % TT.CurBlockStartTime;
    stop_t = TT.CurBlockStopTime;
    total_t = stop_t-start_t;
    CurrentPInt = 60; % default
    p_end = 0;
    
    % all you do here is call the parsing scripts and cat the data
    while p_end < total_t
        if p_end==0 % first time
            TDTData = getTDTData(0,CurrentPInt,CurrentEvent);
            % get NData from analysis
            [data,p_end] = anaTDTData(TDTData,p_end,1);
            u_update = strcat('Retrieved- ','',num2str(ceil(p_end)),'s of data');
            disp(u_update)
        elseif p_end+CurrentPInt > total_t % last time
            TDTData = getTDTData(p_end,p_end+CurrentPInt,CurrentEvent);
            % get NData from analysis
            [data_temp,p_end] = anaTDTData(TDTData,p_end,1);
            % cat new data with old
            dataCat(data_temp);
            u_update = strcat('Retrieved- ','',num2str(ceil(p_end)),'s of data');
            disp(u_update)
            break
        else
            TDTData = getTDTData(p_end,p_end+CurrentPInt,CurrentEvent);
            % get NData from analysis
            [data_temp,p_end] = anaTDTData(TDTData,p_end,1);
            dataCat(data_temp);
            u_update = strcat('Retrieved- ',num2str(ceil(p_end)),'s of data');
            disp(u_update)
        end
    end
    
    % try to save file
    data_n_folder = 'C:\Documents and Settings\Cohen\My Documents\MATLAB\D_nrl\';
    uisave('data',strcat(data_n_folder,CurrentBlock));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % close connection when done
    TT.CloseTank
    TT.ReleaseServer
end