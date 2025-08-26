function probeStats = plotAngVel_final(angVel, trial_arrays, trialTypes, fs, window, doBaseline, analysisWindow)
% Plot angular velocity aligned to stim onset for different trial types
% Overlays CS+, CS-, and CS+ probe on the same plot
%
% trialTypes = {'CS+','CS-','CS+ probe'};
% trial_arrays = [CSp, CSn, CS_probe]  OR  {CSp, CSn, CS_probe}
%
% analysisWindow = [start end] in seconds (relative to onset)
%   e.g. [0.2 0.75]
%
% Returns:
%   probeStats.meanVal
%   probeStats.maxVal
%   probeStats.minVal

    preSamps  = round(window(1) * fs);
    postSamps = round(window(2) * fs);
    t = (-preSamps:postSamps) / fs;

    figure(1); clf; hold on;

    % colors: CS+ (blue), CS- (red), probe (green)
    colors = [0,0,1; ...
              1,0,0; ...
              0,1,0];

    probeStats = struct('meanVal',NaN,'maxVal',NaN,'minVal',NaN);

    % --- Plot all trial types overlayed ---
    for i = 1:3
        trialStruct = getTrialStruct(trial_arrays, i);
        [meanTrace, t] = plotTrialType(angVel, trialStruct, trialTypes{i}, fs, preSamps, postSamps, doBaseline, t, colors(i,:));

        % --- Collect stats only for probe ---
        if contains(trialTypes{i}, 'probe', 'IgnoreCase', true) && ~isempty(meanTrace)
            % Find indices for analysis window
            idxWin = t >= analysisWindow(1) & t <= analysisWindow(2);

            probeStats.meanVal = mean(meanTrace(idxWin));
            probeStats.maxVal  = max(meanTrace(idxWin));
            probeStats.minVal  = min(meanTrace(idxWin));
        end
    end

    % labels / formatting
    xlabel('time to onset (s)');
    if doBaseline
        ylabel('change in angular velocity (rev/s)');
    else
        ylabel('angular velocity (rev/s)');
    end
    title('CS+ (blue), CS- (red), probe (green)');
    ylim([-0.1 0.15]);   % fixed y-limits for all
    SetFigBoxDefaults;

end

% -------------------------
% Subfunction: safely get trial struct
% -------------------------
function s = getTrialStruct(arr, idx)
    if iscell(arr)
        s = arr{idx};
    elseif isstruct(arr)
        s = arr(idx);
    else
        error('plotAngVel_final:trial_arrays', ...
              'trial_arrays must be a cell or struct array where each element has field "onsetTime".');
    end
    if ~isfield(s, 'onsetTime')
        error('plotAngVel_final:trialStruct', 'Each trial struct must contain field ''onsetTime''.');
    end
end

% -------------------------
% Subfunction: plot mean +/- SEM for a trial type
% -------------------------
function [meanTrace, t] = plotTrialType(angVel, trialStruct, trialType, fs, preSamps, postSamps, doBaseline, t, color)
    trialTimes = trialStruct.onsetTime;
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
            traces(end+1, :) = segment; %#ok<AGROW>
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
