% script to run through to collate all data and get final data file

%% convert behavioral data file from labview into a 'data' struct that can be used 
% for analyzing behavior

makeData_b('bjww198c','Bld')

%% get data from TDT for the same session and save 'data'

TDTOffline_GUI

%% Combine the files to get final data file
% combine data file saved from TDTOffline_GUI (D_nrl folder) with data file from the
% LabView computer with the same name (D_beh folder)

combine_BN('bjww193f')