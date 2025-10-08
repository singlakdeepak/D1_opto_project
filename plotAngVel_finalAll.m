function [sessionStats, meanTraces_all, t] = plotAngVel_finalAll(doAbs, angVel_all, trial_arrays, trialTypes, fs, window, doBaseline, analysisWindow, ax)
% plotAngVel_finalAll
%   Plots angular velocity aligned to stim onset for different trial types
%   Handles multiple sessions: angVel_all is a cell array (1 cell per session)
%
% Inputs:
%   angVel_all       : cell array of angular velocity vectors (1 per session)
%   trial_arrays     : cell array of trial_arrays (1 per session)
%   trialTypes       : labels for trial types (e.g. {'Cue1','Cue2','Cue_probe'})
%   fs               : sampling rate (Hz)
%   window           : [precue postcue] in seconds
%   doBaseline       : logical, subtract baseline if true
%   analysisWindow   : [start end] for computing stats
%   ax               : (optional) axes handle to plot into
%
% Note: One figure per session if no axes are provided.
%       Cue1 = blue, Cue2 = red, Probe = green

    preSamps  = round(window(1) * fs);
    postSamps = round(window(2) * fs);
    t = (-preSamps:postSamps) / fs;

    colors = [0,0,1; ...
              1,0,0; ...
              0,1,0]; % cue1, cue2, probe

    nSessions = numel(angVel_all);
    sessionStats = cell(1, nSessions); 
    meanTraces_all = cell(1, nSessions);
    
    idxWin = t >= analysisWindow(1) & t <= analysisWindow(2);

    % loop over all sessions
    for s = 1:nSessions
        angVel = angVel_all{s};

        % --- handle axes/figure creation ---
        if nargin < 9 || isempty(ax)
            figure; clf;
            ax_sess = gca;
        else
            if numel(ax) >= nSessions
                ax_sess = ax(s); % allow array of axes handles
                axes(ax_sess); 
                cla(ax_sess);
            else
                error('Not enough axes handles provided for number of sessions.');
            end
        end
        hold(ax_sess, 'on');

        sessionStats{s} = struct();
        meanTraces = cell(1, numel(trialTypes));

        % loop over trial types Cue 1, Cue 2, and Probe
        h = gobjects(1,numel(trialTypes));
        for i = 1:numel(trialTypes)
            [meanTrace, t, h(i)] = plotTrialType(ax_sess, angVel, trial_arrays{i}, trialTypes{i}, ...
                                                 fs, preSamps, postSamps, doBaseline, t, colors(i,:), s);

            meanTraces{i} = meanTrace;

            % If no valid trials, fill with NaN
            if isempty(meanTrace)
                meanVal = NaN; maxVal = NaN; minVal = NaN;
            else
                if doAbs
                    meanVal = mean(abs(meanTrace(idxWin)));
                    maxVal  = max(abs(meanTrace(idxWin)));
                    minVal  = min(abs(meanTrace(idxWin)));
                else
                    meanVal = mean(meanTrace(idxWin));
                    maxVal  = max(meanTrace(idxWin));
                    minVal  = min(meanTrace(idxWin));
                end
            end

            % Build field names dynamically
            baseName = strrep(trialTypes{i}, ' ', '_');
            sessionStats{s}.([baseName '_meanVal']) = meanVal;
            sessionStats{s}.([baseName '_maxVal'])  = maxVal;
            sessionStats{s}.([baseName '_minVal'])  = minVal;
        end
        meanTraces_all{s} = meanTraces;

        % labels / formatting
        xlabel(ax_sess, 'time from cue onset (s)');
        if doBaseline
            ylabel(ax_sess, '(Δ mean angular velocity (rev/s)', 'fontweight', 'bold');
        else
            ylabel(ax_sess, 'mean angular velocity (rev/s)', 'fontweight', 'bold');
        end
        ax_sess.XAxis.FontWeight = 'bold';
        ax_sess.YAxis.FontWeight = 'bold';
        legend(ax_sess, h, trialTypes, 'Location', 'Southwest');
        title(ax_sess, sprintf('Session %d', s));
        ylim(ax_sess, [-0.1 0.15]);
        % xline(ax_sess, 0,'k--','LineWidth',1);
        % SetFigBoxDefaults;
    end
end

% -------------------------
% Subfunction: plot mean +/- SEM for a trial type
% -------------------------
function [meanTrace, t, h] = plotTrialType(ax, angVel, trial_arrays, trialTypes, fs, preSamps, postSamps, doBaseline, t, color, s)
    trialTimes = trial_arrays.onsetTime(s,:); % assuming structure layout
    trialidx_onset = round(trialTimes * fs);
    traces = [];

    for j = 1:length(trialidx_onset)
        trialidx = trialidx_onset(j);
        if trialidx - preSamps >= 1 && trialidx + postSamps <= length(angVel)
            segment = angVel(trialidx - preSamps : trialidx + postSamps);
            if doBaseline
                baseline = mean(angVel(trialidx - preSamps : trialidx));
                segment = segment - baseline;
            end
            traces(end+1, :) = segment;
        end
    end

    meanTrace = [];
    h = [];
    if ~isempty(traces)
        meanTrace = mean(traces, 1);
        semTrace  = std(traces, 0, 1) / sqrt(size(traces,1));

        fill(ax, [t fliplr(t)], [meanTrace + semTrace, fliplr(meanTrace - semTrace)], ...
             color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        h = plot(ax, t, meanTrace, 'Color', color, 'LineWidth', 1.5);
    end
end
