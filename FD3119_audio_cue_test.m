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
%% Extract the encoder movement and get walking start and stop
extract_encoder_movement;

%% get laser times only during camera on times
laser = laser(first_pulse_index:last_pulse_index);
if exist('CS_p','var')
    CS_p  = CS_p(first_pulse_index:last_pulse_index);
    [a1,a2] = get_cue_onset(CS_p, samplingFrequency);
    CSp = struct();
    CSp.onsetID = a1;
    CSp.onsetTime = a2;
end
if exist('CS_n','var')
    CS_n  = CS_n(first_pulse_index:last_pulse_index);
    [a1,a2] = get_cue_onset(CS_n, samplingFrequency);
    CSn = struct();
    CSn.onsetID = a1;
    CSn.onsetTime = a2;
end

%%
local_encoder_fx;

%% Get laser on and off times based on the set parameters
laser_pulse_dur = 0.01; % 10 ms in duration
eps2 = 0.01;
laser_trial_freq = [25,40];
laser_trial_dur = [2];

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

%% assuming there are only 1 type of laser, I will segregate CSp trials paired with laser
% and the ones which are not. 
cue_to_laser_time = 1;
[CSp, CS_probe] = unpair_probe_trials(CSp, laser_trial_times, ...
                        cue_to_laser_time);

%% plot all the trial types included
trialTypes = {'CS+','CS-','CS+ probe'};
trial_arrays = [CSp,CSn, CS_probe];
precue = 1;
postcue = 5;
doBaseline = 0; % decide whether to apply baseline subtraction
plotAngVel_byCue(smooth_resamp_vels, trial_arrays,...
                trialTypes, finalFPS, [precue,postcue], doBaseline);

%% plot the startle response adaptation in first one second after cue. 
plotAngVel_byCueOverT(smooth_resamp_vels, trial_arrays,...
                trialTypes, finalFPS, cue_to_laser_time,5);

%% check 0.5s to 1.5s vel activity to see if there's any dip
bin_size = 5; % averaging every # of trials
startidx = 1; % starting time of interest
endidx = 4; % ending time of interest
plotTempActivity(smooth_resamp_vels, trial_arrays, trialTypes, finalFPS, ...
                 bin_size, [startidx, endidx])


