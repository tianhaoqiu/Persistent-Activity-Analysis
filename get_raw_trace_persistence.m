function [raw_trace,spikeRasterOut,spikeRate_exp_250ms, velocity_IntX, stop_period_preferred_direction_start_index, stop_period_preferred_direction_length,stop_period_null_direction_start_index,stop_period_null_direction_length] = get_raw_trace_persistence(raw_data_location,analysis_code_location,raw_trial_foldir_location,spike_current_cutoff_taken,max_voltage_bin,min_voltage_bin)

%% Get the raw recording
cd(raw_data_location);
raw_data = importdata(raw_trial_foldir_location(1).name);
cd(analysis_code_location);



%% code to load in data that is cleaner...
ephysSettings;

TOTAL_DEGREES_IN_PATTERN = 360;
DEGREE_PER_LED_SLOT = 360 / 96;  % 
MIDLINE_POSITION = 34;%
EDGE_OF_SCREEN_POSITION = 72; % last LED slot in postion units
EDGE_OF_SCREEN_DEG = (EDGE_OF_SCREEN_POSITION -  MIDLINE_POSITION ) * DEGREE_PER_LED_SLOT;

POSSIBLE_BAR_LOCATIONS = 2:2:71;
barPositionDegreesFromMidline = ( POSSIBLE_BAR_LOCATIONS - MIDLINE_POSITION ) * DEGREE_PER_LED_SLOT;

MINBARPOS = 1;
MAXBARPOS = 72;


patternOffsetPosition = decodePatternOffset( raw_data.stimulus.panelParams.patternNum );
    
xBarPostion =  raw_data .data.xPanelPos + patternOffsetPosition;
xBarPostion = mod( xBarPostion , MAXBARPOS );
    
barPositionDegreesVsMidline = (  xBarPostion - MIDLINE_POSITION) * DEGREE_PER_LED_SLOT;
timeArray_sec = (1:length(raw_data.data.scaledVoltage))/settings.sampRate;
raw_trace = raw_data.data.scaledVoltage;


%% Auto Spike detection to generate spike raster 
current_corrected = [];
current_corrected = [current_corrected, raw_data.data.current];
current_corrected(2*settings.sampRate:3*settings.sampRate) = current_corrected(2*settings.sampRate:3*settings.sampRate) - 0.5;
lowPassCutOff = 100; % hz
dVdT_SPIKE_THRESHOLD = 0.02;
currentThreshold = spike_current_cutoff_taken;
[spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimesFromCurrentChannel_v2(raw_data.data.scaledVoltage, timeArray_sec, current_corrected, currentThreshold, lowPassCutOff, settings.sampRate);


%% Get velocity information
lowPass_velocity = 25;
max_velocity = 500;
[velocity_angular, accumulated_position_1]= ficTracSignalDecoding(raw_data.data.ficTracAngularPosition, settings.sampRate, lowPass_velocity, max_velocity);
[velocity_IntX, accumulated_position_2]= ficTracSignalDecoding(raw_data.data.ficTracIntx, settings.sampRate, lowPass_velocity, max_velocity);
[velocity_IntY, accumulated_position_3]= ficTracSignalDecoding(raw_data.data.ficTracInty, settings.sampRate, lowPass_velocity, max_velocity);

%% Different ways to smooth spike raster
windowSize = settings.sampRate * 0.2;  % 0.2s sliding window
spikeRaster_boxfiltered = smoothdata(spikeRasterOut,'gaussian',windowSize);
spikeRaster_exp_100ms =  expsmooth_spike(spikeRasterOut,settings.sampRate,100);
spikeRaster_exp_250ms = expsmooth_spike(spikeRasterOut,settings.sampRate,250);
spikeRaster_exp_500ms = expsmooth_spike(spikeRasterOut,settings.sampRate,500);
spikeRaster_exp_1s = expsmooth_spike(spikeRasterOut,settings.sampRate,1000);

spikeRate_exp_250ms = spikeRaster_exp_250ms * settings.sampRate;
%% Get stopping period in preferred/null firing direction

% shift the bar_position to 0-270 degree range
bar_Position_shifted = barPositionDegreesVsMidline + 128;
bin_size = 30;
stop_period_preferred_direction_start_index = [];
stop_period_preferred_direction_length = [];
stop_period_null_direction_start_index = [];
stop_period_null_direction_length = [];
angular_speed_toloreance = 30;



% find all index that has low angular velocity(30 degrees/sec
bar_position_low_angular_index = find(abs(velocity_angular) <= angular_speed_toloreance);

%Now the start of period is the index in diff array where it does not equal 1
diff_low_angular_index = diff(bar_position_low_angular_index);
%jump point mark the end of stopping period
break_point = find(diff_low_angular_index ~=1);

stopping_period_start_index = bar_position_low_angular_index(break_point + 1);
%Add first index as one missing start point
stopping_period_start_index = cat(1, 1, stopping_period_start_index);

stopping_period_end_index = bar_position_low_angular_index(break_point);
%Add last index as one missing end point
stopping_period_end_index = cat(1, stopping_period_end_index, bar_position_low_angular_index(length(bar_position_low_angular_index)));

% Stopping period must be at least 3s for meaningful analysis
stopping_duration_threshold = settings.sampRate * 3;

% Find long enough period and if they start at preferred/null direction 
for i = 1:length(stopping_period_start_index)
    period_duration = stopping_period_end_index(i) - stopping_period_start_index(i) + 1;
    if period_duration >= stopping_duration_threshold
        
        %Preferred direction
        if ~isempty(max_voltage_bin)
            for j = 1:length(max_voltage_bin)
                if bin_size * (max_voltage_bin(j) -1) <= bar_Position_shifted(stopping_period_start_index(i)) && bar_Position_shifted(stopping_period_start_index(i)) < bin_size * max_voltage_bin(j)
                    stop_period_preferred_direction_start_index = [stop_period_preferred_direction_start_index,stopping_period_start_index(i)];
                    stop_period_preferred_direction_length = [stop_period_preferred_direction_length, period_duration];
                end
            end
        end
            
        %Null direction    
   
        if ~isempty(min_voltage_bin)
            for k = 1:length(min_voltage_bin)
                if bin_size * (min_voltage_bin(k) -1) <= bar_Position_shifted(stopping_period_start_index(i)) && bar_Position_shifted(stopping_period_start_index(i)) < bin_size * min_voltage_bin(k)
                    stop_period_null_direction_start_index = [stop_period_null_direction_start_index,stopping_period_start_index(i)];
                    stop_period_null_direction_length = [stop_period_null_direction_length, period_duration];
                end
            end
            
        end

    end
end
    
% raw_trace_p_firing_start_length_index = cat(1,stop_period_preferred_direction_start_index, stop_period_preferred_direction_length);
% raw_trace_n_firing_start_length_index = cat(1,stop_period_null_direction_start_index,stop_period_null_direction_length);

end