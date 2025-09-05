function sessionStats = plotAngVel_finalAll(angVel_all, trial_arrays, trialTypes, fs, window, doBaseline, analysisWindow)
% plotAngVel_finalAll_multi
%   Plots angular velocity aligned to stim onset for different trial types
%   Handles multiple sessions: angVel_all is a cell array (1 cell per session)
%
% Inputs:
%   angVel_all       : cell array of angular velocity vectors (1 per session)
%   trial_arrays_all : cell array of trial_arrays (1 per session)
%   trialTypes       : labels for trial types (e.g. {'Cue1','Cue2','Cue_probe'})
%   fs               : sampling rate (Hz)
%   window           : [precue postcue] in seconds
%   doBaseline       : logical, subtract baseline if true
%
% Note: One figure per session. Within each figure:
%       Cue1 = blue, Cue2 = red, Probe = green

    preSamps  = round(window(1) * fs);
    postSamps = round(window(2) * fs);
    t = (-preSamps:postSamps) / fs;

    colors = [0,0,1; ...
              1,0,0; ...
              0,1,0]; % cue1, cue2, probe

    nSessions = numel(angVel_all);
    sessionStats = cell(1, nSessions); % create sessionStats which each cell holds a session of data
    
    idxWin = t >= analysisWindow(1) & t <= analysisWindow(2);

    % loop over all sessions
    for s = 1:nSessions
        angVel = angVel_all{s};

        figure; clf; hold on;

        sessionStats{s} = struct();

        % loop over trial types Cue 1, Cue 2, and Probe
        for i = 1:numel(trialTypes)
            [meanTrace, t] = plotTrialType(angVel, trial_arrays{i}, trialTypes{i}, fs, preSamps, postSamps, doBaseline, t, colors(i,:), s);

            % If no valid trials, fill with NaN
            if isempty(meanTrace)
                meanVal = NaN; maxVal = NaN; minVal = NaN;
            else
                meanVal = mean(meanTrace(idxWin));
                maxVal  = max(meanTrace(idxWin));
                minVal  = min(meanTrace(idxWin));
            end

            % Build field names dynamically
            baseName = strrep(trialTypes{i}, ' ', '_');
            sessionStats{s}.([baseName '_meanVal']) = meanVal;
            sessionStats{s}.([baseName '_maxVal'])  = maxVal;
            sessionStats{s}.([baseName '_minVal'])  = minVal;
        end

        % labels / formatting
        xlabel('time to onset (s)');
        if doBaseline
            ylabel('change in angular velocity (rev/s)');
        else
            ylabel('angular velocity (rev/s)');
        end
        title(sprintf('Session %d: cue1 (blue), cue2 (red), probe (green)', s));
        ylim([-0.1 0.15]);
        xline(0,'k--','LineWidth',1);
        SetFigBoxDefaults;
    end
end

% -------------------------
% Subfunction: plot mean +/- SEM for a trial type
% -------------------------
function [meanTrace, t] = plotTrialType(angVel, trial_arrays, trialType, fs, preSamps, postSamps, doBaseline, t, color, s)
    trialTimes = trial_arrays.onsetTime(s,:);
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
    if ~isempty(traces)
        meanTrace = mean(traces, 1);
        semTrace  = std(traces, 0, 1) / sqrt(size(traces,1));

        fill([t fliplr(t)], [meanTrace + semTrace, fliplr(meanTrace - semTrace)], ...
             color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        plot(t, meanTrace, 'Color', color, 'LineWidth', 1.5);
    end
end
