function [angular_forward_velocity_matrix] = foward_heading_relationship_check(angular_array,foward_array,sample_rate, dOWN_SAMPLE_RATE)


lowPass_velocity = 25;
max_velocity = 500;

[angular_array, accumulated_posiiton_1] = ficTracSignalDecoding(angular_array, sample_rate, lowPass_velocity, max_velocity);
[foward_array, accumulated_posiiton_2]= ficTracSignalDecoding(foward_array, sample_rate, lowPass_velocity, max_velocity);

downSampleFactor = sample_rate/dOWN_SAMPLE_RATE;
foward_array = downsample(foward_array,downSampleFactor);
downSampleFactor = sample_rate/dOWN_SAMPLE_RATE;
angular_array = downsample(angular_array,downSampleFactor);

%Only Amplitude matters
foward_array = abs(foward_array);
angular_array = abs(angular_array);

bin_size = 10;
foward_bin = ceil(max(foward_array) / bin_size);
angular_bin = ceil(max(angular_array)/ bin_size);

angular_forward_velocity_matrix = zeros(foward_bin, angular_bin);

for i = 1:angular_bin
    current_angular_index = find((i-1)*bin_size <= angular_array & angular_array < i*bin_size);
    for j = 1:length(current_angular_index)
        current_forward_index =  ceil(foward_array(current_angular_index(j)) /bin_size);
        if current_forward_index == 0
        angular_forward_velocity_matrix(1, i) = angular_forward_velocity_matrix(1, i) + 1;    
        else
        angular_forward_velocity_matrix(current_forward_index, i) = angular_forward_velocity_matrix(current_forward_index, i) + 1;
        end
    end
    
end


end