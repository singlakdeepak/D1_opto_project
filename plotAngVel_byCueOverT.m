function plotAngVel_byCueOverT(angVel, trial_arrays,...
                trialTypes, fs, cue_to_laser_time,combineN)

    preSamps = 0;
    postSamps = round(cue_to_laser_time * fs);
    nosqr = 1;
    figure(2); 
    clf(2);
    hold on;

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
                
                traces(end+1, :) = segment;
            end
        end

        % Plot mean ± SEM
        if ~isempty(traces)
            meanTraceByTrial = mean(traces, 2)';
            % Make sure length is multiple of 5
            nti = numel(meanTraceByTrial);
            data = meanTraceByTrial(1:floor(nti/combineN)*combineN); % trim if needed
            
            % Reshape so each column has 5 numbers
            reshaped_data = reshape(data, combineN, []);
            
            % Take mean of each column
            meanTraceByTrial = mean(reshaped_data, 1);

            semTrace = std(reshaped_data, [], 1)/ sqrt(combineN);
            samps = 1:length(meanTraceByTrial);
            fill([samps fliplr(samps)], ...
                 [meanTraceByTrial + semTrace, fliplr(meanTraceByTrial - semTrace)], ...
                 colors(i,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            hold on;
            plot(samps, meanTraceByTrial, 'Color', colors(i,:), 'LineWidth', 1);
        end
        xlabel([ trialType, ' trial #']);
        ylabel('angular velocity');
        
        % if ~strcmp(plotID,'all')
        %     a1 = keys{1};
        %     title(['Stim Frequency (Hz), Duration (s): ',a1]);
        % end
        title(['angular velocity from 1st to last trial of cue (0-', ...
                num2str(cue_to_laser_time), 's)']);
        SetFigBoxDefaults
    end

end