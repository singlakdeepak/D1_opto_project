function plotTempActivity(angVel, trial_arrays, trialTypes, fs, bin_size, window)
    figure();

    % Define colors for each trialType
    colors = [1,0,0;    % red
              0,1,0;    % green
              0,1,1];   % blue

    startidx = round(window(1) * fs); % starting window of focus
    endidx = round(window(2) * fs);   % ending window of focus
    ntypes = length(trialTypes);
    
    for i = 1:ntypes
        subplot(1, ntypes, i); hold on;
        trialType = trialTypes{i};
        trialTimes = trial_arrays(i); % Cue onset time
        trialTimes = trialTimes.onsetTime;

        totalVels = [];
        for j = 1:(length(trialTimes)/bin_size)
            vels = [];
            for k = 1*j:bin_size*j
                trial_onset = round(trialTimes(k)*fs);
                vels(k) = mean(angVel(startidx + trial_onset : endidx + trial_onset));
            end
            totalVels(j) = mean(vels);
        end

        % assign color by trial type index
        thisColor = colors(i,:);

        x = i*ones(1, length(totalVels));
        scatter(x, totalVels, 36, thisColor, 'filled')  % 36 = marker size

        meanVel = mean(totalVels);
        scatter(i, meanVel, 120, thisColor, 'd', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5)        
        title(trialType)
        SetFigBoxDefaults;
        ylabel('angular vel')
        ylim([0 0.5])
    end
    hold off;

    % Add big title showing window
    sgtitle(sprintf('window of interest: %.2f s to %.2f s', window(1), window(2)));
end
