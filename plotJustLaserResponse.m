% Make sure the VLSE Neuro functions are in workspace. 
clear all;
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
decimal_round = 2;           % decimals to round to for accl_rounding

% --- Define the specifications of the quadrature encoder ---
PPR = 256; % Pulses per revolution
diameter = round(6*25.4); % Diameter of styrofoam ball in mm (12" diameter), 6" for black foam roller
circum = pi*diameter; % Circumference 

% --- plotting params ---
onset = 2; % time before and after onset
plotting_speed = false; % Change boolean if plotting speed or velocity

get_startendFrames = 1; % Change to 1 only if you would like to get start and end frames.
%% Extract the encoder movement and get walking start and stop
extract_encoder_movement; 

%% --- Load concatenated data ---
local_encoder_fx;
close all;

%% --- Get laser on and off times based on the set parameters ---
laser = laser(first_pulse_index:last_pulse_index); % synchronize laser to camera
laser_diff = diff([0,laser]);

% Find the indices where the laser turns on (i.e., where the difference is 1)
laser_onset = find(laser_diff == 1);
laser_onset_times = (laser_onset)/samplingFrequency;
laser_onset_diffs = diff([0,laser_onset_times]);
new_laser_trial_idx = find(laser_onset_diffs>1);
laser_trial_onsets = round(laser_onset(new_laser_trial_idx)*finalFPS/samplingFrequency);
laser_trial_times = laser_onset(new_laser_trial_idx)/samplingFrequency;

%% --- Plot angular velocity aligned to onset of laser ---
plotAngVel_byLaser(smooth_resamp_vels, laser_trial_times, finalFPS, [onset, onset])

