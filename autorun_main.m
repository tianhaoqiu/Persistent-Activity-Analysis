%% Read the key file information for spike/voltage persistence analysis
flyinfofile = readcell('/Users/tianhaoqiu/Desktop/Ephys-Persistence-Analysis-Info.xlsx');
flyNum_array = cell2mat(flyinfofile(2:length(flyinfofile),1));
cellNum_array = cell2mat(flyinfofile(2:length(flyinfofile),2));
expNum_array = cell2mat(flyinfofile(2:length(flyinfofile),3));
trialNum_array = cell2mat(flyinfofile(2:length(flyinfofile),4));
%Cutoff frequency for spike detection in single trial persistence analysis
lpf_array = cell2mat(flyinfofile(2:length(flyinfofile),5));
%Current threshold for spike detection in single trial persistence analysis
current_threshold_array = cell2mat(flyinfofile(2:length(flyinfofile),6));

%% Get the directory of raw data 
raw_data_folderpath = fullfile('/Users/tianhaoqiu/Desktop/data analysis project/raw_data', 'flyNum*');
raw_data_foldir= dir(raw_data_folderpath);
raw_data_path = '/Users/tianhaoqiu/Desktop/data analysis project/raw_data';
analysis_code_path = '/Users/tianhaoqiu/Desktop/data analysis project/Analysis Code';
single_persistence_save_path = '/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V6/Single_trial_data';
combined_persistence_save_path = '/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V4/Combined_trial_data';
%% Run the single persistence analysis auto function
for i = 1: length(raw_data_foldir)
   single_trial_persistence_analysis_auto(raw_data_path,analysis_code_path,single_persistence_save_path,raw_data_foldir(i).name,flyNum_array(i), cellNum_array(i), expNum_array(i),trialNum_array(i),lpf_array(i),current_threshold_array(i));
end

%% Run the combined persistence analysis auto function
single_persistece_folderpath = fullfile('/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V4/Single_trial_data','persistence_single_trial_flyNum*');
single_persistence_foldir= dir(single_persistece_folderpath);
count_trial_from_samefly = 0;
for j = 1: length(single_persistence_foldir)
    %check first file in the directory
    if j == 1
        previousflyNum = flyNum_array(j);
        currentflyNum = previousflyNum;
        count_trial_from_samefly = count_trial_from_samefly + 1;
    elseif j < length(single_persistence_foldir)
        previousflyNum = flyNum_array(j-1);
        currentflyNum = flyNum_array(j);
        if  currentflyNum == previousflyNum
            count_trial_from_samefly = count_trial_from_samefly + 1;
        else
            formatSpec_flynum = 'persistence_single_trial_flyNum%d*';
            fileName_for_combine = sprintf(formatSpec_flynum, previousflyNum);
            combined_trials_persistence_analysis_auto(single_persistence_save_path,combined_persistence_save_path,fileName_for_combine,count_trial_from_samefly,previousflyNum);
            count_trial_from_samefly = 1;           
        end
    %check last file in the directory
    else
        previousflyNum = flyNum_array(j-1);
        currentflyNum = flyNum_array(j);
        if  currentflyNum == previousflyNum
            count_trial_from_samefly = count_trial_from_samefly + 1;
            formatSpec_flynum = 'persistence_single_trial_flyNum%d*';
            fileName_for_combine = sprintf(formatSpec_flynum, previousflyNum);
            combined_trials_persistence_analysis_auto(single_persistence_save_path,combined_persistence_save_path,fileName_for_combine,count_trial_from_samefly,previousflyNum);
        else
            formatSpec_flynum = 'persistence_single_trial_flyNum%d*';
            fileName_for_combine = sprintf(formatSpec_flynum, previousflyNum);
            combined_trials_persistence_analysis_auto(single_persistence_save_path,combined_persistence_save_path,fileName_for_combine,count_trial_from_samefly,previousflyNum);
            
            fileName_for_combine_last = sprintf(formatSpec_flynum, currentflyNum);
            combined_trials_persistence_analysis_auto(single_persistence_save_path,combined_persistence_save_path,fileName_for_combine_last, 1,currentflyNum);
        
        end
    end
    
    
end