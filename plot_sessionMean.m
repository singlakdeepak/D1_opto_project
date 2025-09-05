function plot_sessionMean(sessionStats, analysisWindow)

    % --- initialize structures and constant variables ---
    cue1_mean = nan(1, numel(sessionStats));
    cue2_mean = nan(1, numel(sessionStats));
    probe_mean = nan(1, numel(sessionStats));
    days = 1:numel(sessionStats);

    % --- fill in mean values ---
    for i = 1:numel(sessionStats)
        cue1_mean(i) = sessionStats{i}.Cue_1_meanVal;
        cue2_mean(i) = sessionStats{i}.Cue_2_meanVal;
        probe_mean(i) = sessionStats{i}.Probe_meanVal;

    end

    % --- plotting ---
    figure; hold on;

    % plot mean, max, min
    h1 = plot(days, cue1_mean, 'b-o', 'LineWidth', 2, 'MarkerFaceColor','b');
    h2  = plot(days, cue2_mean,  'r-o', 'LineWidth', 2, 'MarkerFaceColor','r');
    h3  = plot(days, probe_mean,  'g-o', 'LineWidth', 2, 'MarkerFaceColor','g');

    xlabel('day');
    ylabel('angular velocity');
    title(sprintf('mean angular velocity (%.2f to %.2f s)', analysisWindow(1), analysisWindow(2)));
    legend([h1, h2, h3], {'Cue 1', 'Cue 2', 'Probe'}, 'Location', 'southwest');

    SetFigBoxDefaults;
    hold off;
end
