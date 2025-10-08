function plot_sessionMean(sessionStats, analysisWindow, ax)
% plot_sessionMean
%   Plots session means for Cue1, Cue2, and Probe across days
%
% Inputs:
%   sessionStats   : cell array of stats (one per session)
%   analysisWindow : [start end] used for title annotation
%   ax             : (optional) axes handle to plot into
%
% If no axes handle is provided, makes a new figure.

    % --- initialize structures and constant variables ---
    cue1_mean = nan(1, numel(sessionStats));
    cue2_mean = nan(1, numel(sessionStats));
    probe_mean = nan(1, numel(sessionStats));
    days = 1:numel(sessionStats);

    % --- fill in mean values ---
    for i = 1:numel(sessionStats)
        cue1_mean(i)   = sessionStats{i}.Cue_1_meanVal;
        cue2_mean(i)   = sessionStats{i}.Cue_2_meanVal;
        probe_mean(i)  = sessionStats{i}.Probe_meanVal;
    end

    % --- handle axes creation ---
    if nargin < 3 || isempty(ax)
        figure;
        ax = gca;
    else
        axes(ax); 
        cla(ax);
    end
    hold(ax, 'on');

    % --- plotting ---
    h1 = plot(ax, days, cue1_mean, 'b-o', 'LineWidth', 2, 'MarkerFaceColor','b');
    h2 = plot(ax, days, cue2_mean, 'r-o', 'LineWidth', 2, 'MarkerFaceColor','r');
    h3 = plot(ax, days, probe_mean, 'g-o', 'LineWidth', 2, 'MarkerFaceColor','g');

    xlabel(ax, 'day', 'fontweight', 'bold');
    ylabel(ax, 'mean angular velocity (rev/s)', 'fontweight', 'bold');
    ax.XAxis.FontWeight = 'bold';
    ax.YAxis.FontWeight = 'bold';
    title(ax, sprintf('(%.2f to %.2f s)', analysisWindow(1), analysisWindow(2)));
    legend(ax, [h1, h2, h3], {'Cue 1', 'Cue 2', 'Probe'}, 'Location', 'southwest');
    ylim(ax, [-0.025 0.025]);

    % SetFigBoxDefaults;
    xticks(ax, 1:1:numel(sessionStats));

    hold(ax, 'off');
end
