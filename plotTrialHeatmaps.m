function plotTrialHeatmaps(smooth_resamp_vels, trial_arrays, trialTypes, fs, window)
% plotTrialHeatmaps
%   Plots trial-by-trial angular velocity aligned to cue onset.
%
% Inputs:
%   smooth_resamp_vels : resampled angular velocity (vector)
%   trial_arrays       : cell array of structs with .onsetTime (s)
%   trialTypes         : labels for trial types (cell array of strings)
%   fs                 : sampling rate (Hz)
%   window             : [precue postcue] in seconds
%
% Example:
%   plotTrialHeatmaps(smooth_resamp_vels, {Cue1, Cue2}, ...
%                     {'Cue1','Cue2'}, fs, [1 5]);

    precue  = window(1);
    postcue = window(2);
    timeAxis = -precue : 1/fs : postcue;

    for tt = 1:numel(trial_arrays)
        trials = trial_arrays{tt};

        if ~isfield(trials,'onsetTime') || isempty(trials.onsetTime)
            fprintf('No trials for %s\n', trialTypes{tt});
            continue;
        end

        nTrials = numel(trials.onsetTime);
        nTime   = numel(timeAxis);
        trialMatrix = nan(nTrials, nTime);

        for t = 1:nTrials
            onsetFrame = round(trials.onsetTime(t) * fs);
            winFrames  = round((-precue*fs : postcue*fs)) + onsetFrame;

            if winFrames(1) < 1 || winFrames(end) > numel(smooth_resamp_vels)
                continue;
            end

            trialMatrix(t,:) = smooth_resamp_vels(winFrames);
        end

        figure;
        imagesc(timeAxis, 1:nTrials, trialMatrix);
        colormap(jet); colorbar;
        xlabel('time (s)');
        ylabel('trial');
        title(sprintf('angular velocity: %s', trialTypes{tt}));
        xline(0,'w--','LineWidth',1.5);
        SetFigBoxDefaults
    end
end
