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


patternOffsetPosition = decodePatternOffset( stimulus.panelParams.patternNum );
    
xBarPostion =  data.xPanelPos + patternOffsetPosition;
xBarPostion = mod( xBarPostion , MAXBARPOS );
    
barPositionDegreesVsMidline = (  xBarPostion - MIDLINE_POSITION) * DEGREE_PER_LED_SLOT;
timeArray_sec = (1:length(data.scaledVoltage))/settings.sampRate;
figure;
set(gcf, 'Color', 'w');
plot(timeArray_sec, barPositionDegreesVsMidline);
niceaxes();





%% Spike detection 
current_corrected = [];
current_corrected = [current_corrected, data.current];
current_corrected(2*settings.sampRate:3*settings.sampRate) = current_corrected(2*settings.sampRate:3*settings.sampRate) - 0.5;
lowPassCutOff = 100; % hz
dVdT_SPIKE_THRESHOLD = 0.02;
currentThreshold = -5.6;
analysis_mode = 3;
if (analysis_mode == 1)
    [spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes(data.scaledVoltage, timeArray_sec, dVdT_SPIKE_THRESHOLD, lowPassCutOff, settings.sampRate);
elseif (analysis_mode == 2)
    [spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes_negative_dVdt(data.scaledVoltage, timeArray_sec, dVdT_SPIKE_THRESHOLD, lowPassCutOff, settings.sampRate);
elseif (analysis_mode == 3)
    [spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimesFromCurrentChannel_v2(data.scaledVoltage, timeArray_sec, current_corrected, currentThreshold, lowPassCutOff, settings.sampRate);
else
    [spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimesFromCurrentChannel_v3(data.scaledVoltage, timeArray_sec, current_corrected, currentThreshold, lowPassCutOff, highPassCutOff,settings.sampRate);
end

%%
%highPassCutOff = 10;
%currentThreshold_bp = 1.1;
%[spikeRasterOut2, spikeIndexOut2, spikeTimesOut2 ] = detectSpikeTimesFromCurrentChannel_v3(data.scaledVoltage, timeArray_sec, current_corrected, currentThreshold_bp, lowPassCutOff, highPassCutOff,settings.sampRate);
%% Median Filtering the voltage trace to remove spike (not working very well)
%MEDIAN_FILTER_WIDTH_SEC = 0.04; % sec, 40 msec
%ORDER_MEDFILTER = MEDIAN_FILTER_WIDTH_SEC * settings.sampRate;
%filteredVoltage = medfilt1(data.scaledVoltage, ORDER_MEDFILTER , 'truncate', 2); % Median filtering of the trace
%% Testing PSD
%figure;
%psd(spectrum.periodogram,voltage_lowSample,'Fs',100)
%figure;
%psd(spectrum.periodogram,data.scaledVoltage,'Fs',settings.sampRate)
%figure;
%nfft = 5000;
%periodogram(data.scaledVoltage(3000000:4000000),[],nfft,settings.sampRate)
%% Test correlation between angular and foward velocity
DOWN_SAMPLE_RATE = 100;
matrix_velocity = foward_heading_relationship_check(data.ficTracAngularPosition,data.ficTracIntx,settings.sampRate, DOWN_SAMPLE_RATE);
matrix_velocity = transpose(matrix_velocity);
figure;
set(gcf, 'Color', 'w');
heatmap(matrix_velocity);
ylabel('Angular Velocity (10 degrees/s/cell)')
xlabel('Velocity in Forward Axis (10 degrees/s/cell)')
niceaxes();
good_velocity = 0;


%% Remove voltage (assign NaN) to values around each spike (20ms)
window_around_spike = 0.020 *settings.sampRate;
filteredVoltage = remove_spike_fromVoltage(data.scaledVoltage, spikeIndexOut, window_around_spike);
plot(timeArray_sec,filteredVoltage);
%%
%Take out velocity information if first round analysis turned out to be bad

if (good_velocity == 0)
    lowPass_velocity = 25;
    max_velocity = 500;
    [velocity_angular, accumulated_position_1]= ficTracSignalDecoding(data.ficTracAngularPosition, settings.sampRate, lowPass_velocity, max_velocity);
    [velocity_IntX, accumulated_position_2]= ficTracSignalDecoding(data.ficTracIntx, settings.sampRate, lowPass_velocity, max_velocity);
    [velocity_IntY, accumulated_position_3]= ficTracSignalDecoding(data.ficTracInty, settings.sampRate, lowPass_velocity, max_velocity);

    figure;
    set(gcf, 'Color', 'w');
    subplot(3,1,1);
    plot(timeArray_sec, velocity_angular);
    ylabel('Velocity (deg/s)','FontSize', 14)

    subplot(3,1,2);
    plot(timeArray_sec, velocity_IntX);
    ylabel('Velocity (deg/s)','FontSize', 14)

    subplot(3,1,3);
    plot(timeArray_sec, velocity_IntY);
    ylabel('Velocity (deg/s)','FontSize', 14)

    xlabel('sec')

end


%% Downsampling and calculating the spike rate
% calculate spike rate (spikes/s)
% Convert spike times into a smoothed spike rate
%binWidthSec = 1; % 1s
%binsEdges = 0 : binWidthSec : timeArray_sec(end) ;
%binsCenters = binsEdges(1 : end - 1) + ( binWidthSec / 2);
%find counts of spikes in each bin
%n = histcounts ( spikeTimesOut , binsEdges  );

% normalized by bin width (seconds)
%spikesPerSecond = n / (  binWidthSec );
%interpolSpikeRate = interp1( binsCenters, spikesPerSecond, timeArray_sec, 'linear','extrap' );
%


% down sample spikeRate and heading information:
DOWN_SAMPLE_RATE = 100; % Hz  % WARNING don't run on higher than 500Hz unless you have lots of time to wait ;)
downSampleFactor = settings.sampRate / DOWN_SAMPLE_RATE;

%spikeRate_lowSample = downsample(interpolSpikeRate, downSampleFactor);
barPosition_lowSample = downsample(barPositionDegreesVsMidline, downSampleFactor);
voltage_lowSample = downsample(filteredVoltage, downSampleFactor);
timeArray_lowSample = (1:length(barPosition_lowSample)) / DOWN_SAMPLE_RATE;


%Smoothing the raster plot
windowSize = settings.sampRate * 0.2;  % 0.2s sliding window
%Method One
%box_filter_numerator_coefficient = (1/windowSize)*ones(1,windowSize);
%spikeRaster_boxfiltered = filter(box_filter_numerator_coefficient,1,spikeRasterOut);

%Method Two
%gausswin_filter_numerator_coefficient = gausswin(windowSize);
%spikeRaster_boxfiltered = filter(gausswin_filter_numerator_coefficient,1,spikeRasterOut);

%Method Three
spikeRaster_boxfiltered = smoothdata(spikeRasterOut,'gaussian',windowSize);

spikeRate_filtered_lowsample = zeros(1,length(voltage_lowSample));
%for i = 1:length(spikeRate_filtered_lowsample)
    %spikeRate_filtered_lowsample(i) = sum(spikeRaster_boxfiltered(1+(i-1)*downSampleFactor:i*downSampleFactor)); 
%end
%spikeRate_filtered_lowsample = spikeRate_filtered_lowsample/0.01;
spikeRate_filtered_lowsample = downsample(spikeRaster_boxfiltered*settings.sampRate, downSampleFactor);


% plot to check that signals still look the same
figure;
subplot(2,1,1);
plot(timeArray_sec, spikeRaster_boxfiltered)

subplot(2,1,2)
plot(timeArray_lowSample, spikeRate_filtered_lowsample);
xlabel('sec')

figure;
subplot(2,1,1);
plot(timeArray_sec, barPositionDegreesVsMidline)

subplot(2,1,2)
plot(timeArray_lowSample, barPosition_lowSample);
xlabel('sec')

figure;
subplot(2,1,1);
plot(timeArray_sec, filteredVoltage)

subplot(2,1,2)
plot(timeArray_lowSample, voltage_lowSample);
xlabel('sec')

if (good_velocity == 0)
    velocity_angular_lowSample = downsample(velocity_angular, downSampleFactor);
    velocity_IntX_lowSample = downsample(velocity_IntX, downSampleFactor);
    velocity_IntY_lowSample = downsample(velocity_IntY, downSampleFactor);
    figure;
    subplot(3,2,1)
    plot(timeArray_sec, velocity_angular)
    subplot(3,2,2)
    plot(timeArray_lowSample, velocity_angular_lowSample)
    subplot(3,2,3)
    plot(timeArray_sec, velocity_IntX)
    subplot(3,2,4)
    plot(timeArray_lowSample, velocity_IntX_lowSample)
    subplot(3,2,5)
    plot(timeArray_sec, velocity_IntY)
    subplot(3,2,6)
    plot(timeArray_lowSample, velocity_IntY_lowSample)
end
%% Calculating Persistence of heading
good_velocity = 1;
%Binning the head/bar direction to somewhat a step function as an
%estimation of prolonged persisitent head direction

%Range of variability that could be tolorated as persistent
var_heading_threshold = 10;

%v1_threshold = quantile(velocity_angular_lowSample , 1-0.1/100);
%v2_threshold = quantile(velocity_IntX_lowSample , 1-0.3/100);
%v3_threshold = quantile(velocity_IntY_lowSample , 1-0.1/100);

if (good_velocity == 1)
    [persistenceArray] = persistenceOfHeadingBySample(var_heading_threshold,barPosition_lowSample, DOWN_SAMPLE_RATE);
else
    [persistenceArray_2] = persistenceOfHeadingBySample_v2(var_heading_threshold,barPosition_lowSample, DOWN_SAMPLE_RATE,velocity_angular_lowSample,velocity_IntX_lowSample,velocity_IntY_lowSample,v1_threshold,v2_threshold,v3_threshold);
end

% plot to check that persistentArray looks correct
figure;
set(gcf, 'Color', 'w');
subplot(2,1,1);
plot(timeArray_lowSample, barPosition_lowSample);
ylabel('heading (deg)','FontSize', 14)
niceaxes();

if (good_velocity == 1)
    subplot(2,1,2);
    plot(timeArray_lowSample, persistenceArray);
    ylabel('heading persistence (s)','FontSize', 14)
    xlabel('sec')
    niceaxes();
else
    subplot(2,1,2);
    plot(timeArray_lowSample, persistenceArray_2);
    ylabel('heading persistence (s)','FontSize', 14)
    xlabel('sec')
    niceaxes();
end


%% Save key data for single trial
persistence_single_trial.current_Threshold = currentThreshold;
persistence_single_trial.lowPassCutOff =lowPassCutOff;
persistence_single_trial.persistenceArray = persistenceArray;
persistence_single_trial.barPosition_lowSample = barPosition_lowSample;
persistence_single_trial.spikeRate_lowSample = spikeRate_filtered_lowsample;
persistence_single_trial.voltage_lowSample = voltage_lowSample;
persistence_single_trial.velocity_angular = velocity_angular_lowSample;
persistence_single_trial.velocity_IntX = velocity_IntX_lowSample;
persistence_single_trial.velocity_IntY = velocity_IntY_lowSample;
persistence_single_trial.DOWN_SAMPLE_RATE = DOWN_SAMPLE_RATE;
saveData('/Users/tianhaoqiu/Desktop/data analysis project/processed_data_V3/Single_trial_data/flyNum318',persistence_single_trial);