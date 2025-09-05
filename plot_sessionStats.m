function plot_sessionStats(sessionStats, analysisWindow)

    % --- initialize structures and constant variables ---
    cue1 = struct('mean', [], 'max', [], 'min', []);
    cue2 = struct('mean', [], 'max', [], 'min', []);
    probe = struct('mean', [], 'max', [], 'min', []);
    days = 1:numel(sessionStats);

    % --- fill in structures ---
    for i = 1:numel(sessionStats)
        cue1.mean(i) = sessionStats{i}.Cue_1_meanVal;
        cue1.max(i)  = sessionStats{i}.Cue_1_maxVal;
        cue1.min(i)  = sessionStats{i}.Cue_1_minVal;

        cue2.mean(i) = sessionStats{i}.Cue_2_meanVal;
        cue2.max(i)  = sessionStats{i}.Cue_2_maxVal;
        cue2.min(i)  = sessionStats{i}.Cue_2_minVal;

        probe.mean(i) = sessionStats{i}.Probe_meanVal;
        probe.max(i)  = sessionStats{i}.Probe_maxVal;
        probe.min(i)  = sessionStats{i}.Probe_minVal;
    end

    % --- create a map of trial types to their structs and colors ---
    trialMap = {
        'Cue 1', cue1;
        'Cue 2', cue2;
        'Probe', probe
    };

    % --- plotting ---
    for i = 1:size(trialMap,1)
        trialName = trialMap{i,1};
        trialData = trialMap{i,2};

        figure; hold on;

        % plot mean, max, min
        h_mean = plot(days, trialData.mean, 'b-o', 'LineWidth', 2, 'MarkerFaceColor','b');
        h_max  = plot(days, trialData.max,  'g-o', 'LineWidth', 2, 'MarkerFaceColor','g');
        h_min  = plot(days, trialData.min,  'r-o', 'LineWidth', 2, 'MarkerFaceColor','r');

        xlabel('day');
        ylabel('angular velocity');
        title(sprintf('%s (%.2f to %.2f s)', trialName, analysisWindow(1), analysisWindow(2)));
        legend([h_max, h_mean, h_min], {'max', 'mean', 'min'}, 'Location', 'southwest');

        SetFigBoxDefaults;
        hold off;
    end
end
