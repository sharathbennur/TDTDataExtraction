function findNexus

global fl;

fl=1;

% setup timer
PT = timer('ExecutionMode','fixedRate',...
    'BusyMode','queue',...
    'Period',300);

PT.TimerFcn = {@checkURL,'Nexus 4','Nexus 5'};

% run
disp('Starting Timer')
checkURL;
start(PT)