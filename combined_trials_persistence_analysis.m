%% Conmbine persistence data from multiple trials from a single neuron 
[barPosition_combined, persistenceArray_combined, spikeRate_combined, voltage_combined, DOWN_SAMPLE_RATE_combined,velocity_angular_combined,velocity_IntX_combined,velocity_IntY_combined] = combine_persistenceTrial('/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V3/Single_trial_data/flyNum318');
    




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
title('Spike activity: w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, 312')
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')

%Plot the heatmap for voltage 
%subplot(3,1,2);
figure;
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:ceil(max(persistenceArray_combined)));
heatmap(xvalues, YLabels, persistentHeatmap_Voltage_mean);
title('Membrane voltage: w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, 312')
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')

%Plot the heatmap for velocity in forward direction
%subplot(3,1,2);
figure;
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:ceil(max(persistenceArray_combined)));
heatmap(xvalues, YLabels, persistentHeatmap_Forward_velocity_mean);
title('Velocity in forward direction (Degress/s): w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, 312')
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')



%Plot the sample count for each cell (converted to second based on sample
%rate
%subplot(3,1,3);
figure;
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:ceil(max(persistenceArray_combined)));
heatmap(xvalues, YLabels, sample_count_matrix/DOWN_SAMPLE_RATE_combined);
title('Spike activity sample count (convert to second): w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, 312')
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')

%%

persistentHM.Heatmap_spike_mean = persistentHeatmap_spike_mean;
persistentHM.Heatmap_voltage_mean = persistentHeatmap_Voltage_mean;
persistentHM.Heatmap_spike_value = persistentHeatmap_spike_value;
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
persistentHM.total_trial_number = 3;
saveData('/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V3/Combined_trial_data/flyNum312',persistentHM);

