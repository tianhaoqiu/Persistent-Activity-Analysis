%%
%Load heatmap matrix data
trial1_data = importdata('/Users/tianhaoqiu/Desktop/data analysis project/Heatmapdata/Persistent_Heatmap_Data_240.2.1.2_1s_bin.mat');
trial2_data = importdata('/Users/tianhaoqiu/Desktop/data analysis project/Heatmapdata/Persistent_Heatmap_Data_240.2.1.4_1s_bin.mat');
%trial3_data = importdata('/Users/tianhaoqiu/Desktop/data analysis project/Heatmapdata/Persistent_Heatmap_Data_127.3.1.5_1s_bin_truncated _for_analysis.mat');

% Number of heatmap matrix need to be averaged 
matrix_Number = 2;
if (matrix_Number == 2) 
    combined_matrix = zeros(max([size(trial1_data.Heatmap,1), size(trial2_data.Heatmap,1)]),max([size(trial1_data.Heatmap,2), size(trial2_data.Heatmap,2)]));
elseif (matrix_Number == 3) 
    combined_matrix = zeros(max([size(trial1_data.Heatmap,1), size(trial2_data.Heatmap,1),size(trial3_data.Heatmap,1)]),max([size(trial1_data.Heatmap,2), size(trial2_data.Heatmap,2),size(trial3_data.Heatmap,2)]));
end
%% 
% Number of heatmap matrix need to be averaged 
combined_matrix = combine_heatmap_matrix(combined_matrix,matrix_Number, trial1_data.Heatmap, trial2_data.Heatmap);
figure();
set(gcf, 'Color', 'w');
xvalues = {'-112','-82','-52','-22','8','38','68','98','128'};
YLabels = string(1:size(combined_matrix,1));
heatmap_obj = heatmap(xvalues, YLabels, combined_matrix);
%h = plot(heatmap_obj);
heatmap_obj.Title = 'w+; UASmCD8GFP/UASmCD8GFP; 60D05/60D05, 240.2.1.2/4';
%heatmap_obj.FontSize = 16;
ylabel('Heading persistence (1s/bin)')
xlabel('Heading in degrees')
niceaxes();
%%
%Create matrix  for Curve fitting for the persistent spike rate decat at cell's preferred
% heading from the initial heatmap matrix 

preferred_heading_spike_rate = []; 
preferred_heading_spike_time = [];
spike_threshold = 8.8;
for i = 1:size(combined_matrix,2)
    if (isnan(combined_matrix(1,i)) == 0 && combined_matrix(1,i) > spike_threshold)
        for j = 1:size(combined_matrix,1)
            if (isnan(combined_matrix(j,i))  == 0)
                preferred_heading_spike_rate = [preferred_heading_spike_rate, combined_matrix(j,i)];
                preferred_heading_spike_time = [preferred_heading_spike_time, j];
            end
        end       
    end
end

preferred_heading_spike_matrix = zeros(2, length(preferred_heading_spike_rate));

for i = 1:length(preferred_heading_spike_rate)
    preferred_heading_spike_matrix(1,i) = preferred_heading_spike_matrix(1,i) + preferred_heading_spike_rate(i);
    preferred_heading_spike_matrix(2,i) = preferred_heading_spike_matrix(2,i) + preferred_heading_spike_time(i);
end


%%
curveFitter(preferred_heading_spike_time,preferred_heading_spike_rate);
