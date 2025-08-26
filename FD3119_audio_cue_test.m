% Make sure the VLSE Neuro functions are in workspace. 
clear all;
close all;
clc;

setOSDetails;
%% Parameters
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
%% Extract the encoder movement and get walking start and stop
extract_encoder_movement;

%% get laser times only during camera on times
laser = laser(first_pulse_index:last_pulse_index);
if exist('cue1','var')
    cue1  = cue1(first_pulse_index:last_pulse_index);
    [a1,a2] = get_cue_onset(cue1, samplingFrequency);
    CS1 = struct();
    CS1.onsetID = a1;
    CS1.onsetTime = a2;
end
if exist('cue2','var')
    cue2  = cue2(first_pulse_index:last_pulse_index);
    [a1,a2] = get_cue_onset(cue2, samplingFrequency);
    CS2 = struct();
    CS2.onsetID = a1;
    CS2.onsetTime = a2;
end

%%
local_encoder_fx;
close all;

%% Get laser on and off times
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

%% --- assuming there are only 1 type of laser, I will segregate CS1 trials paired with laser ---
% and the ones which are not. 
cue_to_laser_time = 1;
[Cue1, Cue1_probe] = unpair_probe_trials(CS1, laser_trial_times, ...
                        cue_to_laser_time);
[Cue2, Cue2_probe] = unpair_probe_trials(CS2, laser_trial_times, ...
                        cue_to_laser_time);

%% --- plot all the trial types included ---
if exist('Cue1_probe','var') && ~isempty(Cue1_probe)
    trialTypes  = {'Cue1','Cue2','Cue1_probe'};
    trial_arrays = {Cue1, Cue2, Cue1_probe};
elseif exist('Cue2_probe','var') && ~isempty(Cue2_probe)
    trialTypes  = {'Cue1','Cue2','Cue2_probe'};
    trial_arrays = {Cue1, Cue2, Cue2_probe};
end

precue = 1;
postcue = 5;
doBaseline = 0;
analysisWindow = [0.2 0.75]; % seconds after onset for probeStats
probeStats = plotAngVel_final(smooth_resamp_vels, trial_arrays,...
                trialTypes, finalFPS, [precue,postcue], ...
                doBaseline, analysisWindow);

%% plot the startle response adaptation in first one second after cue. 
do2 = 0;
if do2
plotAngVel_byCueOverT(smooth_resamp_vels, trial_arrays,...
                trialTypes, finalFPS, cue_to_laser_time,5);
end

