function [new_cue1, new_cue2, cue_probe, CSplus_ID] = ...
         reclassify_cues(cue1, cue2, laser_times)
% Automatically detects which cue (cue1 or cue2) is CS+
% and reassigns trials into:
%   - new_cue1 : struct of cue1 trials (all)
%   - new_cue2 : struct of cue2 trials (all)
%   - cue_probe: subset of CS+ trials with no laser
%   - CSplus_ID: 1 or 2, depending on which cue was paired with laser
%
% Inputs:
%   cue1, cue2   = structs with fields onsetTime, onsetID
%   laser_times  = vector of laser onset times
%
% Outputs:
%   new_cue1, new_cue2 : same format as inputs
%   cue_probe           : struct of probe trials (only CS+)
%   CSplus_ID           : 1 if cue1 was CS+, 2 if cue2 was CS+

eps = 0.01; % tolerance for timing (10 ms)

% --- Step 1: Determine CS+ based on first laser
firstLaser = laser_times(1);

% Find most recent cue1 and cue2 before first laser
lastCue1 = max(cue1.onsetTime(cue1.onsetTime < firstLaser), [], 'omitnan');
lastCue2 = max(cue2.onsetTime(cue2.onsetTime < firstLaser), [], 'omitnan');

% Pick the most recent cue (handle empties safely) and assign CS+
if isempty(lastCue1) && isempty(lastCue2)
    error('No cue precedes the first laser. Cannot determine CS+.'); 
elseif isempty(lastCue2) || (~isempty(lastCue1) && lastCue1 > lastCue2)
    CSplus     = cue1;
    CSplus_ID  = 1;
    chosenLastCue = lastCue1;
else
    CSplus     = cue2;
    CSplus_ID  = 2;
    chosenLastCue = lastCue2;
end

% Infer cue-to-laser interval from first pairing
nextLaser = min(laser_times(laser_times > firstLaser));
CS_to_laser_time = nextLaser - chosenLastCue;

% --- Step 3: Separate probe vs paired in CS+
CSp_times = CSplus.onsetTime;
CSp_IDs   = CSplus.onsetID;

g1 = []; % paired
b1 = []; % probe

for ii = 1:length(CSp_times)
    this_cue_time = CSp_times(ii);
    a1 = laser_times - this_cue_time;

    % Lasers that fall within expected interval
    a2 = find((a1 > 0) & (a1 <= (CS_to_laser_time + eps)));

    if isempty(a2)
        b1 = [b1, ii]; % probe
    else
        g1 = [g1, ii]; % paired
    end
end

% --- Step 4: Build outputs
new_cue1 = cue1;
new_cue2 = cue2;

cue_probe = struct();
cue_probe.onsetTime = CSp_times(b1);
cue_probe.onsetID   = CSp_IDs(b1);

end
