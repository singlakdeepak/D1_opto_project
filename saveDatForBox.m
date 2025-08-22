% Make sure the VLSE Neuro functions are in workspace. 
clear all;
clc;

% have this function at the start of every script that runs analysis.
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

laser_pulse_dur = 0.01; % 10 ms in duration
eps2 = 0.01;
laser_trial_freq = [25,40];
laser_trial_dur = [2]; % Make sure to change this if laser duration changes

cue_to_laser_time = 1;
lPower  = 6; % laser power
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

[CSp, CS_probe] = unpair_probe_trials(CSp, laser_trial_times, ...
                        cue_to_laser_time);

%% convert to common format. % same as stimuli.
% stimuli: main struct.
% stimuli.ballvelocity: stores the smoothed angular velocity in rev/s.
% stimuli.ballvelsamplingrate: stores the final fs of sampling.
% stimuli.cue1times: stores the cue1 times for the cue that is paired with
% laser.
% stimuli.cue2times: stores the cue2 times for the cue that is not paired with
% laser.
% stimuli.meancue1laserdelay: stores the time between cue1 to laser time. 
% stimuli.probetimes: stores the time for the probe trials.
% stimuli.lasertimes: stores the times when laser was turned on. 
% 

stimuli = struct();
stimuli.ballvelocity = smooth_resamp_vels;
stimuli.ballvelsamplingrate = finalFPS;
stimuli.cue1times = CSp.onsetTime;
stimuli.cue2times = CSn.onsetTime;
stimuli.meancue1laserdelay = mean(laser_trial_times - CSp.onsetTime);
stimuli.probetimes = CS_probe.onsetTime;
stimuli.lasertimes = laser_trial_times;

params = struct();
params.laserFreq = lTypes(1);
params.laserDur = lTypes(2);
params.laserPulseDur = laser_pulse_dur;
params.laserPower = lPower;
params.ballCircum = circum;
params.folderPath = folderPath;
params.velUnits = 'revolutions/s';
stimuli.params = params;

savePath = fullfile(folderPath,'stimuli.mat');
save(savePath, 'stimuli','-v7.3');