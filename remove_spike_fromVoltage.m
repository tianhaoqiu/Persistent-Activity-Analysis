function[voltage_spikeRemoved] = remove_spike_fromVoltage(voltage_array, spikeIndex, remove_window)

%Remove spike from volage trace by assigning NaN to the window around each
%spike index
%Tianhao Qiu 12/2022

half_window = floor(remove_window/2);
voltage_spikeRemoved = voltage_array;
for i = 1:length(spikeIndex)
    
    current_spike_index =spikeIndex(i);
    if (current_spike_index - half_window < 1)
        voltage_spikeRemoved((1):(current_spike_index + half_window)) = NaN;
    elseif (current_spike_index + half_window > length(voltage_array))
        voltage_spikeRemoved((current_spike_index - half_window):(length(voltage_array))) = NaN;
    else
        voltage_spikeRemoved((current_spike_index - half_window):(current_spike_index + half_window)) = NaN;
    end
    
end


end
