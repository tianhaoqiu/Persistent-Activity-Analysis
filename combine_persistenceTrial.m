function [barPosition_combine, persistenceArray_combine, spikeRate_combine, voltage_combine, DOWN_SAMPLE_RATE_combine,velocity_angular_combine,velocity_IntX_combine,velocity_IntY_combine] = combine_persistenceTrial(directory)
% combine_persistenceTrial 
% A function that combines trial data from a single cell for further
% persistence analysis by concatenating the relevant variables directly
%
%     Input: current directory  of single trial data
%
%
%Tianhao Qiu 6/2022

barPosition_combine = [];
persistenceArray_combine = [];
spikeRate_combine = [];
voltage_combine = [];
velocity_angular_combine = [];
velocity_IntX_combine = [];
velocity_IntY_combine = [];
cd(directory);

theFiles = dir(fullfile(directory,'*.mat'));

for i = 1:length(theFiles)
    current_file_name = fullfile(directory, theFiles(i).name);
    current_file = importdata(current_file_name);
    barPosition_combine = cat(1,barPosition_combine,current_file.barPosition_lowSample);
    persistenceArray_combine = cat(1,persistenceArray_combine,current_file.persistenceArray);
    spikeRate_combine = cat(2,spikeRate_combine,current_file.spikeRate_lowSample);
    voltage_combine = cat(1,voltage_combine,current_file.voltage_lowSample);
    DOWN_SAMPLE_RATE_combine = current_file.DOWN_SAMPLE_RATE;
    velocity_angular_combine = cat(1,velocity_angular_combine,current_file.velocity_angular);
    velocity_IntX_combine =cat(1,velocity_IntX_combine,current_file.velocity_IntX);
    velocity_IntY_combine =cat(1,velocity_IntY_combine,current_file.velocity_IntY);
end


end