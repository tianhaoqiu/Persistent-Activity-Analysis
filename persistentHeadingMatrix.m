function [persistent_matrix] = persistentHeadingMatrix(barPosition, persistenceArray, spikeRate_lowSample, heading_bin_size, time_bin_size, total_time)
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
%       Output: persistent_matrix
%             The matrix used for generating heatmap of spike rate change
%             along persistent heading position
%       Tianhao Qiu 4/2022

%Create bins based on decided bin size and shift barPosition to 0-360
%degree range
head_bin = 360/heading_bin_size;
time_bin  = total_time/time_bin_size;
barPosition = barPosition + 180;

%Initiate persistent_matrix & count_matrix (for averaging the spike rate in
%each bin)
persistent_matrix = zeros(time_bin, head_bin);
count_matrix = zeros(time_bin, head_bin);


for i = 1:head_bin
    %find all index in the barPosition that falls into the current head bin
    current_head_bin = find((i-1)*heading_bin_size <= barPosition & barPosition < i*heading_bin_size);
    %Make sure array size is not 0
    if (size(current_head_bin) > 0)
        for k = 1:length(current_head_bin)
            %Get spike rate for each index in current haed bin
            current_spike = spikeRate_lowSample(current_head_bin(k));        
            for j = 1:time_bin
                %Assign spike rate to the time bin based on their
                %correspending index in persistentArray
                if (j - 1 <= persistenceArray(current_head_bin(k)) && persistenceArray(current_head_bin(k)) < j)
                    persistent_matrix(j,i) = persistent_matrix(j,i) + current_spike;
                    count_matrix(j,i) = count_matrix(j,i) + 1;
                    break
                end
            end
        end
               
    end
    
end


%Iterate thourgh each cell in the persistent_matrix & count_matrix for
%averaging spike rate
for o = 1:head_bin
    for p = 1: time_bin       
        if (count_matrix(p,o) == 0)
            persistent_matrix(p,o) = 0;
        else
            persistent_matrix(p,o) = persistent_matrix(p,o)/count_matrix(p,o);
        end
    end
        
end



end