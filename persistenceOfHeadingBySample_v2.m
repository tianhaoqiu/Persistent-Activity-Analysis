function [persistenceArray] = persistenceOfHeadingBySample_v2(var_heading_threshold, bar_position_array, sampleRate, velocity_1_angular, velocity_2_X, velocity_3_Y, velocity_threshold1, velocity_threshold2, velocity_threshold3)
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
%     Input 3: sampleRate
%           the sample rate of the data set (typically ~20,000Hz for ephy
%           experiemnts)
%    
%     Input 4,5,6:velocity_1_angular, velocity_2_X, velocity_3_Y
%           Downsampled time-locked velocity in all three dimensions
%
%     Input 7,8,9:velocity_threshold1,2,3
%           Threshold to be considered as high velocity
%     
%     Output:persistenceArray
%          An array with the same length as bar_position_array where every
%          value tells you for that time point of the data set how many seconds the fly has been facing the same direction (within range of var_heading_threshold)
%
% Yvette Fisher 4/2022
% Modified by Tianhao 6/2022

%Find index of all velocity above the threshold
aboveThresholdIndex_velocity1 = find(velocity_1_angular > velocity_threshold1);
aboveThresholdIndex_velocity2 = find(abs(velocity_2_X) > velocity_threshold2);
aboveThresholdIndex_velocity3 = find(velocity_3_Y > velocity_threshold3);

persistenceArray = zeros(length(bar_position_array),1); % initiate values

for i = 2:length(bar_position_array)
    head_current = bar_position_array(i);
    
    previous_bar_postions = bar_position_array(1:i-1);
    absDiffFromCurrent = abs(previous_bar_postions - head_current); % absolute value of different from current heading

    
    aboveThresholdIndex = find(absDiffFromCurrent > var_heading_threshold);
    
    max_v1 = 0;
    max_v2 = 0;
    max_v3 = 0;
    
   
    if(isempty(find(aboveThresholdIndex_velocity1 < i)) == 0)
        max_v1 = aboveThresholdIndex_velocity1(max(find(aboveThresholdIndex_velocity1 < i)));
    end
    
    if(isempty(find(aboveThresholdIndex_velocity2 < i)) == 0)
        max_v2 = aboveThresholdIndex_velocity2(max(find(aboveThresholdIndex_velocity2 < i)));
    end
    
    if(isempty(find(aboveThresholdIndex_velocity3 < i)) == 0)
        max_v3 = aboveThresholdIndex_velocity3(max(find(aboveThresholdIndex_velocity3 < i)));
    end


    if(isempty(aboveThresholdIndex) && max([max_v1, max_v2, max_v3]) == 0)
        persistenceArray(i) = (i-1) / sampleRate;
    else
        mostRecentAboveThreshold = max(aboveThresholdIndex);
        mostRecentAboveThreshold = max([mostRecentAboveThreshold, max_v1, max_v2, max_v3]);
        persistenceArray(i) = (i - mostRecentAboveThreshold) / sampleRate;
    end
end


end