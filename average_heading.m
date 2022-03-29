function [binned_head_bar] = average_heading(bar_position_array, persistent_cutoff)

binned_head_bar = zeros(length(bar_position_array), 1);
cut_off = 1;
for j = 1:length(persistent_cutoff)
    % Random temp so the loop does not need to call mean function calculate
    % and update each value every time
    temp = 400;
    for k = cut_off:persistent_cutoff(j)
        if(temp == 400) temp = mean(bar_position_array(cut_off:persistent_cutoff(j)));
        end
        binned_head_bar(k) = temp ;
    end
    cut_off = persistent_cutoff(j) + 1;
end


end