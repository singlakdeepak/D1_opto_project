function plotAlignedAngVelByTrialID(angVel, stimStartTrialIDs, laser_trial_onsets, ...
                                    fs, window, plotID)
% Plot angular velocity aligned to stim onset for different trial types
%
% Inputs:
%   angVel - 1D vector of angular velocity
%   stimStartTimes - containers.Map from trial type -> trial IDs
%   laser_trial_onsets - vector, where laser_trial_onsets(trialID) gives stim onset index
%   fs - sampling rate in Hz
%   window - [pre post] window in seconds

    arguments
        angVel (:,1) double
        stimStartTrialIDs containers.Map
        laser_trial_onsets (:,1) double
        fs (1,1) double {mustBePositive}
        window (1,2) double {mustBeNonnegative}
        plotID
    end

    preSamps = round(window(1) * fs);
    postSamps = round(window(2) * fs);
    t = (-preSamps:postSamps) / fs;

    figure; hold on;
    if strcmp(plotID,'all')
        keys = stimStartTrialIDs.keys;
    else
        a1 = stimStartTrialIDs.keys;
        keys = a1(plotID);
    end
    colors = lines(length(keys));

    for i = 1:length(keys)
        trialType = keys{i};
        trialIDs = stimStartTrialIDs(trialType);  % e.g., [2, 5, 11]
        traces = [];

        for j = 1:length(trialIDs)
            trialID = trialIDs(j);
            if trialID > length(laser_trial_onsets)
                continue
            end

            stimIdx = laser_trial_onsets(trialID);
            if stimIdx - preSamps >= 1 && stimIdx + postSamps <= length(angVel)
                segment = angVel(stimIdx - preSamps : stimIdx + postSamps);
                traces(end+1, :) = segment;
            end
        end

        % Plot mean ± SEM
        if ~isempty(traces)
            meanTrace = mean(traces, 1);
            semTrace = std(traces, 0, 1) / sqrt(size(traces,1));

            fill([t fliplr(t)], ...
                 [meanTrace + semTrace, fliplr(meanTrace - semTrace)], ...
                 colors(i,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            plot(t, meanTrace, 'Color', colors(i,:), 'LineWidth', 1);
        end
    end

    xlabel('time from stim onset (s)');
    ylabel('angular velocity');
    if ~strcmp(plotID,'all')
        a1 = keys{1};
        title(['Stim Frequency (Hz), Duration (s): ',a1]);
    end
    % title('Angular velocity aligned to stim onset by trial type');
    legend(keys, 'Location', 'best');
    SetFigBoxDefaults
    exportgraphics(gcf, [a1,'.jpg'], 'Resolution', 300);

end
