

%% Analyzing and plotting each fixed heading trials
degree_of_tolerance = 30;
shortest_stopFrame = DOWN_SAMPLE_RATE*3;
[persistence_stop_index, persistence_stop_length] = find_stop_period_on_heading(velocity_angular_lowSample,degree_of_tolerance,shortest_stopFrame);
raw_voltage_lowSample = downsample(data.scaledVoltage, downSampleFactor);

figure;
plot(barPosition_lowSample);
hold on;
for i =  1:length(persistence_stop_index)
    stop_index_end =  persistence_stop_index(i);
    stop_index_start = stop_index_end - persistence_stop_length(i) + 1;
    vertices = [stop_index_start min(ylim); stop_index_start max(ylim); stop_index_end max(ylim); stop_index_end min(ylim)];
    face = [1 2 3 4];
    patch('Faces',face,'Vertices',vertices,'FaceColor','red','FaceAlpha',.3);
end
plot(barPosition_lowSample, 'b');
hold off

%%
figure;
plot(velocity_angular_lowSample);
hold on;
for i =  1:length(persistence_stop_index)
    stop_index_end =  persistence_stop_index(i);
    stop_index_start = stop_index_end - persistence_stop_length(i) + 1;
    vertices = [stop_index_start min(ylim); stop_index_start max(ylim); stop_index_end max(ylim); stop_index_end min(ylim)];
    face = [1 2 3 4];
    patch('Faces',face,'Vertices',vertices,'FaceColor','red','FaceAlpha',.3);
end
plot(velocity_angular_lowSample, 'b');
hold off
