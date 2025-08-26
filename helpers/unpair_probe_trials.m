function [CSp_good, CS_probe] = unpair_probe_trials(CSp, laser_times, CS_to_laser_time)
   % This function separates CS+ trials into:
   %   1. CSp_good = trials where the cue is followed by a laser
   %   2. CS_probe = trials where the cue occurs without a laser
   
   % Extract CS+ onset times and IDs
   CSp_times = CSp.onsetTime;
   CSp_IDs = CSp.onsetID;
   ntr = length(CSp_times);   % total number of CS+ trials
   eps = 0.01;                % small tolerance (10 ms) for matching cue-to-laser timing
   
   % Initialize trial index lists
   g1 = [];  % indices of CS+ trials paired with laser
   b1 = [];  % indices of CS+ probe trials (no laser)
   
   % Loop through all CS+ trials
   for ii = 1:ntr
       this_cue_time = CSp_times(ii);         % current CS+ cue onset
       a1 = laser_times - this_cue_time;      % difference between laser onsets and cue onset
       
       % Find laser(s) that occur AFTER this cue and
       % within the expected cue-to-laser time window
       a2 = find((a1 > 0) & (a1 <= (CS_to_laser_time + eps)));
       
       if ~isempty(a2)
            % If a matching laser exists → classify as paired trial
            g1 = [g1, ii];
       else
            % Otherwise → classify as probe (unpaired) trial
            b1 = [b1, ii];
       end
   end
   
   % Build output structs with onset times & IDs
   CSp_good = struct();
   CS_probe = struct();
   
   % Paired trials (cue + laser)
   CSp_good.onsetTime = CSp_times(g1);
   CSp_good.onsetID   = CSp_IDs(g1);
   
   % Probe trials (cue only, no laser)
   CS_probe.onsetTime = CSp_times(b1);
   CS_probe.onsetID   = CSp_IDs(b1);
end
