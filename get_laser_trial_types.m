function [lTypes, lTypesID] = get_laser_trial_types(new_laser_trial_idx,...
                            laser_onset_diffs, ...
                            laser_trial_freq, laser_trial_dur)
% lTypes will be 2D array storing laser frequency in Col1 and laser
% duration in Col2
% lTypesID will store the ID to understand what trial Type a laser trial
% was. lTypes(lTypesID,:) will give the laser freq and duration for each
% trial type

    ntrials = length(new_laser_trial_idx);
    lTypeMap = containers.Map;
    lType_Mat = [];
    for ii = 1:length(laser_trial_freq)
        for jj = 1:length(laser_trial_dur)
            lFq = laser_trial_freq(ii);
            ldur = round(laser_trial_dur(jj),2);
            tmp_s = [num2str(lFq),',',num2str(ldur)];
            lType_Mat = [lType_Mat;[lFq,ldur]];
            lTypeMap(tmp_s) = [];
        end
    end
    for lid = 1:(ntrials-1)
        thisst = new_laser_trial_idx(lid);
        thisend = new_laser_trial_idx(lid+1);
        npulses = thisend - thisst;
        pp_diff = laser_onset_diffs(thisst+1);
        lFq  = round(1/pp_diff);
        ldur = round(npulses*pp_diff,2);
        tmp_s = [num2str(lFq),',',num2str(ldur)];
        % disp(tmp_s);
        lTypeMap(tmp_s) = [lTypeMap(tmp_s), lid];

    end
    thisst = new_laser_trial_idx(ntrials);
    thisend = length(laser_onset_diffs)+1;
    npulses = thisend - thisst;
    pp_diff = laser_onset_diffs(thisst+1);
    lFq  = round(1/pp_diff);
    ldur = round(npulses*pp_diff,2);
    tmp_s = [num2str(lFq),',',num2str(ldur)];
    lTypeMap(tmp_s) = [lTypeMap(tmp_s), ntrials]; 
    
    
    final_types = [];
    for ii = 1:size(lType_Mat,1)
        tmp_s = [num2str(lType_Mat(ii,1)),',',num2str(lType_Mat(ii,2))];
        if ~isempty(lTypeMap(tmp_s))
            final_types = [final_types;lType_Mat(ii,:)];
            
        else
            remove(lTypeMap, tmp_s);
        end
    end
    lTypes = final_types;
    lTypesID = lTypeMap;
end