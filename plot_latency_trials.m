% Function takes cue paired w/laser and probe, and identifies earliest time of activity post cue onset (the latency)
    % Take mean angular velocities trace and get latency for that session

% angVel_all is a row of cells where each cell is a session's angular velocity
% trial_arrays is a 1x3 cell where each cell is cue 1/cue2/probe and is a structure that holds onsetTime and onsetID. each row of onsetTime is a session of cue times.
% CSplus_ID is a column vector of 1's for cue 1 or 2's for cue 2 (doubles), where each value is for a session
% fs is sampling rate
% analysis window is [precue, postcue] that determines window of analysis
% factor is used towards determining the threshold, a factor of what the max activity of the cue that determines actual activity post cue onset

function plot_latency(angVel_all, trial_arrays, CSplus_ID, fs, window, factor)
    baseline = -1 to 0s
    create empty latency matrix of nsessions in (s)
    if CSplusID == 1
        look at angVel_all of cue 1
        find max value post cue onset and set as number for reference when determining threshold
        find when angVel_all of cue 1 crosses threshold (latency)
    else
        look at angVel_all of cue 2
        find max value post cue onset and set as number for reference when determining threshold
        find when angVel_all of cue 2 crosses threshold (latency)
    end
    look at angVel_all of probe
    find when angVel_all of probe crosses threshold (latency)
    plot latencies of cue w/laser and probe for each session
end