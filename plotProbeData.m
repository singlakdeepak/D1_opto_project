clear all;
close all;
clc; 

%% TD154 data
mean1 = [-0.0081648, -0.012791, -0.015346, -0.014557, -0.027026, 0.0014098, -0.0029423, -0.007067, -0.0053801, -0.024778];
max1  = [0.00468, 0.0010162, 0.0054669, 0.013812, 0.0095074, 0.014332, 0.023203, 0.044513, 0.0274, 0.034967];
min1  = [-0.028989, -0.045408, -0.050223, -0.055668, -0.085605, -0.012924, -0.025659, -0.057995, -0.032793, -0.023314];

days = 1:length(mean1);

mean = mean1(:)'; 
max  = max1(:)'; 
min  = min1(:)'; 
days = days(:)';

figure; hold on;

% mean
scatter(days, mean, 80, 'b', 'filled');
h_mean = plot(days, mean, 'b-', 'LineWidth', 2);

% max
scatter(days, max, 80, 'g', 'filled');
h_max = plot(days, max, 'g-', 'LineWidth', 2);

% min
scatter(days, min, 80, 'r', 'filled');
h_min = plot(days, min, 'r-', 'LineWidth', 2);

h_reverse = xline(5.5,'k--','LineWidth',1.5);
h_trace = xline(7.5,'k-.','LineWidth',1.5);

xlabel('day');
ylabel('angular velocity');
legend([h_max, h_mean, h_min, h_reverse, h_trace], {'max', 'mean', 'min', 'reverse', 'trace'}, 'Location', 'southwest')
title('TD154 probe (0 to 1s)')
SetFigBoxDefaults;

%% TD156 data
mean2 = [-4.2452e-09, -0.0022693, -0.0014784, -0.0066969, -0.011882, -0.0064348, -0.0012733, -0.00054449, -0.0027113, -0.0029481];
max2  = [5.6757e-07, 0.0070748, 0.017557, 0.017062, 0.0087232, 0.0086896, 0.0056006, 0.0085419, 0.008217, 0.016102];
min2  = [-7.0367e-07, -0.012734, -0.0134, -0.031151, -0.034393, -0.03194, -0.0075394, -0.0099478, -0.018919, -0.024778];

days = 1:length(mean2);

mean = mean2(:)'; 
max  = max2(:)'; 
min  = min2(:)'; 
days = days(:)';

figure; hold on;

scatter(days, mean, 80, 'b', 'filled');
h_mean = plot(days, mean, 'b-', 'LineWidth', 2);

scatter(days, max, 80, 'g', 'filled');
h_max = plot(days, max, 'g-', 'LineWidth', 2);

scatter(days, min, 80, 'r', 'filled');
h_min = plot(days, min, 'r-', 'LineWidth', 2);

h_reverse = xline(6.5,'k--','LineWidth',1.5);
h_trace = xline(7.5,'k-.','LineWidth',1.5);

xlabel('day');
ylabel('angular velocity');
legend([h_max, h_mean, h_min, h_reverse, h_trace], {'max', 'mean', 'min', 'reverse', 'trace'}, 'Location', 'southwest')
title('TD156 probe (0 to 1s)')
SetFigBoxDefaults;

%% --- Save figures --- 
doSave = 1;
if doSave
    saveas(figure(1), 'TD154_probes.png')
    saveas(figure(2), 'TD156_probes.png')
end

