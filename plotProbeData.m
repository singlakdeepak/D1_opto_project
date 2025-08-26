%% TD154 data
% --- plots probe mean, max, and min over days ---
mean1 = [-0.0070, -0.0074, -0.0235, -0.0146, -0.0379];
max1 = [7.8337e-04, 0.0010, 0.0053, 0.0054, 0.0012];
min1 = [-0.0165, -0.0408, -0.0502, -0.0409, -0.0856];

days = 1:5;

% force all into row vectors
mean = mean1(:)'; 
max  = max1(:)'; 
min  = min1(:)'; 
days  = days(:)';

figure; hold on;

% scatter + fit line for mean
scatter(days, mean, 80, 'b', 'filled');
p_mean = polyfit(days, mean, 1); % linear fit
yfit_mean = polyval(p_mean, days);
h_mean = plot(days, yfit_mean, 'b-', 'LineWidth', 2);

% scatter + fit line for max
scatter(days, max, 80, 'g', 'filled');
p_max = polyfit(days, max, 1);
yfit_max = polyval(p_max, days);
h_max = plot(days, yfit_max, 'g-', 'LineWidth', 2);

% scatter + fit line for min
scatter(days, min, 80, 'r', 'filled');
p_min = polyfit(days, min, 1);
yfit_min = polyval(p_min, days);
h_min = plot(days, yfit_min, 'r-', 'LineWidth', 2);

xlabel('day');
ylabel('angular velocity');
legend([h_max, h_mean, h_min], {'max', 'mean', 'min'}, 'Location', 'southwest')
title('TD154')
SetFigBoxDefaults;

%% TD155 data
% --- plots probe mean, max, and min over days ---
mean2 = [9.1022e-10, -2.4193e-04, -0.0022, -0.0086, -0.0120];
max2 = [4.9060e-08, 0.0071, 0.0176, 0.0096, 0.0087];
min2 = [-2.0960e-08, -0.0081, -0.0134, -0.0246, -0.0323];

days = 1:5;

% force all into row vectors
mean = mean2(:)'; 
max  = max2(:)'; 
min  = min2(:)'; 
days  = days(:)';

figure; hold on;

% scatter + fit line for mean
scatter(days, mean, 80, 'b', 'filled');
p_mean = polyfit(days, mean, 1); % linear fit
yfit_mean = polyval(p_mean, days);
h_mean = plot(days, yfit_mean, 'b-', 'LineWidth', 2);

% scatter + fit line for max
scatter(days, max, 80, 'g', 'filled');
p_max = polyfit(days, max, 1);
yfit_max = polyval(p_max, days);
h_max = plot(days, yfit_max, 'g-', 'LineWidth', 2);

% scatter + fit line for min
scatter(days, min, 80, 'r', 'filled');
p_min = polyfit(days, min, 1);
yfit_min = polyval(p_min, days);
h_min = plot(days, yfit_min, 'r-', 'LineWidth', 2);

xlabel('day');
ylabel('angular velocity');
legend([h_max, h_mean, h_min], {'max', 'mean', 'min'}, 'Location', 'southwest')
title('TD156')
SetFigBoxDefaults;