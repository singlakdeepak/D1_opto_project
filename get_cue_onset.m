function [cue_onset_idx, cue_onset_times] = get_cue_onset(cue_array, samplingFrequency)
    cue_diff = diff([0,cue_array]);
    cue_onset_idx = find(cue_diff == 1);
    cue_onset_times = (cue_onset_idx - 1)/samplingFrequency;

end