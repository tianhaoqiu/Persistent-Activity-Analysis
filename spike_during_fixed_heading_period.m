%% Analyze spike during fixed heading period
% Get the file for analysis
single_trial_folder_path = fullfile('/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V5/Single_trial_data','persistence_single_trial_flyNum232_4_1_1*');
single_trial_foldir = dir(single_trial_folder_path);
cd('/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V5/Single_trial_data');
single_trial_data = importdata(single_trial_foldir(1).name);
cd('/Users/tianhaoqiu/Desktop/data analysis project/Analysis Code');

%%
angle_bin_size = 30;
[persistentHeatmap_Voltage_mean, persistentHeatmap_Voltage_value, sample_count_matrix] = persistentHeadingMatrix(single_trial_data.barPosition_lowSample, single_trial_data.persistenceArray, single_trial_data.voltage_lowSample, angle_bin_size,1, ceil(max(single_trial_data.persistenceArray)), 0);
transient_voltage_mean = persistentHeatmap_Voltage_mean(1,:);
[max_voltage, max_voltage_bin_index] = maxk(transient_voltage_mean,2);
[min_voltage, min_voltage_bin_index] = mink(transient_voltage_mean,2);



%% Get preferred/null direction stopping period on raw trace
raw_trial_folder_path = fullfile('/Users/tianhaoqiu/Desktop/data analysis project/raw_data','flyNum232_4_1_1*');
raw_trial_foldir = dir(raw_trial_folder_path);
spike_current_cutoff = 0.2;
raw_data_path = '/Users/tianhaoqiu/Desktop/data analysis project/raw_data';
analysis_code_path = '/Users/tianhaoqiu/Desktop/data analysis project/Analysis Code';
[raw_data_trace, raw_spike_raster,raw_spike_rate_250ms_exp,forwrd_velocity_raw, stopping_preferred_start_index,stopping_preferred_length,stopping_null_start_index,stopping_null_length] = get_raw_trace_persistence(raw_data_path,analysis_code_path,raw_trial_foldir,spike_current_cutoff,max_voltage_bin_index,min_voltage_bin_index);

%% Plot such trace
rawsampleRate = 20000;
for i = 1:length (stopping_preferred_start_index) 
%      if stopping_preferred_length(i) >= 10*rawsampleRate;
%          time_Array_temp = (1:length(10*rawsampleRate))/rawsampleRate;
%      end
     time_Array_temp = (1:stopping_preferred_length(i))/rawsampleRate;
     figure;
     set(gcf, 'Color', 'w');
     subplot(3,1,1)
     plot(time_Array_temp, raw_data_trace(stopping_preferred_start_index(i):stopping_preferred_start_index(i)+stopping_preferred_length(i)-1));
     title('Raw Voltage/Spike Trace during stopping period (preferred direction)');
     xlabel('sec')
     ylabel('mV')
     xlim([0 10]);
     ylim([-50 -20]);
     niceaxes();
     
     subplot(3,1,2)
     plot(time_Array_temp, raw_spike_raster(stopping_preferred_start_index(i):stopping_preferred_start_index(i)+stopping_preferred_length(i)-1));
     title('Spike Raster during stopping period (preferred direction)');
     xlabel('sec')
     ylabel('Spike Counts')
     xlim([0 10]);
     niceaxes();
     
     subplot(3,1,3)
     plot(time_Array_temp, raw_spike_rate_250ms_exp(stopping_preferred_start_index(i):stopping_preferred_start_index(i)+stopping_preferred_length(i)-1));
     title('Spike rate (Exponential filtered, tau =250ms) during stopping period (preferred direction)');
     xlabel('sec')
     ylabel('Hz')
     xlim([0 10]);
     ylim([0 20]);
     niceaxes();
     
     %niceaxes();
     %subplot(4,1,4)
     %plot(time_Array_temp, forwrd_velocity_raw(stopping_preferred_start_index(i):stopping_preferred_start_index(i)+stopping_preferred_length(i)-1));
     %title('Forward velocity during stopping period (preferred direction)');
     %xlabel('sec')
    % ylabel('Degrees/s')
end




for i = 1:length (stopping_null_start_index) 
     time_Array_temp = (1:stopping_null_length(i))/rawsampleRate;
     figure;
     set(gcf, 'Color', 'w');
     subplot(3,1,1)
     plot(time_Array_temp, raw_data_trace(stopping_null_start_index(i):stopping_null_start_index(i)+stopping_null_length(i)-1));
     title('Raw Voltage/Spike Trace during stopping period (null direction)');
     xlabel('sec')
     ylabel('mV')
     xlim([0 10]);
     niceaxes();
     
     subplot(3,1,2)
     plot(time_Array_temp, raw_spike_raster(stopping_null_start_index(i):stopping_null_start_index(i)+stopping_null_length(i)-1));
     title('Spike Raster during stopping period (null direction)');
     xlabel('sec')
     ylabel('Spike Counts')
     xlim([0 10]);
     niceaxes();
     
     subplot(3,1,3)
     plot(time_Array_temp, raw_spike_rate_250ms_exp(stopping_null_start_index(i):stopping_null_start_index(i)+stopping_null_length(i)-1));
     title('Spike rate (Exponential filtered, tau =250ms) during stopping period (null direction)');
     xlabel('sec')
     ylabel('Hz')
     xlim([0 10]);
     niceaxes();
     
    
