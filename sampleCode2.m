% code to load in data that is cleaner...

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

figure;
set(gcf, 'Color', 'w');
plot(barPositionDegreesVsMidline);
niceaxes();

%Binning the head/bar direction to somewhat a step function as an
%estimation of prolonged persisitent head direction

%binned_size = 4;
%[binned_head_barDirection, diff_index, diff_heading_pairwise] = binning_heading(barPositionDegreesVsMidline, binned_size);


% important ones barPositionDegreesVsMidline, scaledVoltage and timeArray

%%
current_corrected = [];
current_corrected = [current_corrected, data.current];
current_corrected(2*settings.sampRate:3*settings.sampRate) = current_corrected(2*settings.sampRate:3*settings.sampRate) - 0.5;
lowPassCutOff = 90; % hz
timeArray_sec = (1:length(data.scaledVoltage))/settings.sampRate;
dVdT_SPIKE_THRESHOLD = 0.02;
currentThreshold = 1.5;
analysis_mode = 3;
if (analysis_mode == 1)
    [spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes(data.scaledVoltage, timeArray_sec, dVdT_SPIKE_THRESHOLD, lowPassCutOff, settings.sampRate);
elseif (analysis_mode == 2)
    [spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes_negative_dVdt(data.scaledVoltage, timeArray_sec, dVdT_SPIKE_THRESHOLD, lowPassCutOff, settings.sampRate);
else
    [spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimesFromCurrentChannel_v2(data.scaledVoltage, timeArray_sec, current_corrected, currentThreshold, lowPassCutOff, settings.sampRate);
end

%%
% Take out velocity information 
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

%%
% calculate spike rate (spikes/s)
% Convert spike times into a smoothed spike rate
binWidthSec = 1; % sec
binsEdges = 0 : binWidthSec : timeArray_sec(end) ;
binsCenters = binsEdges(1 : end - 1) + ( binWidthSec / 2);
% find counts of spikes in each bin
n = histcounts ( spikeTimesOut , binsEdges  );

% normalized by bin width (seconds)
spikesPerSecond = n / (  binWidthSec );
interpolSpikeRate = interp1( binsCenters, spikesPerSecond, timeArray_sec, 'linear','extrap' );
%


% down sample spikeRate and heading information:
DOWN_SAMPLE_RATE = 100; % Hz  % WARNING don't run on higher than 500Hz unless you have lots of time to wait ;)
downSampleFactor = settings.sampRate / DOWN_SAMPLE_RATE;

spikeRate_lowSample = downsample(interpolSpikeRate, downSampleFactor);
barPosition_lowSample = downsample(barPositionDegreesVsMidline, downSampleFactor);
velocity_angular_lowSample = downsample(velocity_angular, downSampleFactor);
velocity_IntX_lowSample = downsample(velocity_IntX, downSampleFactor);
velocity_IntY_lowSample = downsample(velocity_IntY, downSampleFactor);
timeArray_lowSample = (1:length(barPosition_lowSample)) / DOWN_SAMPLE_RATE;

% plot to check that signals still look the same
figure;
subplot(2,1,1);
plot(timeArray_sec, interpolSpikeRate)

subplot(2,1,2)
plot(timeArray_lowSample, spikeRate_lowSample);
xlabel('sec')

figure;
subplot(2,1,1);
plot(timeArray_sec, barPositionDegreesVsMidline)

subplot(2,1,2)
plot(timeArray_lowSample, barPosition_lowSample);
xlabel('sec')



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
%%
%lowPassCutOff_barPosition = 1;
%barPosition_lowSample = lowPassFilter(barPosition_lowSample,lowPassCutOff_barPosition,DOWN_SAMPLE_RATE);
%figure;
%%
%Binning the head/bar direction to somewhat a step function as an
%estimation of prolonged persisitent head direction

%Range of variability that could be tolorated as persistent
var_heading_threshold = 10;

v1_threshold = quantile(velocity_angular_lowSample , 1-0.5/100);
v2_threshold = quantile(velocity_IntX_lowSample , 1-0.5/100);
v3_threshold = quantile(velocity_IntY_lowSample , 1-0.5/100);

[persistenceArray] = persistenceOfHeadingBySample(var_heading_threshold,barPosition_lowSample, DOWN_SAMPLE_RATE);

[persistenceArray_2] = persistenceOfHeadingBySample_v2(var_heading_threshold,barPosition_lowSample, DOWN_SAMPLE_RATE,velocity_angular_lowSample,velocity_IntX_lowSample,velocity_IntY_lowSample,v1_threshold,v2_threshold,v3_threshold);

% plot to check that persistentArray looks correct
figure;
set(gcf, 'Color', 'w');
subplot(3,1,1);
plot(timeArray_lowSample, barPosition_lowSample);
ylabel('heading (deg)','FontSize', 14)
niceaxes();


subplot(3,1,2);
plot(timeArray_lowSample, persistenceArray);
ylabel('heading persistence (s)','FontSize', 14)
xlabel('sec')
niceaxes();

subplot(3,1,3);
plot(timeArray_lowSample, persistenceArray_2);
ylabel('heading persistence (s)','FontSize', 14)
xlabel('sec')
niceaxes();

%%

%Changeable parameter for heading,time bin size,  total time
%Warning  1: Make sure the max duration do not exceed total_time by looking at
%persistenceArray plot
%Warning  2: heading/time bin must be divisible by 360, total_time
%respectively
heading_bin_size = 30;
time_bin_size = 1;
total_time = 14;

%Transpose spikeRate 
spikeRate_lowSample = transpose(spikeRate_lowSample);

%Create the persistent heading matrix 
[persistentHeatmap] = persistentHeadingMatrix(barPosition_lowSample, persistenceArray, spikeRate_lowSample, heading_bin_size,time_bin_size, total_time);

%Plot the heatmap
figure;
set(gcf, 'Color', 'w');
%xvalues = {'9?','27?','45?','63?','81?','99?','107?','125?','143?','161?','179?','197?','215?','233?','251?'};
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
%yvalues = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56'};
%yvalues = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85','86','87','88','89','90','91','92','93','94','95','96','97','98','99','100','101','102','103','104','105','106','107','108','109','110','111','112','113','114','115','116','117','118','119','120','121','122','123','124','125','126','127','128','129'};
yvalues = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'};
heatmap(xvalues, yvalues, persistentHeatmap);
title('w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, 107.2.2.3')
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')
niceaxes();

persistentHM.Heatmap = persistentHeatmap;
persistentHM.heading_bin_size = heading_bin_size;
persistentHM.time_bin_size= time_bin_size;
persistentHM.total_time = total_time;
persistentHM.current_Threshold = currentThreshold;
persistentHM.lowPassCutOff =lowPassCutOff;
persistentHM.DOWN_SAMPLE_RATE = DOWN_SAMPLE_RATE;
%persistentHM.lowPassCutOff_barPosition = lowPassCutOff_barPosition;
%saveData('/Users/tianhaoqiu/Desktop/data analysis project/Heatmapdata',persistentHM);