function[stop_end_index,stop_length] = find_stop_period_on_heading(angular_vel_array, degree_of_tolerance,shortest_stopFrame)
stop_end_index = [];
stop_length = [];
count = 0;
for i = 1:length(angular_vel_array)
    if i == length(angular_vel_array)
        if abs(angular_vel_array(i)) <= degree_of_tolerance
            count = count + 1;
            if count >= shortest_stopFrame
                stop_end_index = [stop_end_index, i];
                stop_length =[stop_length, count];
            end
        elseif count >= shortest_stopFrame
             stop_end_index = [stop_end_index, i-1];
             stop_length =[stop_length, count];
        end
    elseif i < length(angular_vel_array)
        if abs(angular_vel_array(i)) <= degree_of_tolerance
            count = count + 1;
        elseif count < shortest_stopFrame
            count = 0;
        else
            stop_end_index = [stop_end_index, i-1];
            stop_length =[stop_length, count];
            count = 0;
        end
    end
    
end


end
