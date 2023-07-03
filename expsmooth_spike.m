function [ smoothed_array ] = expsmooth_spike(input_array, fs, tau )
% EXPSMOOTH Exponential smoothing. 
%   Everthing in ms unit
%   Tianhao Qiu, 2.2023.
    
    T = 1E3/fs;
    % calculate alpha of exponential window based on sample interval and
    % time constant
    alpha = 1-exp( -T/tau );
    % filtering the input data
    smoothed_array =  filtfilt(alpha, [1 alpha- 1],input_array);
  
   
end
% EOF 
