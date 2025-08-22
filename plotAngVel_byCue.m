function plotAngVel_byCue(angVel, trial_arrays,...
                trialTypes, fs, window, doBaseline)
% Plot angular velocity aligned to stim onset for different trial types
%
% Inputs:
%   angVel - 1D vector of angular velocity
%   laser_trial_times - vector, where laser_trial_onsets(trialID) gives
%   stim onset time
%   fs - sampling rate in Hz
%   window - [pre post] window in seconds
%   doBaseline - true or false boolean to apply baseline subtraction based
%   on preSamps (typically -1s to 0s is baseline)

    preSamps = round(window(1) * fs);
    postSamps = round(window(2) * fs);
    t = (-preSamps:postSamps) / fs;
    nosqr = 1;
    figure(1); hold on;

    colors = [1,0,0;...
              0,0,0;...
              0,1,0];
    ntypes = length(trialTypes);

    for i = 1:ntypes
        subplot(ntypes,1,i);
        trialType = trialTypes{i};
        trialTimes = trial_arrays(i);
        trialTimes = trialTimes.onsetTime;

        trialidx_onset = round(trialTimes*fs);
        
        traces = [];

        for j = 1:length(trialidx_onset)
            trialidx = trialidx_onset(j);
           
            if trialidx - preSamps >= 1 && trialidx + postSamps <= length(angVel)
                segment = angVel(trialidx - preSamps : trialidx + postSamps);

                % --- Baseline subtraction: mean from -1s to 0s ---
                if doBaseline
                    baseline_start = trialidx - preSamps;
                    baseline_end   = trialidx;
                    baseline = mean(angVel(baseline_start:baseline_end));
                    segment = segment - baseline;
                end
                % -------------------------------------------------

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
            hold on;
            plot(t, meanTrace, 'Color', colors(i,:), 'LineWidth', 1);
        end
        xlabel(['time to ', trialType, ' onset (s)']);
        if doBaseline
            ylabel('change in angular velocity (rev/s)');
        else
            ylabel('angular velocity (rev/s)');
        end
        % if ~strcmp(plotID,'all')
        %     a1 = keys{1};
        %     title(['Stim Frequency (Hz), Duration (s): ',a1]);
        % end
        SetFigBoxDefaults
    end

    
    % title('Angular velocity aligned to stim onset by trial type');
    % legend(keys, 'Location', 'best');
    
    % exportgraphics(gcf, [a1,'.jpg'], 'Resolution', 300);

end
