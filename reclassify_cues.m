function [new_cue1, new_cue2, cue_probe, CSplus_ID] = ...
         reclassify_cues(cue1, cue2, laser_times)
% Multi-session reclassification with numeric outputs
% Minimal NaN padding for probe trials

tol = 0.02; % 10 ms tolerance
nSessions = size(cue1.onsetTime, 1);

% Precompute max trials for cue1/cue2
maxTrials_cue1 = size(cue1.onsetTime, 2);
maxTrials_cue2 = size(cue2.onsetTime, 2);

% Temporary storage for probe trials to compute max later
probeTimes = cell(nSessions,1);
probeIDs   = cell(nSessions,1);

new_cue1.onsetTime = nan(nSessions, maxTrials_cue1);
new_cue1.onsetID   = nan(nSessions, maxTrials_cue1);
new_cue2.onsetTime = nan(nSessions, maxTrials_cue2);
new_cue2.onsetID   = nan(nSessions, maxTrials_cue2);
CSplus_ID = nan(nSessions,1);

for s = 1:nSessions
    thisLaser = laser_times(s,:);
    thisLaser = thisLaser(~isnan(thisLaser));
    if isempty(thisLaser)
        warning('Session %d has no lasers, skipping', s);
        continue;
    end
    firstLaser = thisLaser(1);

    c1_times = cue1.onsetTime(s,~isnan(cue1.onsetTime(s,:)));
    c1_IDs   = cue1.onsetID(s,~isnan(cue1.onsetID(s,:)));
    c2_times = cue2.onsetTime(s,~isnan(cue2.onsetTime(s,:)));
    c2_IDs   = cue2.onsetID(s,~isnan(cue2.onsetID(s,:)));

    lastCue1 = max(c1_times(c1_times < firstLaser), [], 'omitnan');
    lastCue2 = max(c2_times(c2_times < firstLaser), [], 'omitnan');

    if isempty(lastCue1) && isempty(lastCue2)
        error('Session %d: no cue precedes first laser.', s);
    elseif isempty(lastCue2) || (~isempty(lastCue1) && lastCue1 > lastCue2)
        CSplus_times = c1_times;
        CSplus_IDs   = c1_IDs;
        CSplus_ID(s) = 1;
        chosenLastCue = lastCue1;
    else
        CSplus_times = c2_times;
        CSplus_IDs   = c2_IDs;
        CSplus_ID(s) = 2;
        chosenLastCue = lastCue2;
    end

    CS_to_laser_time = firstLaser - chosenLastCue;

    g1 = []; b1 = [];
    for ii = 1:length(CSplus_times)
        dt = thisLaser - CSplus_times(ii);
        if any(dt > 0 & dt <= CS_to_laser_time + tol)
            g1 = [g1, ii]; % paired
        else
            b1 = [b1, ii]; % probe
        end
    end

    % Assign paired trials to new_cue1 / new_cue2
    if CSplus_ID(s) == 1
        new_cue1.onsetTime(s,1:length(g1)) = CSplus_times(g1);
        new_cue1.onsetID(s,1:length(g1))   = CSplus_IDs(g1);
        new_cue2.onsetTime(s,1:length(c2_times)) = c2_times;
        new_cue2.onsetID(s,1:length(c2_IDs))     = c2_IDs;
    else
        new_cue2.onsetTime(s,1:length(g1)) = CSplus_times(g1);
        new_cue2.onsetID(s,1:length(g1))   = CSplus_IDs(g1);
        new_cue1.onsetTime(s,1:length(c1_times)) = c1_times;
        new_cue1.onsetID(s,1:length(c1_IDs))     = c1_IDs;
    end

    % Temporarily store probe trials in cell arrays
    probeTimes{s} = CSplus_times(b1);
    probeIDs{s}   = CSplus_IDs(b1);
end

% --- Step 2: minimal NaN padding for probe trials
maxProbe = max(cellfun(@numel, probeTimes));
cue_probe.onsetTime = nan(nSessions, maxProbe);
cue_probe.onsetID   = nan(nSessions, maxProbe);

for s = 1:nSessions
    n = numel(probeTimes{s});
    if n > 0
        cue_probe.onsetTime(s,1:n) = probeTimes{s};
        cue_probe.onsetID(s,1:n)   = probeIDs{s};
    end
end

end
