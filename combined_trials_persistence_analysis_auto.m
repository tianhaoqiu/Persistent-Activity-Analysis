function [] = combined_trials_persistence_analysis_auto(single_trial_directory, combine_trial_directory,fileName_flyNum, total_trial_number, flyNum_for_save)
% Automatic function written to combine single trial with persistence arrau
% formed for pooled analysis on the same fly
% Input 1: single_trial_directory; where the single trial is saved
% Input 2: combine_trial_directory; where to save the combined trial
% Input 3: fileName_flyNum, single persistence file names with the same
% flyNum
% Input 4: total_trial_number; number of single trial combined (for the record)
% Input 5: flyNum_for_save
% Tianhao Qiu 02.2023

%% Conmbine persistence data from multiple trials from a single neuron 
[barPosition_combined, persistenceArray_combined, spikeRate_combined, spikeRate_combined_exp_100ms,spikeRate_combined_exp_250ms, spikeRate_combined_exp_500ms, spikeRate_combined_exp_1s, voltage_combined, DOWN_SAMPLE_RATE_combined,velocity_angular_combined,velocity_IntX_combined,velocity_IntY_combined] = combine_persistenceTrial(single_trial_directory, fileName_flyNum);
    
%output_file = ['asdgfashg'];
cd('/Users/tianhaoqiu/Desktop/data analysis project/Analysis code')
%mkdir /Users/tianhaoqiu/Desktop/  output_file

%% Generate heatmap matrix for voltage/spike for a single cell with multiple trials combined 
%Changeable parameter for heading bin size in degrees,time bin size in second
heading_bin_size = 30;
time_bin_size = 1;
%Longest time for peisitence activity stay in a single heading direction
total_time = ceil(max(persistenceArray_combined));

%Create the persistent heading matrix for both spike and membrane voltage
%last argument (0/1) for whether using absolute value for averaging
%(velocity yes/1; spike, membrane voltahe no/0)
[persistentHeatmap_spike_mean, persistentHeatmap_spike_value, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined , persistenceArray_combined, spikeRate_combined, heading_bin_size,time_bin_size, total_time, 0);
[persistentHeatmap_spike_mean_100ms_exp, persistentHeatmap_spike_value_100ms_exp, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined , persistenceArray_combined, spikeRate_combined_exp_100ms, heading_bin_size,time_bin_size, total_time, 0);
[persistentHeatmap_spike_mean_250ms_exp, persistentHeatmap_spike_value_250ms_exp, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined , persistenceArray_combined, spikeRate_combined_exp_250ms, heading_bin_size,time_bin_size, total_time, 0);
[persistentHeatmap_spike_mean_500ms_exp, persistentHeatmap_spike_value_500ms_exp, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined , persistenceArray_combined, spikeRate_combined_exp_500ms, heading_bin_size,time_bin_size, total_time, 0);
[persistentHeatmap_spike_mean_1s_exp, persistentHeatmap_spike_value_1s_exp, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined , persistenceArray_combined, spikeRate_combined_exp_1s, heading_bin_size,time_bin_size, total_time, 0);
[persistentHeatmap_spike_mean_1s_exp_1500ms_bin, persistentHeatmap_spike_value_1s_exp_1500ms_bin, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined , persistenceArray_combined, spikeRate_combined_exp_1s, heading_bin_size,1.5, total_time, 0);
[persistentHeatmap_Voltage_mean, persistentHeatmap_Voltage_value, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined, persistenceArray_combined, voltage_combined, heading_bin_size,time_bin_size, total_time, 0);
[persistentHeatmap_Forward_velocity_mean, persistentHeatmap_Forward_velocity_value, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined, persistenceArray_combined, velocity_IntX_combined, heading_bin_size,time_bin_size, total_time, 1);
[persistentHeatmap_Angular_velocity_mean, persistentHeatmap_Angular_velocity_value, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined, persistenceArray_combined, velocity_angular_combined, heading_bin_size,time_bin_size, total_time, 1);
[persistentHeatmap_Y_velocity_mean, persistentHeatmap_Y_velocity_value, sample_count_matrix] = persistentHeadingMatrix(barPosition_combined, persistenceArray_combined, velocity_IntY_combined, heading_bin_size,time_bin_size, total_time, 1);
%Plot the heatmap for spike
figure;
set(gcf, 'Color', 'w');
%subplot(3,1,1);
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:ceil(max(persistenceArray_combined)));
heatmap(xvalues, YLabels, persistentHeatmap_spike_mean);
title(['Spike activity: w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, flyNum', num2str(flyNum_for_save)])
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')

