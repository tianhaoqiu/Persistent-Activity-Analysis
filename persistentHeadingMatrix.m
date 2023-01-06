function [persistent_matrix,persistent_matrix_value, count_matrix] = persistentHeadingMatrix(barPosition, persistenceArray, spikeRate_lowSample, heading_bin_size, time_bin_size, total_time, avg_abs)
%Generate heatmap matrix about spike rate when animals were under
%persistent heading in certain direction
%       Input 1: barPosition
%             Down sampled barPosition array containing bar/heading of
%             flies
%       Input 2: persistenceArray
%             Time Array containing info about how long flies have beed in
%             that certain heading for each index/sample
%       Input 3: spikeRate_lowSample
%             Down sampled and interpolated spikeRate array of flies
%             through out the sampling period
%       Input 4: heading_bin_size
%             Size of heading bin in degrees
%       Input 5: time_bin_size
%             Size of time bin in seconds
%       Input 6: total_time
%             Total/longest time considered for persistent heading 
%       Input 7: avg_abs
%             Whether using absolute value for calculting average value (no
%             for spike/voltage; yes for velocity
%       Output 1: persistent_matrix
%             The matrix used for generating heatmap of spike rate change
%             along persistent heading position
%       Output 2: count_matrix for how many samples are actually used for
%             averaging spike at each cells
%             The matrix used for 
%       Tianhao Qiu 4/2022

%Create bins based on decided bin size and shift barPosition to 0-360
%degree range
head_bin = ceil(270/heading_bin_size);
time_bin  = ceil(total_time/time_bin_size);
%Specific setting to adapt to Fisher et al 2019, (-127---143 range)
barPosition = barPosition + 128;

%Initiate persistent_matrix & count_matrix (for averaging the spike rate in
%each bin)
persistent_matrix = zeros(time_bin, head_bin);
%Instead of giving the mean of spike rate, it record spike rate of every
%sample in that cell
persistent_matrix_value = cell(time_bin, head_bin);
count_matrix = zeros(time_bin, head_bin);


for i = 1:head_bin
    %find all index in the barPosition that falls into the current head bin
    current_head_bin = find((i-1)*heading_bin_size <= barPosition & barPosition < i*heading_bin_size);
    %Remove NaN value for voltage trace fall in current head bin
    voltage_template = spikeRate_lowSample(current_head_bin);
    nan_voltage = find(isnan(voltage_template));
    current_head_bin(nan_voltage) = [];
    %Make sure array size is not 0
    if (size(current_head_bin) > 0)
        for k = 1:length(current_head_bin)
            %Get spike rate for each index in current haed bin
            current_spike = spikeRate_lowSample(current_head_bin(k));        
            for j = 1:time_bin
                %Assign spike rate to the time bin based on their
                %correspending index in persistentArray
                if ((j - 1) * time_bin_size <= persistenceArray(current_head_bin(k)) && persistenceArray(current_head_bin(k)) < j * time_bin_size)
                    if avg_abs > 0
                         persistent_matrix(j,i) = persistent_matrix(j,i) + abs(current_spike);
                    else
                         persistent_matrix(j,i) = persistent_matrix(j,i) + current_spike;
                    end
                    persistent_matrix_value{j,i} = [persistent_matrix_value{j,i}, current_spike];
                    count_matrix(j,i) = count_matrix(j,i) + 1;
                    break
                end
            end
        end
               
    end
    
end


%Iterate thourgh each cell in the persistent_matrix & count_matrix for
%averaging spike rate
%for o = 1:head_bin
    %for p = 1: time_bin       
        %if (count_matrix(p,o) == 0)
            %persistent_matrix(p,o) = 0;
        %else
            %persistent_matrix(p,o) = persistent_matrix(p,o)/count_matrix(p,o);
        %end
    %end
        
%end


persistent_matrix = persistent_matrix ./ count_matrix;




end