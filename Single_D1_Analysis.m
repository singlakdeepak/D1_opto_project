% Make sure the VLSE Neuro functions are in workspace. 
clear all;
close all;
clc;

setOSDetails;
%% --- Parameters ---
% --- recording params ---
samplingFrequency = 25000; % Sampling frequency in Hz
finalFPS = 80;

% --- startFrames and endFrames related params ---
walk_bout_min_dur = 2.5;     % Minimum walking bout duration in seconds: good value can be anything above 1.5
downTime = 1.5;              % Duration between walking bouts in seconds: good value is at 1.5
accl_threshold = 0.21;       % Manipulatable threshold amplitude for acceleration thresholding: good value is at 0.21
final_vel_threshold = 0.05;   % reject final bouts with mean smooth_resamp_vels threshold

decimal_round = 2;           % decimals to round to for accl_rounding

% --- Define the specifications of the quadrature encoder ---
PPR = 256; % Pulses per revolution
diameter = round(6*25.4); % Diameter of styrofoam ball in mm (12" diameter), 6" for black foam roller
circum = pi*diameter; % Circumference 

% --- plotting params ---
onset = 2; % time before and after onset
plotting_speed = false; % Change boolean if plotting speed or velocity

get_startendFrames = 1; % Change to 1 only if you would like to get start and end frames.

% --- Laser params ---
laser_pulse_dur = 0.01; % 10 ms in duration
laser_trial_freq = [25,40];
laser_trial_dur = [2];
cue_to_laser_time = 2; % for regular conditions (normal/reverse) time is 1 s, for trace is 2 s

% --- Was it a reversal (Cue2 has probes) ---
reverse = true;
%% --- Extract the encoder movement and get walking start and stop ---
extract_encoder_movement; % Encoder and laser is synchronized to camera, only necessary for pose tracking

%% save cue times
if exist('cue1','var')
    cue1  = cue1(first_pulse_index:last_pulse_index);
    [a1,a2] = get_cue_onset(cue1, samplingFrequency);
    Cue1 = struct();
    Cue1.onsetID = a1;
    Cue1.onsetTime = a2;
end
if exist('cue2','var')
    cue2  = cue2(first_pulse_index:last_pulse_index);
    [a1,a2] = get_cue_onset(cue2, samplingFrequency);
    Cue2 = struct();
    Cue2.onsetID = a1;
    Cue2.onsetTime = a2;
end

%% --- get walking bout start and end frames ---
local_encoder_fx;

%% --- Get laser on and off times ---
if exist('laser', 'var')
    laser_diff = diff([0,laser]);

    % Find the indices where the laser turns on (i.e., where the difference is 1)
    laser_onset = find(laser_diff == 1);
    laser_onset_times = (laser_onset)/samplingFrequency;
    laser_onset_diffs = diff([0,laser_onset_times]);
    new_laser_trial_idx = find(laser_onset_diffs>1);
    
    [lTypes, lTypesID] = get_laser_trial_types(new_laser_trial_idx,laser_onset_diffs, ...
                            laser_trial_freq, laser_trial_dur);
    laser_trial_onsets = round(laser_onset(new_laser_trial_idx)*finalFPS/samplingFrequency);
    laser_trial_times = laser_onset(new_laser_trial_idx)/samplingFrequency;
end

%% --- assuming there are only 1 type of laser, I will segregate Cue1 laser or Cue2 laser from probe trials ---
if reverse % If Cue 2 has probe
    [Cue2, Cue2_probe] = unpair_probe_trials(Cue2, laser_trial_times, ...
        cue_to_laser_time);
else % If Cue 1 has probe
    [Cue1, Cue1_probe] = unpair_probe_trials(Cue1, laser_trial_times, ...
        cue_to_laser_time);
end

%% --- plot all the trial types included ---

if reverse
    trialTypes  = {'Cue 1','Cue 2','Cue 2 probe'};
    trial_arrays = {Cue1, Cue2, Cue2_probe};
else
    trialTypes  = {'Cue 1','Cue 2','Cue 1 probe'};
    trial_arrays = {Cue1, Cue2, Cue1_probe};
end

precue = 1;
postcue = 5;
doBaseline = 0;
analysisWindow = [0 1]; % seconds after onset for probeStats
probeStats = plotAngVel_final(smooth_resamp_vels, trial_arrays,...
                trialTypes, finalFPS, [precue,postcue], ...
                doBaseline, analysisWindow);

disp(['meanVal = ', num2str(probeStats.meanVal)]);
disp(['maxVal = ', num2str(probeStats.maxVal)]);
disp(['minVal = ', num2str(probeStats.minVal)]);

%% --- Plot trial by trial angular velocity of cue 1 and cue 2 using imagesc ---
precue = 1;
postcue = 5;
doBaseline = 0; % Only really matters if mouse is runnning a lot before cue onset

plotTrialHeatmaps(smooth_resamp_vels, trial_arrays, trialTypes, finalFPS, [precue, postcue], doBaseline);

%% --- plot the startle response adaptation in first one second after cue ---
do2 = 0;
if do2
plotAngVel_byCueOverT(smooth_resamp_vels, trial_arrays,...
                trialTypes, finalFPS, cue_to_laser_time,5);
end

%% --- Save figures: CHANGE NAME ---
parts = strsplit(ch_info_file, filesep); % split into parts

name = parts{4};
session = parts{5};
tokens = regexp(session, '^(\d+)_', 'tokens'); % extracts session number before underscore
sessionNum = str2double(tokens{1}{1});

doSave = 1;
if doSave
    saveas(figure(1), sprintf('%s_session%d.png', name, sessionNum))
    saveas(figure(2), sprintf('%s_session%d_Cue1trials.png', name, sessionNum))
    saveas(figure(3), sprintf('%s_session%d_Cue2trials.png', name, sessionNum))
    saveas(figure(4), sprintf('%s_session%d_probetrials.png', name, sessionNum))
end