%      subplot(4,1,4)
%      plot(time_Array_temp, forwrd_velocity_raw(stopping_null_start_index(i):stopping_null_start_index(i)+stopping_null_length(i)-1));
%      title('Forward velocity during stopping period (null direction)');
%      xlabel('sec')
%      ylabel('Degrees/s')
end
%% Code for extract stopping period on lowsampled data (not used)
%shift bar_position to 0-270 (easier for calculation)
% bar_Position_shifted = single_trial_data.barPosition_lowSample + 128;
% stop_period_preferred_direction_index = [];
% stop_period_preferred_direction_length = [];
% stop_period_null_direction_index = [];
% stop_period_null_direction_length = [];
% for i = 1:length(single_trial_data.persistence_stop_index)
%     stop_period_start_position = bar_Position_shifted(single_trial_data.persistence_stop_index(i) - single_trial_data.persistence_stop_length(i) + 1);
%     if (max_voltage_bin_index(1) -1)*angle_bin_size  <=  stop_period_start_position &&  stop_period_start_position <  max_voltage_bin_index(1)*angle_bin_size
%         stop_period_preferred_direction_index = [stop_period_preferred_direction_index, single_trial_data.persistence_stop_index(i)];
%         stop_period_preferred_direction_length = [stop_period_preferred_direction_length,single_trial_data.persistence_stop_length(i)];
%     end
%     
%     if (max_voltage_bin_index(2) -1)*angle_bin_size  <=  stop_period_start_position &&  stop_period_start_position <  max_voltage_bin_index(2)*angle_bin_size
%         stop_period_preferred_direction_index = [stop_period_preferred_direction_index, single_trial_data.persistence_stop_index(i)];
%         stop_period_preferred_direction_length = [stop_period_preferred_direction_length,single_trial_data.persistence_stop_length(i)];
%     end
%     
%     
%     if (min_voltage_bin_index(1) -1)*angle_bin_size  <=  stop_period_start_position &&  stop_period_start_position <  min_voltage_bin_index(1)*angle_bin_size
%         stop_period_null_direction_index = [stop_period_null_direction_index, single_trial_data.persistence_stop_index(i)];
%         stop_period_null_direction_length = [stop_period_null_direction_length, single_trial_data.persistence_stop_length(i)];
%     end
%     
%    if (min_voltage_bin_index(2)-1)*angle_bin_size  <=  stop_period_start_position &&  stop_period_start_position <  min_voltage_bin_index(2)*angle_bin_size
%         stop_period_null_direction_index = [stop_period_null_direction_index, single_trial_data.persistence_stop_index(i)];
%         stop_period_null_direction_length = [stop_period_null_direction_length, single_trial_data.persistence_stop_length(i)];
%     end
% end


% %%
% sampleRate_lowsampled = 100;
% for j = 1:length(stop_period_preferred_direction_index)
%     stop_period_start_index = stop_period_preferred_direction_index(j) - stop_period_preferred_direction_length(j) + 1;
%     time_Array_temp = (1:stop_period_preferred_direction_length(j))/sampleRate_lowsampled;
%     figure;
%     
%     subplot(3,1,1)
%     plot(time_Array_temp, single_trial_data.voltage_raw_lowSample(stop_period_start_index:stop_period_preferred_direction_index(j)))
%     title('Raw Voltage/Spike Trace during stopping period (preferred direction)')
%     xlabel('sec')
%     ylabel('mV')
%     niceaxes();
%     
%     subplot(3,1,2)
%     plot(time_Array_temp, single_trial_data.spikeRate_lowSample_exp_100ms(stop_period_start_index:stop_period_preferred_direction_index(j)))
%     title('Spike Rate (preferred direction)')
%     xlabel('sec')
%     ylabel('Hz')
%     niceaxes();
%     
%     subplot(3,1,3)
%     plot(time_Array_temp, single_trial_data.velocity_IntX(stop_period_start_index:stop_period_preferred_direction_index(j)))
%     title('Forward Velocity (preferred direction)')
%     xlabel('sec')
%     ylabel('Degrees/s')
%     niceaxes();
%     
% end
% 
% 
% %%
% for j = 1:length(stop_period_null_direction_index)
%     stop_period_start_index = stop_period_null_direction_index(j) - stop_period_null_direction_length(j) + 1;
%     time_Array_temp = (1:stop_period_null_direction_length(j))/sampleRate_lowsampled;
%     figure;
%     
%     subplot(3,1,1)
%     plot(time_Array_temp, single_trial_data.voltage_raw_lowSample(stop_period_start_index:stop_period_null_direction_index(j)))
%     title('Raw Voltage/Spike Trace during stopping period (null direction)')
%     xlabel('sec')
%     ylabel('mV')
%     niceaxes();
%     
%     subplot(3,1,2)
%     plot(time_Array_temp, single_trial_data.spikeRate_lowSample_exp_100ms(stop_period_start_index:stop_period_null_direction_index(j)))
%     title('Spike Rate (null direction)')
%     xlabel('sec')
%     ylabel('Hz')
%     niceaxes();
%     
%     subplot(3,1,3)
%     plot(time_Array_temp, single_trial_data.velocity_IntX(stop_period_start_index:stop_period_null_direction_index(j)))
%     title('Forward Velocity (null direction)')
%     xlabel('sec')
%     ylabel('Degrees/s')
%     niceaxes();
%     
% end