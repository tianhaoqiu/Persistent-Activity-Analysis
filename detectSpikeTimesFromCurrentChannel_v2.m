function [ spikeRasterOut, spikeIndexOut, spikeTimesOut ] = detectSpikeTimesFromCurrentChannel_v2(voltage, timeArray, current, currentThreshold, lowPassCutOff, sampleRate)
%DETECTSPIKETIMESFROMCURRENTCHANNEL spike detection for whole cell current clamp recordings
%   This function analyzes the current trace fluctuations from a 200B (amplifier) current clamp
%   recordings in order to find spike times in the voltage trace. The function will also plot the trace with spikes detected
%   marked
%
%         INPUTS
%           voltage - trace from recording
%           timeArray - timing of each sample in seconds
%           current - current trace from recording
%
%           lowPassCutOff - cut off for low pass
%                     filering the CURRENT trace before looking for peaks
%       	sampleRate, needed for lowpass filerering
%                     operation
%
%  OUTPUT  spikeRasterOut - logical array with 1 when spike onset occurs
%          spikeIndexOut - index values when the spike start time occured
%          spikeTimesOut - times (sec) when the spike start times occured
%
%    Yvette Fisher, 10/2020, updated 5/2022

filteredCurrent = lowPassFilter( current,  lowPassCutOff , sampleRate );


% FIND PEAKS in current channel 
%WIDTHS_REQUIRED = 10;
PEAK_WIDTH_REQUIRED = 0.0015*sampleRate; % 0.0015 s = 1.5 ms ~spike event width required
DIST_BETWEEN_PEAKS = 0.0025*sampleRate; %0.0025 s = 2.5 ms refreactory period

[~ , spikeIndex] = findpeaks( filteredCurrent, 'MinPeakHeight', currentThreshold, 'MinPeakWidth', PEAK_WIDTH_REQUIRED,'MinPeakDistance', DIST_BETWEEN_PEAKS);


% Added critera that voltage trace needs to be in upper XX % of Vm values
%to count
UPPER_PERCENTAGE = 15;
UpperVoltages = quantile(voltage, 1- UPPER_PERCENTAGE/ 100);
spikeIndex_upperVm = spikeIndex( voltage(spikeIndex) > UpperVoltages );

% add critera that spike index needs to be within 3ms of a peak that
% crosses into upper voltages
REQUIRED_MIN_DISTANCE_TO_VOLTAGE_PEAK = 0.0015*sampleRate; % 1.5 ms
[~ , voltagePeakIndex] = findpeaks( voltage, 'MinPeakHeight', UpperVoltages, 'MinPeakWidth', PEAK_WIDTH_REQUIRED,'MinPeakDistance', DIST_BETWEEN_PEAKS);


spikeIndex_upperVm_matchedPeaks = [];

for i = 1:length(spikeIndex_upperVm)

    currDistances = abs(voltagePeakIndex - spikeIndex_upperVm(i));
    if( min(currDistances) < REQUIRED_MIN_DISTANCE_TO_VOLTAGE_PEAK)
        spikeIndex_upperVm_matchedPeaks = [spikeIndex_upperVm_matchedPeaks spikeIndex_upperVm(i)];
    end

end

% Plot the voltage data, and detected spikes
figure('Position',[50, 50, 800, 400]);
set(gcf, 'Color', 'w');


ax(1) = subplot(2, 1 ,1);
plot( timeArray,  voltage ); hold on; box off

scatter( timeArray(spikeIndex),  voltage(spikeIndex) ); 
scatter( timeArray(spikeIndex_upperVm),  voltage(spikeIndex_upperVm) ); 
scatter( timeArray(spikeIndex_upperVm_matchedPeaks),  voltage(spikeIndex_upperVm_matchedPeaks) ); 

legend('Vm','all', 'upper %', 'upper % and matched Peaks');
xlabel('seconds');
ylabel('membrane voltage (mV)');

ax(2) = subplot(2, 1, 2);
plot( timeArray, filteredCurrent ); hold on; box off
%plot(timeArray, current);
scatter( timeArray(spikeIndex) , filteredCurrent(spikeIndex) );
xlabel('seconds');
ylabel('filtered current (pA)');

linkaxes(ax,'x');

title( ['Current threshold: ' num2str( currentThreshold ) ]);
%output variables
spikeIndexOut = spikeIndex_upperVm_matchedPeaks;
spikeTimesOut = timeArray(spikeIndex_upperVm_matchedPeaks);

spikeRasterOut = zeros(1, length(timeArray));
spikeRasterOut( spikeIndex_upperVm_matchedPeaks ) = 1; % put ones when the spikes occured

end

