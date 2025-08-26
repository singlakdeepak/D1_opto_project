function plotAngVel_byLaser(angVel, laser_trial_times, fs, window)
% Plot angular velocity aligned to start of each laser train
%
% angVel            vector of angular velocity (samples)
% laser_trial_times times (in seconds) of first pulse of each train
% fs                sampling frequency of angVel
% window            [pre post] window in seconds

    preSamps  = round(window(1) * fs);
    postSamps = round(window(2) * fs);

    traces = [];
    for j = 1:length(laser_trial_times)
        trialIdx = round(laser_trial_times(j) * fs);  % convert seconds → sample index
        
        if trialIdx - preSamps >= 1 && trialIdx + postSamps <= length(angVel)
            segment = angVel(trialIdx - preSamps : trialIdx + postSamps);
            traces(end+1, :) = segment; %#ok<AGROW>
        end
    end

    % Plot mean ± SEM
    figure; hold on;
    if ~isempty(traces)
        meanTrace = mean(traces, 1);
        semTrace  = std(traces, [], 1) / sqrt(size(traces,1));
        samps = (-preSamps:postSamps) / fs;  % convert to seconds axis

        fill([samps fliplr(samps)], ...
             [meanTrace + semTrace, fliplr(meanTrace - semTrace)], ...
             [0.2 0.2 1], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        plot(samps, meanTrace, 'k', 'LineWidth', 1.5);
    end
    
    xlabel('time (s)');
    ylabel('angular velocity (mm/s)');
    SetFigBoxDefaults;
end