%Plot the heatmap for voltage 
%subplot(3,1,2);
figure;
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:ceil(max(persistenceArray_combined)));
heatmap(xvalues, YLabels, persistentHeatmap_Voltage_mean);
title(['Membrane voltage: w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, flyNum', num2str(flyNum_for_save)])
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')

%Plot the heatmap for velocity in forward direction
%subplot(3,1,2);
figure;
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:ceil(max(persistenceArray_combined)));
heatmap(xvalues, YLabels, persistentHeatmap_Forward_velocity_mean);
title(['Velocity in forward direction (Degress/s): w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, flyNum', num2str(flyNum_for_save)])
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')



%Plot the sample count for each cell (converted to second based on sample
%rate
%subplot(3,1,3);
figure;
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:ceil(max(persistenceArray_combined)));
heatmap(xvalues, YLabels, sample_count_matrix/DOWN_SAMPLE_RATE_combined);
title(['Spike activity sample count (convert to second): w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, flyNum', num2str(flyNum_for_save)])
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')

%%

persistentHM.Heatmap_spike_mean = persistentHeatmap_spike_mean;
persistentHM.Heatmap_spike_mean_100ms_exp = persistentHeatmap_spike_mean_100ms_exp;
persistentHM.Heatmap_spike_mean_250ms_exp = persistentHeatmap_spike_mean_250ms_exp;
persistentHM.Heatmap_spike_mean_500ms_exp = persistentHeatmap_spike_mean_500ms_exp;
persistentHM.Heatmap_spike_mean_1s_exp_1500ms_bin = persistentHeatmap_spike_mean_1s_exp_1500ms_bin;
persistentHM.Heatmap_spike_mean_1s_exp = persistentHeatmap_spike_mean_1s_exp;
persistentHM.Heatmap_voltage_mean = persistentHeatmap_Voltage_mean;
persistentHM.Heatmap_spike_value = persistentHeatmap_spike_value;
persistentHM.Heatmap_spike_value_100ms_exp = persistentHeatmap_spike_value_100ms_exp;
persistentHM.Heatmap_spike_value_250ms_exp = persistentHeatmap_spike_value_250ms_exp;
persistentHM.Heatmap_spike_value_500ms_exp = persistentHeatmap_spike_value_500ms_exp;
persistentHM.Heatmap_spike_value_1s_exp = persistentHeatmap_spike_value_1s_exp;
persistentHM.Heatmap_spike_value_1s_exp_1500ms_bin = persistentHeatmap_spike_value_1s_exp_1500ms_bin;
persistentHM.Heatmap_voltage_value = persistentHeatmap_Voltage_value;
persistentHM.Heatmap_Forward_velocity_value = persistentHeatmap_Forward_velocity_value;
persistentHM.Heatmap_Forward_velocity_mean =  persistentHeatmap_Forward_velocity_mean;
persistentHM.Heatmap_Angular_velocity_value = persistentHeatmap_Angular_velocity_value;
persistentHM.Heatmap_Angular_velocity_mean = persistentHeatmap_Angular_velocity_mean;
persistentHM.Heatmap_Y_velocity_mean = persistentHeatmap_Y_velocity_mean;
persistentHM.Heatmap_Y_velocity_value = persistentHeatmap_Y_velocity_value;
persistentHM.Heatmap_sample_count_matrix = sample_count_matrix;
persistentHM.heading_bin_size = heading_bin_size;
persistentHM.time_bin_size= time_bin_size;
persistentHM.total_time = total_time;
persistentHM.DOWN_SAMPLE_RATE = DOWN_SAMPLE_RATE_combined;
%Number of trial used to generate combined heatmap from a single cell.
persistentHM.total_trial_number = total_trial_number;

cd(combine_trial_directory);
flyNum = flyNum_for_save;
formatSpec = 'combined_trial_fyNum%d';
file_name  =sprintf(formatSpec, flyNum);
save(file_name, 'persistentHM');
cd('/Users/tianhaoqiu/Desktop/data analysis project/Analysis code');



end %EOF