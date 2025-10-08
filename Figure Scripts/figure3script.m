% Compile day 5 data from both ChR2 and controls and compare %%
clear all;
close all;
clc; 

%% load chr2 and GFP control data %%
% --- load chr2 data ---
loadStimuli_singleSession; % Load ChR2 data
chr2_CSplusID = CSplus_ID;
chr2_CSminusID = 3 - chr2_CSplusID;
chr2_meanTraces = meanTraces_all;
chr2_sessionStats = sessionStats;
n_chr2 = length(chr2_meanTraces);

% --- load GFP control data ---
loadStimuli_singleSession; % Load GFP data
control_CSplusID = CSplus_ID;
control_CSminusID = 3 - control_CSplusID;
control_meanTraces = meanTraces_all;
control_sessionStats = sessionStats;
n_control = length(control_meanTraces);

%% figure 1: CS+ vs CS- (mean and SEM traces) of chr2 and control %%
% --- get traces of CSplus and CSmin ---
[chr2_CSplus_mean, chr2_CSplus_sem, chr2_CSminus_mean, chr2_CSminus_sem] = ...
    computeGroupMeanSEM(chr2_meanTraces, chr2_CSplusID, chr2_CSminusID);

[control_CSplus_mean, control_CSplus_sem, control_CSminus_mean, control_CSminus_sem] = ...
    computeGroupMeanSEM(control_meanTraces, control_CSplusID, control_CSminusID);

% --- plot CS plus and CS minus --- 
figure(3);

% --- chr2 ---
subplot(1,2,1); hold on;
fill([t fliplr(t)], ... % cs plus
    [chr2_CSplus_mean + chr2_CSplus_sem, fliplr(chr2_CSplus_mean - chr2_CSplus_sem)], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
h1 = plot(t, chr2_CSplus_mean, 'Color', 'b', 'LineWidth', 1.5);

fill([t fliplr(t)], ... % cs minus
    [chr2_CSminus_mean + chr2_CSminus_sem, fliplr(chr2_CSminus_mean - chr2_CSminus_sem)], ...
     'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
h2 = plot(t, chr2_CSminus_mean, 'Color', 'r', 'LineWidth', 1.5);
hold off;
ylim([0 0.09]);
xlabel('time (s)')
lgd = legend([h1 h2], ...
             {sprintf('ChR2 CS+, (n = %d)', n_chr2), ...
              'ChR2 CS-'}, ...
             'Location', 'Northwest');
lgd.Box = 'off';
ylabel('absolute mean angular velocity (rev/s)')

% --- control ---
subplot(1,2,2); hold on;
fill([t fliplr(t)], ... % cs plus
    [control_CSplus_mean + control_CSplus_sem, fliplr(control_CSplus_mean - control_CSplus_sem)], ...
     'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
h3 = plot(t, control_CSplus_mean, 'Color', 'b', 'LineWidth', 1.5);

fill([t fliplr(t)], ... % cs minus
    [control_CSminus_mean + control_CSminus_sem, fliplr(control_CSminus_mean - control_CSminus_sem)], ...
     'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
h4 = plot(t, control_CSminus_mean, 'Color', 'r', 'LineWidth', 1.5);
hold off;

ylim([0 0.09]);
xlabel('time (s)')
lgd = legend([h3 h4], ...
             {sprintf('GFP control CS+, (n = %d)', n_control), ...
              'GFP control CS-'}, ...
             'Location', 'Northwest');
lgd.Box = 'off';

hSG = sgtitle('Day 5');
hSG.FontWeight = 'bold';  
hSG.FontSize   = 12;

% --- figure aesthetics ---
SetFigBoxDefaults(10, 1.25, 1, 10);

%% Save Figure %%

% saveas(figure(3), 'figure3', 'png')
