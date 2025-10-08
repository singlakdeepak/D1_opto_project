% Compile day 5 data from both ChR2 and controls and compare %%
clear all;
close all;
clc; 

%% load chr2 and GFP control data %%
% --- variables ---
sessions = 5; % change number of sessions to look at
mice = 4;

% --- create allSessionStats ---
chr2_allCSplusID = nan(sessions, mice);
chr2_allSessionStats = cell(1, mice);

% --- load chr2 data ---
for ii = 1:mice
    loadStimuli_allSingleMouse; % Load first mouse
    chr2_allCSplusID(:, ii) = CSplus_ID;
    chr2_allSessionStats{ii} = sessionStats;
end
chr2_allCSminusID = 3 - chr2_allCSplusID;

% --- load control data ---
for ii = 1:mice
    loadStimuli_allSingleMouse; % Load first mouse
    control_allCSplusID(:, ii) = CSplus_ID;
    control_allSessionStats{ii} = sessionStats;
end
control_allCSminusID = 3 - control_allCSplusID;

%% calculate mean and SEM of each day %%
% --- chr2 ---
chr2_mean = nan(mice, sessions);
for i = 1:mice
    for ii = 1:sessions
        if chr2_allCSplusID(ii, i) == 1
            chr2_mean(i, ii) = chr2_allSessionStats{i}{ii}.Cue_1_meanVal;
        else
            chr2_mean(i, ii) = chr2_allSessionStats{i}{ii}.Cue_2_meanVal;
        end
    end
end
chr2_groupMean = mean(chr2_mean);
chr2_groupSEM = std(chr2_mean, 0, 1, 'omitnan') ./ sqrt(mice);

% --- control ---
control_mean = nan(mice, sessions);
for i = 1:mice
    for ii = 1:sessions
        if control_allCSplusID(ii, i) == 1
            control_mean(i, ii) = control_allSessionStats{i}{ii}.Cue_1_meanVal;
        else
            control_mean(i, ii) = control_allSessionStats{i}{ii}.Cue_2_meanVal;
        end
    end
end
control_groupMean = mean(control_mean);
control_groupSEM = std(control_mean, 0, 1, 'omitnan') ./ sqrt(mice);

%% figure 4: absolute angular velocity per session per group %%
sessions = 5; 
mice = 4; 
figure(4); clf; hold on;

% --- x positions (same for both groups) ---
xDays = 1:sessions;

% --- plot individual mice points (scatter) ---
for d = 1:sessions
    scatter(repmat(xDays(d), mice, 1), chr2_mean(:, d), 50, 'b', 'filled'); % ChR2
    scatter(repmat(xDays(d), mice, 1), control_mean(:, d), 50, 'k', 'filled'); % Control
end

% --- plot mean as horizontal line + SEM as vertical line ---
halfWidth = 0.15;      % half-width of horizontal mean line
lineWidthMean = 2;      % thickness of mean line
lineWidthSEM  = 1.5;    % thickness of SEM line

halfWidth = 0.15;      % half-width of horizontal mean line
lineWidthMean = 2;      % thickness of mean line
lineWidthSEM  = 1.5;    % thickness of SEM line
capWidth = 0.08;        % half-width of the top/bottom caps

