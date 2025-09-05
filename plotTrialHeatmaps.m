function plotTrialHeatmaps(smooth_resamp_vels, trial_arrays, trialTypes, fs, window, doBaseline)
% plotTrialHeatmaps2
%   Plots trial-by-trial angular velocity aligned to cue onset.
%   Handles multiple sessions (smooth_resamp_vels is a cell array: 1 cell per session).
%
% Inputs:
%   smooth_resamp_vels : cell array of velocity vectors (1 cell per session)
%   trial_arrays       : cell array of structs with .onsetTime (s)
%   trialTypes         : labels for trial types (cell array of strings)
%   fs                 : sampling rate (Hz)
%   window             : [precue postcue] in seconds
%   doBaseline         : logical, true = subtract baseline (pre-cue mean)

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
    trialSessionIdx = [];  % Keep track of which session each trial came from
    for s = 1:nSessions
        thisSession = trials.onsetTime(s,:);
        thisSession = thisSession(~isnan(thisSession)); % drop padding
        onsetTimes  = [onsetTimes, thisSession];
        trialSessionIdx = [trialSessionIdx, repmat(s, 1, numel(thisSession))];
    end

    nTrials = numel(onsetTimes);
    nTime   = numel(timeAxis);
    trialMatrix = nan(nTrials, nTime);

    % --- Extract aligned trial data for each session separately ---
    for t = 1:nTrials
        sIdx = trialSessionIdx(t);         % session index for this trial
        velVec = smooth_resamp_vels{sIdx}; % velocity for this session

        onsetFrame = round(onsetTimes(t) * fs);
        winFrames  = round((-precue*fs : postcue*fs)) + onsetFrame;

        if winFrames(1) < 1 || winFrames(end) > numel(velVec)
            continue;
        end

        trialData = velVec(winFrames);

        % --- baseline subtraction ---
        if doBaseline
            baselineIdx = timeAxis < 0; % indices before cue
            baselineVal = mean(trialData(baselineIdx));
            trialData   = trialData - baselineVal;
        end

        trialMatrix(t,:) = trialData;
    end
    % --- After trialMatrix is built and imagesc is called ---
    figure;
    imagesc(timeAxis, 1:nTrials, trialMatrix);
    clim([-0.2 0.2]);  
    colormap(hot); 
    colorbar;
    xlabel('time (s)');
    ylabel('trial');
    title(sprintf('angular velocity: %s', trialTypes{tt}));
    xline(0,'w--','LineWidth',1.5);
    
    % --- Add session separators ---
    sessionTrialCounts = cellfun(@(r) sum(~isnan(r)), num2cell(trials.onsetTime, 2)); 
    cumulativeTrials = cumsum(sessionTrialCounts);
    for k = 1:length(cumulativeTrials)-1
        yline(cumulativeTrials(k)+0.5, 'w--', 'LineWidth', 1);
    end
    
    SetFigBoxDefaults
end
end
