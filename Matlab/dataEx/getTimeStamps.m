function [oo] = getTimeStamps(stm,stmfs,flag)

% looks for on/offsets on streamed data, sends back sample numbers when
% onsets and offsets occur
% flag decides which one to wait for first
%     - flag==1 wait for on first, then look for off eg. TTL
%     - flag==2 wait for off first, then look for on eg. lever
%       flag==3 auditory time stamps
%       flag==4 reward timestamps
%       flag==5 joystick timestamps
% init
oo=[];

% compute
% TRIAL START STOP
if flag==1 % START FLAG
    thr = 5;
    st = diff(stm);
    i_stt = gt(st,thr); % greater than threshold
    i_stp = lt(st,-thr); % below threshold
    
    i=0;
    j=1;
    while i<numel(st)
        % find start
        if i==0 % first time
            start = find(i_stt(1:numel(st)),1,'first');
        else
            start = find(i_stt(i:numel(st)),1,'first');
        end
        if isempty(start)
            break
        end
        i = i+start; % keep track of total samples
        oo(j,1) = i;
        % find stop
        stop = find(i_stp(i+100:numel(st)),1,'first');
        if isempty(stop)
            break
        end
        i = i+stop; % keep track of total samples
        oo(j,2) = i;
        j=j+1;
    end
    % LEVER
elseif flag==2
    thr = 10;
    st = diff(stm);
    i_stt = lt(st,-thr); % greater than threshold
    i_stp = gt(st,thr); % below threshold
    
    i=0;
    j=1;
    while i<numel(st)
        % find release
        if i==0 % first time
            start = find(i_stt(1:numel(st)),1,'first');
        else
            start = find(i_stt(i:numel(st)),1,'first');
        end
        if isempty(start)
            break
        end
        i = i+start; % keep track of total samples
        oo(j,1) = i;
        % find hold
        stop = find(i_stp(i:numel(st)),1,'first');
        if isempty(stop)
            break
        end
        i = i+stop; % keep track of total samples
        oo(j,2) = i;
        j=j+1;
    end
    % AUD
elseif flag==3 % specially for auditory stim
    fthr = 0.005;
    bthr = 0.001;
    stm_fstd = movingstd(stm,25,'forward'); % use for stop
    stm_bstd = movingstd(stm,25,'backward'); % use for start
    
    i_stt = gt(stm_bstd,fthr); % greater than threshold
    i_stp = lt(stm_fstd,bthr); % silence has low variance
    
    i=0;
    j=1;
    while i<numel(stm)
        if i==0 % first time
            start = find(i_stt(1:numel(stm)),1,'first');
        else
            start = find(i_stt(i:numel(stm)),1,'first');
        end
        if isempty(start)
            break
        end
        % keep track of total samples
        i = i+start;
        oo(j,1) = i;
        i = i+ceil(0.025.*stmfs);
        stop = find(i_stp(i:numel(stm)),1,'first');
        if isempty(stop)
            break
        end
        % keep track of total samples
        i = i+stop;
        oo(j,2) = i;
        i = i+ceil(0.025.*stmfs); % refractory perdiod
        j=j+1;
    end
    % REWARD
elseif flag==4
    thr = 10;
    st = diff(stm);
    i_stt = lt(st,-thr); % greater than threshold
    i_stp = gt(st,thr); % below threshold
    
    i=0;
    j=1;
    while i<numel(st)
        % find rew_on
        if i==0 % first time
            start = find(i_stt(1:numel(st)),1,'first');
        else
            start = find(i_stt(i:numel(st)),1,'first');
        end
        if isempty(start)
            break
        end
        i = i+start; % keep track of total samples
        oo(j) = i;
        % find stop
        stop = find(i_stp(i:numel(st)),1,'first');
        if isempty(stop)
            break
        end
        i = i+stop; % keep track of total samples
        j=j+1;
    end
elseif flag==5 % joystick stuff
    thr = 5;
    st = diff(stm);
    i_stt = gt(st,thr); % greater than threshold
    i_stp = lt(st,-thr); % below threshold
    
    i=0;
    j=1;
    while i<numel(st)
        % find start
        if i==0 % first time
            start = find(i_stt(1:numel(st)),1,'first');
        else
            start = find(i_stt(i:numel(st)),1,'first');
        end
        if isempty(start)
            break
        end
        i = i+start; % keep track of total samples
        oo(j,1) = i; % index of >threshold
        % Find dir
        if stm(i+10)>=33
            oo(j,3) = -1;
        else
            oo(j,3) = 1;
        end
        % find stop
        stop = find(i_stp(i:numel(st)),1,'first');
        if isempty(stop)
            break
        end
        i = i+stop; % keep track of total samples
        oo(j,2) = i; % index of <threshold
        j=j+1;
    end
elseif flag==6 % for Joji/Andrew's auditory stim
    fthr = 0.005;
    bthr = 0.005;
    stm_fstd = movingstd(stm,25,'forward'); % use for stop
    stm_bstd = movingstd(stm,25,'backward'); % use for start
    
    i_stt = gt(stm_bstd,fthr); % greater than threshold
    i_stp = lt(stm_fstd,bthr); % silence has low variance
    
    i=0;
    j=1;
    while i<numel(stm)
        if i==0 % first time
            start = find(i_stt(1:numel(stm)),1,'first');
        else
            start = find(i_stt(i:numel(stm)),1,'first');
        end
        if isempty(start)
            break
        end
        % keep track of total samples
        i = i+start;
        oo(j,1) = i;
        i = i+ceil(0.002.*stmfs); % 5ms refractory period
        stop = find(i_stp(i:numel(stm)),1,'first');
        if isempty(stop)
            break
        end
        % keep track of total samples
        i = i+stop;
        oo(j,2) = i;
        i = i+ceil(0.002.*stmfs); % refractory perdiod
        j=j+1;
    end
    
elseif flag==7 % for ToneNoise tasks
    % First find start of the first tone/noise, everything else is relative to that
    % with the hilbert version for detection of stm onset & offset
    hilthr=0.004;
    stm_hilbert=smooth(abs(hilbert(stm)),100);
    over = stm_hilbert > hilthr;
    under = stm_hilbert < hilthr;
    i=0;
    j=1;
    while i<numel(stm)
        if i==0 % first time
            start = find(over,1);
        else
            start = find(over(i:numel(over)),1);
        end
        if isempty(start)
            break
        end
        % keep track of total samples
        i = i+start;
        oo(j,1) = i;
        i = i+ceil((0.8).*stmfs); % 800ms refractory period
        j=j+1;
    end
end % END FLAG



%% plot for test section for vectorized versions
% oos = 1;
% figure1 = figure;
% in = oos:oos+1000;
% plot(in,i_stt(in),'b')
% hold on
% plot(in,i_stp(in),'k')
% plot(in,stm_fstd(in),'r')
% plot(in,stm(in),'g')
% plot(in,1.2)
% %
% figure2=figure;
% in = 1:numel(st);
% plot(st(in),'r')
% hold on
% scatter(reshape(oo,numel(oo),1),2*ones(numel(oo),1),20,'k')
% scatter(reshape(oo1,numel(oo1),1),2*ones(numel(oo1),1),10,'b')
