% Use TD161 (good chr2 mouse) to show mean angular velocity across 5 days (learning) %
clear all;
close all;
clc;

%% load chr2 data over the course of days %%
% --- load chr2 data ---
loadStimuli_allSingleMouse; % Load ChR2 data
chr2_CSplusID = CSplus_ID;
chr2_CSminusID = 3 - chr2_CSplusID;
chr2_meanTraces = meanTraces_all;
chr2_sessionStats = sessionStats;
sessions = length(chr2_meanTraces);

%% figure 1: plot mean trace over days of example %%
figure(1);

% --- create color scheme (light blue to dark blue) ---
baseColor = [0 0 1];  % pure blue
alphaVals = linspace(0.3, 1, sessions);  % Day 1 = 30% opaque,  Last Day = 100% opaque
hLines = gobjects(sessions,1);  % preallocate for legend handles

hold on;
for i = 1:sessions
    hLines(i) = plot(t, chr2_meanTraces{i}{CSplus_ID(i)}, ...
        'Color', [baseColor alphaVals(i)], 'LineWidth', 1.5);
end
hold off;

legendHandles = [hLines(1) hLines(end)];  % only show first and last day
legendLabels  = {'Day 1', sprintf('Day %d', sessions)};
lgd = legend(legendHandles, legendLabels, 'Location', 'Northeast');
lgd.Box = 'off';
xlabel('time (s)')
ylabel('mean angular velocity (rev/s)')
ylim([-0.04 0.14]);

hSG = sgtitle('example GFP control mouse CS+');
hSG.FontWeight = 'bold';  
hSG.FontSize   = 12;

% --- figure aethstics ---
SetFigBoxDefaults(10, 1.25, 1, 10);

%% Save Figure %%

saveas(figure(1), 'figure1', 'png')