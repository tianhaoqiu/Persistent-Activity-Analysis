function [persistent_cutoff] = persistent_heading(var_heading_threshold, bar_position_array)
%Preprocessing the bar position/heading data by binning the position with
%slight change as a better estimation of prolonged heading position of fly
%     Input 1: var_heading_threshold
%          Threshold of variability in heading that can be manually determined depending on how much
%          variation in heading direction could be tolorated and be considered
%          as persistent heading direction 
%      
%     Input 2: bar_position_array
%          The bar_position array that have been corrected from frame shift
%     
%     Output:binned_head_bar
%          Processed heading/bar position array like a step function
%     3/23/2022 Tianhao Qiu

k = 1;
persistent_cutoff = [];
for i = 2:length(bar_position_array)
    head_current = bar_position_array(i);
    for j = 1:i-k
        diff = head_current - bar_position_array(i - j);
        
        if (diff > var_heading_threshold)
            persistent_cutoff = [persistent_cutoff; i]; 
            k = i;
            break
        end        
    end
end


end