for d = 1:sessions
    % --- ChR2 ---
    % Mean line
    plot(xDays(d) + [-halfWidth halfWidth], repmat(chr2_groupMean(d), 1, 2), ...
        'Color', 'b', 'LineWidth', lineWidthMean);
    % SEM vertical line
    plot([xDays(d) xDays(d)], chr2_groupMean(d) + [-chr2_groupSEM(d) chr2_groupSEM(d)], ...
        'Color', 'b', 'LineWidth', lineWidthSEM);
    % SEM caps
    plot(xDays(d) + [-capWidth capWidth], repmat(chr2_groupMean(d)+chr2_groupSEM(d), 1, 2), 'b', 'LineWidth', lineWidthSEM); % top cap
    plot(xDays(d) + [-capWidth capWidth], repmat(chr2_groupMean(d)-chr2_groupSEM(d), 1, 2), 'b', 'LineWidth', lineWidthSEM); % bottom cap

    % --- Control ---
    % Mean line
    plot(xDays(d) + [-halfWidth halfWidth], repmat(control_groupMean(d), 1, 2), ...
        'Color', 'k', 'LineWidth', lineWidthMean);
    % SEM vertical line
    plot([xDays(d) xDays(d)], control_groupMean(d) + [-control_groupSEM(d) control_groupSEM(d)], ...
        'Color', 'k', 'LineWidth', lineWidthSEM);
    % SEM caps
    plot(xDays(d) + [-capWidth capWidth], repmat(control_groupMean(d)+control_groupSEM(d), 1, 2), 'k', 'LineWidth', lineWidthSEM); % top cap
    plot(xDays(d) + [-capWidth capWidth], repmat(control_groupMean(d)-control_groupSEM(d), 1, 2), 'k', 'LineWidth', lineWidthSEM); % bottom cap
end


% --- labels & aesthetics ---
xticks(xDays);
xticklabels(arrayfun(@(x) sprintf('day %d', x), xDays, 'UniformOutput', false));
ylabel('absolute angular velocity (rev/s)');
xlim([0 sessions+1]);

lgd = legend({sprintf('ChR2 (n = %d)', mice), ...
              sprintf('GFP control (n = %d)', mice)}, ...
              'Location','Northwest');
lgd.Box = 'off';

% --- statistics: two-way repeated measures ANOVA ---

% Assume:
% chr2_mean = [nMice x nDays] for ChR2 group
% control_mean = [nMice x nDays] for Control group
% mice = nMice per group, sessions = nDays

% Combine into one matrix
allData = [chr2_mean; control_mean];   % [nSubjects x nDays]
nSubjects = size(allData,1);

% Make group labels (categorical)
group = [repmat({'ChR2'}, mice, 1); repmat({'Control'}, mice, 1)];

% Subject IDs (important for repeated measures)
subjectID = strcat(group, "_", string((1:nSubjects)')); 

% Create a table in wide format (one column per day)
varNames = ["Subject","Group", arrayfun(@(d) sprintf("Day%d",d), 1:sessions, "UniformOutput",false)];
T = array2table([(1:nSubjects)'], 'VariableNames', {'Subject'});
T.Group = categorical(group);
for d = 1:sessions
    T.(sprintf("Day%d",d)) = allData(:,d);
end

% Define within-subject factor (Day)
within = table((1:sessions)','VariableNames',{'Day'});
within.Day = categorical(within.Day);

% Fit repeated measures model
rm = fitrm(T, sprintf('Day1-Day%d ~ Group', sessions), 'WithinDesign', within);

% Run repeated measures ANOVA
ranovatbl = ranova(rm, 'WithinModel','Day');
disp(ranovatbl);

% You can also check between-subjects effect of Group
betweenTbl = anova(rm);
disp(betweenTbl);

% --- Display anova results --- %

% Extract rows
groupRow = strcmp(ranovatbl.Row, 'Group');
dayRow   = strcmp(ranovatbl.Row, '(Intercept):Day');
interactionRow = strcmp(ranovatbl.Row, 'Group:Day');

% Extract p-values (Greenhouse-Geisser corrected for within-subjects)
p_group = ranovatbl.pValue(groupRow);
p_day   = ranovatbl.pValueGG(dayRow);         % corrected
p_inter = ranovatbl.pValueGG(interactionRow); % corrected

% Display results in console
fprintf('Group main effect: p = %.3f\n', p_group);
fprintf('Day main effect (GG corrected): p = %.3f\n', p_day);
fprintf('Group x Day interaction (GG corrected): p = %.3f\n', p_inter);

% --- title ---
hSG = sgtitle(sprintf('Group main effect: p = %.3f', p_group));
hSG.FontWeight = 'bold';
hSG.FontSize = 12;

% --- expand y-axis to fit asterisks ---
ylim([-0.005, max(ylim)*1.2]);

% --- figure aesthetics ---
SetFigBoxDefaults(10, 1.25, 1, 10);

%% Save Figures %%

% saveas(figure(4), 'figure4', 'png')