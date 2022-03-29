    

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

%Binning the head/bar direction to somewhat a step function as an
%estimation of prolonged persisitent head direction

%binned_size = 4;
%[binned_head_barDirection, diff_index, diff_heading_pairwise] = binning_heading(barPositionDegreesVsMidline, binned_size);


% important ones barPositionDegreesVsMidline, scaledVoltage and timeArray

%%
lowPassCutOff = 90; % hz
timeArray_sec = (1:length(data.scaledVoltage))/settings.sampRate;

[ spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimes(data.scaledVoltage, timeArray_sec, 0.05, lowPassCutOff, settings.sampRate);

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

interpolSpikeRate = interp1( binsCenters, spikesPerSecond, timeArray_sec );
%
plot(spikesPerSecond)
figure
plot(interpolSpikeRate)

%interpolSpikeRate


%DEG Bin size = 


inBin = 50 <= barPositionDegreesVsMidline & barPositionDegreesVsMidline <= 100;


diff(inBin);

%%
%Binning the head/bar direction to somewhat a step function as an
%estimation of prolonged persisitent head direction

%Range of variability that could be tolorated as persistent
var_heading_threshold = 5;
[persistent_cutoff] = persistent_heading(var_heading_threshold,barPositionDegreesVsMidline);


%%
[heading_averaged] = average_heading(barPositionDegreesVsMidline, persistent_cutoff);

%% Draw heatmap based on binn size for heading direction & time
heading_bin_size = 20;
time_bin_size = 1;
total_time = 10;
[persistent_heatmap_matrix,matrix_voltage_count,matrix_event_count] = heatmap_matrix(spikeRasterOut, heading_averaged, persistent_cutoff,heading_bin_size,time_bin_size,total_time);
