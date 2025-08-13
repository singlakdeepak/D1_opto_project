function [CSp_good, CS_probe] = unpair_probe_trials(CSp, laser_times,CS_to_laser_time)
   CSp_times = CSp.onsetTime;
   CSp_IDs = CSp.onsetID;
    ntr = length(CSp_times);
    eps = 0.01;
    
    g1 = [];
    b1 = [];
   for ii = 1:ntr
       this_cue_time = CSp_times(ii);
       a1 = laser_times - this_cue_time;
       a2 = find((a1>0) & (a1<=(CS_to_laser_time+eps)));
       if ~isempty(a2)
            g1 = [g1,ii];
       else
            b1 = [b1,ii];
       end
   end
   CSp_good = struct();
   CS_probe = struct();
   CSp_good.onsetTime = CSp_times(g1);
   CSp_good.onsetID = CSp_IDs(g1);
   
    CS_probe.onsetTime = CSp_times(b1);
   CS_probe.onsetID = CSp_IDs(b1);
end