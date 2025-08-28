%% TD154 data
mean1 = [-0.0070, -0.0074, -0.0235, -0.0146, -0.0379, 0.0012, -0.0060];
max1  = [7.8337e-04, 0.0010, 0.0053, 0.0054, 0.0012, 0.0088, 0.0108];
min1  = [-0.0165, -0.0408, -0.0502, -0.0409, -0.0856, -0.0068, -0.0257];

days = 1:7;

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

xlabel('day');
ylabel('angular velocity');
legend([h_max, h_mean, h_min, h_reverse], {'max', 'mean', 'min', 'reverse'}, 'Location', 'southwest')
title('TD154')
SetFigBoxDefaults;

%% TD156 data
mean2 = [9.1022e-10, -2.4193e-04, -0.0022, -0.0086, -0.0120, -0.0084, -5.7708e-04];
max2  = [4.9060e-08, 0.0071, 0.0176, 0.0096, 0.0087, 0.0087, 0.0056];
min2  = [-2.0960e-08, -0.0081, -0.0134, -0.0246, -0.0323, -0.0319, -0.0075];

days = 1:7;

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

xlabel('day');
ylabel('angular velocity');
legend([h_max, h_mean, h_min, h_reverse], {'max', 'mean', 'min', 'reverse'}, 'Location', 'southwest')
title('TD156')
SetFigBoxDefaults;

%% --- Save figures --- 
doSave = 1;
if doSave
    saveas(figure(1), 'TD154_probes.png')
    saveas(figure(2), 'TD156_probes.png')
end