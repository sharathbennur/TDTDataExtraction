global CurrentBlock
data_b_folder = 'C:\Lab\Data\Mat\Beh\';
file_in = CurrentBlock;
save(strcat(data_b_folder,'B_',file_in),'data_b')