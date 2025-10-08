function plotTrialHeatmaps(smooth_resamp_vels, trial_arrays, trialTypes, fs, window, doBaseline, ax)
% plotTrialHeatmaps
%   Plots trial-by-trial angular velocity aligned to cue onset.
%   Optional axes handle for subplot-friendly plotting.

precue  = window(1);
postcue = window(2);
timeAxis = -precue : 1/fs : postcue;

nSessions = numel(smooth_resamp_vels);

for tt = 1:numel(trial_arrays)
    trials = trial_arrays{tt};

    if ~isfield(trials,'onsetTime') || isempty(trials.onsetTime)
        fprintf('No trials for %s\n', trialTypes{tt});
        continue;
    end

    % --- Concatenate trials across sessions in order ---
    onsetTimes = [];
    trialSessionIdx = [];  
    for s = 1:nSessions
        thisSession = trials.onsetTime(s,:);
        thisSession = thisSession(~isnan(thisSession));
        onsetTimes  = [onsetTimes, thisSession];
        trialSessionIdx = [trialSessionIdx, repmat(s, 1, numel(thisSession))];
    end

    nTrials = numel(onsetTimes);
    nTime   = numel(timeAxis);
    trialMatrix = nan(nTrials, nTime);

    % --- Extract aligned trial data ---
    for t = 1:nTrials
        sIdx = trialSessionIdx(t);
        velVec = smooth_resamp_vels{sIdx};

        onsetFrame = round(onsetTimes(t) * fs);
        winFrames  = round((-precue*fs : postcue*fs)) + onsetFrame;

        if winFrames(1) < 1 || winFrames(end) > numel(velVec)
            continue;
        end

        trialData = velVec(winFrames);

        if doBaseline
            baselineIdx = timeAxis < 0;
            baselineVal = mean(trialData(baselineIdx));
            trialData   = trialData - baselineVal;
        end

        trialMatrix(t,:) = trialData;
    end

    % --- handle axes creation ---
    if nargin < 7 || isempty(ax)
        figure;
        ax_tt = gca;
    else
        if numel(ax) >= tt
            ax_tt = ax(tt); 
            axes(ax_tt); %#ok<LAXES>
            cla(ax_tt);
        else
            error('Not enough axes handles provided for number of trial types.');
        end
    end

    % --- plotting ---
    imagesc(ax_tt, timeAxis, 1:nTrials, trialMatrix);
    clim(ax_tt, [-0.2 0.2]);  
    colormap(ax_tt, hot); 
    colorbar(ax_tt, 'fontweight', 'bold');
    xlabel(ax_tt, 'time (s)', 'fontweight', 'bold');
    ylabel(ax_tt, 'trial', 'fontweight', 'bold');
    ax_tt.XAxis.FontWeight = 'bold';
    ax_tt.YAxis.FontWeight = 'bold';
    title(ax_tt, sprintf('angular velocity: %s', trialTypes{tt}));
    xline(ax_tt, 0,'w--','LineWidth',1.5);

    % --- Add session separators ---
    sessionTrialCounts = cellfun(@(r) sum(~isnan(r)), num2cell(trials.onsetTime, 2)); 
    cumulativeTrials = cumsum(sessionTrialCounts);
    for k = 1:length(cumulativeTrials)-1
        yline(ax_tt, cumulativeTrials(k)+0.5, 'w--', 'LineWidth', 1);
    end

    % SetFigBoxDefaults
end
end
