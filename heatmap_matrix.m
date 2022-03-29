function [matrix_final,matrix_voltage_count,matrix_event_count] = heatmap_matrix(spikeRasterOut, heading_averaged,persistent_cutoff,heading_bin_size,time_bin_size,total_time)
ephysSettings;
x_axis = 360 / heading_bin_size;
y_axis = (total_time / time_bin_size) + 1;
matrix_final = zeros (x_axis, y_axis);

%Array storing the headbinn index for each chunk of persistent to go to
%based on cut off (since between each cutoff the heading has been averaged in previous steps)
heading_bin_index = zeros (length(persistent_cutoff), 1);
%Iterate through each bin from larger to small indexes and in each bin
%iterates through the cutoff array for comparison 
%for i = 1:length (x_axis)
    %for j = 1:length(persistent_cutoff)
        %if (heading_averaged(persistent_cutoff(j)) + 180 <= heading_bin_size * (x_axis + 1 - i) )
            %heading_bin_index(j) = x_axis + 1 - i;
        %end     
    %end
%end

for i = 1:length (persistent_cutoff)
    for j = 1:x_axis
        if ((heading_averaged(persistent_cutoff(i)) + 180) <= (heading_bin_size * j) )
            heading_bin_index(i) = j;
            break
        end     
    end
end


%Array containing the length of each persistent heading corresponding to
%each cutoff
diff_temp = diff(persistent_cutoff);
persistence_length = [persistent_cutoff(1); diff_temp];


%Two matrix for: 1. # of event based on persistence activity in each cell
%2. Total voltage in each cell (the last cell is for persistence length > the total length). Spike rate is caculated by the division of
%two matrix
matrix_event_count = zeros (x_axis, y_axis);
matrix_voltage_count = zeros (x_axis, y_axis);
spikeRasterOut_trans =transpose(spikeRasterOut);


for k = 1:length(persistence_length)
    for l = 1:(y_axis - 1)
        if ((l-1)* time_bin_size < persistence_length(k) /settings.sampRate) && (persistence_length(k) /settings.sampRate <= l* time_bin_size) 
                matrix_event_count(heading_bin_index(k),l) =  matrix_event_count(heading_bin_index(k),l) + 1;
        elseif (persistence_length(k)/settings.sampRate > total_time)
                matrix_event_count(heading_bin_index(k),:) = matrix_event_count(heading_bin_index(k),:) + 1;               
        end                  
    end      
end
plot(persistence_length/settings.sampRate);

%Special case for the first chunk of persistence array for raster count
for o = 1:(y_axis - 1)
     if (persistence_length(1) /settings.sampRate > total_time)
         for p = 1:(y_axis - 1)
             matrix_voltage_count(heading_bin_index(1),p) = matrix_voltage_count(heading_bin_index(1),p) + sum(spikeRasterOut_trans((p-1)*time_bin_size*settings.sampRate:p*time_bin_size*settings.sampRate));
         end
         matrix_voltage_count(heading_bin_index(1),y_axis) = matrix_voltage_count(heading_bin_index(1),y_axis) + sum(spikeRasterOut_trans(total_time*settings.sampRate:persistent_length(1)));
     elseif (persistence_length(1)/settings.sampRate - (o-1)* time_bin_size  >= o* time_bin_size) && (o==1)
         matrix_voltage_count(heading_bin_index(1),o) = matrix_voltage_count(heading_bin_index(1),o) + sum(spikeRasterOut_trans(1:o*time_bin_size*settings.sampRate));
     elseif (persistence_length(1)/settings.sampRate - (o-1)* time_bin_size  >= o* time_bin_size)
         matrix_voltage_count(heading_bin_index(1),o) = matrix_voltage_count(heading_bin_index(1),o) + sum(spikeRasterOut_trans((o-1)*time_bin_size*settings.sampRate:o*time_bin_size*settings.sampRate));
     else
         matrix_voltage_count(heading_bin_index(1),o) = matrix_voltage_count(heading_bin_index(1),o) + sum(spikeRasterOut_trans((o*time_bin_size*settings.sampRate):(persistent_cutoff(1))));
     end
end

for m = 2:length(persistence_length)
    if ((persistence_length(m)/settings.sampRate) > total_time)
        for n = 1:(y_axis - 1)
            matrix_voltage_count(heading_bin_index(m),n) = matrix_voltage_count(heading_bin_index(m),n) + sum(spikeRasterOut_trans((persistent_cutoff(m)+(n-1)*time_bin_size*settings.sampRate):(persistent_cutoff(m)+n*time_bin_size*settings.sampRate)));
        end
        % Check Special condition if this this is the last chunk
        if (m < length(persistence_length))
            matrix_voltage_count(heading_bin_index(m),y_axis) = matrix_voltage_count(heading_bin_index(m),y_axis) + sum(spikeRasterOut_trans((persistent_cutoff(m)+total_time*settings.sampRate):persistent_cutoff(m+1)));
        else
            matrix_voltage_count(heading_bin_index(m),y_axis) = matrix_voltage_count(heading_bin_index(m),y_axis) + sum(spikeRasterOut_trans((persistent_cutoff(m)+total_time*settings.sampRate):length(spikeRasterOut)));
        end
    else
        for p = 1:(y_axis - 1)
            if (persistence_length(m)/settings.sampRate - (p-1)* time_bin_size  >= p* time_bin_size)
                matrix_voltage_count(heading_bin_index(m),p) = matrix_voltage_count(heading_bin_index(m),p) + sum(spikeRasterOut_trans((persistent_cutoff(m)+(p-1)*time_bin_size*settings.sampRate):(persistent_cutoff(m)+ p*time_bin_size*settings.sampRate)));
            else
                 % Check Special condition if this this is the last chunk
                if (m < length(persistence_length))
                    matrix_voltage_count(heading_bin_index(m),p) = matrix_voltage_count(heading_bin_index(m),p) + sum(spikeRasterOut_trans((persistent_cutoff(m)+(p-1)*time_bin_size*settings.sampRate):persistent_cutoff(m+1)));
                else
                    matrix_voltage_count(heading_bin_index(m),p) = matrix_voltage_count(heading_bin_index(m),p) + sum(spikeRasterOut_trans((persistent_cutoff(m)+(p-1)*time_bin_size*settings.sampRate):length(spikeRasterOut)));
                end
            end
        end
    end
end


%Generate the final heatmap matrix based on the previous two count/spike
%matrix


for q = 1: x_axis
    for r = 1: y_axis
        if (matrix_event_count(q,r) == 0 ) 
            matrix_final(q,r) = 0;
        else
            matrix_final(q,r) = matrix_voltage_count (q,r) / matrix_event_count(q,r);
        end
    end
end

matrix_final = transpose(matrix_final);

end