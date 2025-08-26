function [cue_onset_idx, cue_onset_times] = get_cue_onset(cue_array, samplingFrequency)
    % This function extracts the onset times of cues from a binary cue signal.
    %
    % INPUTS:
    %   cue_array         - binary array (0/1) where "1" indicates cue is ON
    %   samplingFrequency - sampling rate of the signal (Hz)
    %
    % OUTPUTS:
    %   cue_onset_idx   - indices (samples) where cue onset occurs
    %   cue_onset_times - onset times in seconds (relative to start of signal)
    
    % Compute difference across consecutive samples
    % Prepend a 0 to align size, so diff captures the first onset properly
    cue_diff = diff([0, cue_array]);
    
    % Find indices where cue goes from 0 → 1 (onset)
    cue_onset_idx = find(cue_diff == 1);
    
    % Convert indices to time in seconds
    cue_onset_times = (cue_onset_idx) / samplingFrequency;
end
