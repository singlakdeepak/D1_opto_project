%start by clearing workspace.

%first need to load a mouse2D file into workspace.

%also, if ephys is available, then load the eMouse file as well.
clear all;
clc;
addpath(genpath('../'));

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

%% #1 Run this cell only for the testing case, 
% one of the sessions for FD3119 has multiple camera start and stops,
% remove all the data in between and get the rest. 
% find out the respective laser start and end times.
% There were different durations and frequencies of lasers given. 
% camera stores all the ones and zeros for camera on.

% laser stores all the ones and zeros for laser, it isn't corrected
% according to the camera
% Run this only once. 
eps = 0.001;
laser_corrected = laser(first_pulse_index:last_pulse_index);

% get the data only when camera is on.
cam_diffs = camera(2:end) - camera(1:(end-1));

cam_on_idx = find([1,cam_diffs] == 1);
cam_on_times = (cam_on_idx-1)/samplingFrequency;
cam_off_idx = find([1,cam_diffs,-1] == -1);
cam_off_times = (cam_off_idx-1)/samplingFrequency;

cam_on_time_diffs = [0,cam_on_times(2:end) - cam_on_times(1:(end-1))];
tmp_a1 = find(cam_on_time_diffs>((1/finalFPS)+eps));
turnon_places = [1,tmp_a1];
turnoff_places = [tmp_a1 - 1,length(cam_off_idx)];

cam_turnonidx = cam_on_idx(turnon_places);
cam_turnoffidx = cam_off_idx(turnoff_places)-1;

a2 = [];
a3 = [];
a4 = [];
for kid = 1:length(cam_turnonidx)
    a2 = [a2,laser_corrected(cam_turnonidx(kid):cam_turnoffidx(kid))];
    a3 = [a3,channelA(cam_turnonidx(kid):cam_turnoffidx(kid))];
    a4 = [a4,channelB(cam_turnonidx(kid):cam_turnoffidx(kid))];
end
%% #2, Run this cell only for the testing case. 
laser = a2;
channelA =  a3;
channelB = a4;
%%
local_encoder_fx;

%% Get laser on and off times based on the set parameters
laser_pulse_dur = 0.01; % 10 ms in duration
eps2 = 0.01;
laser_trial_freq = [2,10,20,25,40];
laser_trial_dur = [0.5,1,2,10];

if exist('laser', 'var')
    laser_diff = diff([0,laser]);

    % Find the indices where the laser turns on (i.e., where the difference is 1)
    laser_onset = find(laser_diff == 1);
    laser_onset_times = (laser_onset - 1)/samplingFrequency;
    laser_onset_diffs = diff([0,laser_onset_times]);
    new_laser_trial_idx = find(laser_onset_diffs>1);
    
    [lTypes, lTypesID] = get_laser_trial_types(new_laser_trial_idx,laser_onset_diffs, ...
                            laser_trial_freq, laser_trial_dur);
    laser_trial_onsets = round(laser_onset(new_laser_trial_idx)*finalFPS/samplingFrequency);
end

%% plotting different laser trial types
plotAlignedAngVelByTrialID(smooth_resamp_vels,lTypesID , laser_trial_onsets, finalFPS, [1,4],2)
%% modified till here
%%
subjects=uipickfiles('FilterSpec','/home/deeplabcutpc/Documents/sleap_analysis');  %prompts to pick subjects.
mousePosedir = subjects{1};
load(fullfile(mousePosedir,'mouse2D.mat'));

if exist('eMouse')==0
eMouse = [];
eMouse.stimuli.fr = 80;
% eMouse.stimuli.camTimes = [0 100];
% eMouse.mouse2D.params.px2mm = 0.3120;
end
%% extract laser and camera ON signals from Intan .rhd files.

samplingFrequency = 25000; % Sampling frequency in Hz
finalFPS = 80;

%% Load concatenatedData

% Select the folder with the concatenatedData
folderPath = uigetdir('/media/deeplabcutpc/Expansion/',...
    'Select the folder containing concatenatedData .mat files');

% Check if the user canceled the folder selection
if folderPath == 0
    disp('User canceled the folder selection.');
else
    % Get a list of all .mat files in the selected folder
    files = dir(fullfile(folderPath, '*Data*.mat'));

    % Check if any files were found
    if isempty(files)
        disp('No .mat files found in the specified folder.');
    else
        % Initialize an empty array to hold all concatenated data
        allConcatenatedData = [];

        % Ensure the files are ordered correctly
        fileNames = {files.name}; % Extract the names of the files
        fileNames = sort_nat(fileNames); % Sort the filenames naturally (e.g., 1, 2, 10, 11)

        % Loop through each file and load the concatenatedData
        for i = 1:length(fileNames)
            fullFileName = fullfile(folderPath, fileNames{i});
            tempData = load(fullFileName, 'concatenatedData');
            allConcatenatedData = [allConcatenatedData, tempData.concatenatedData];
        end

        % Now, allConcatenatedData contains the combined data from all .mat files
        disp(['All concatenatedData files have been loaded and combined from: ', folderPath]); disp(' ');
    end
end

camera_times = allConcatenatedData(2,:);
laser_ones = allConcatenatedData(1,:);

% Find indices of all pulses of 1 from Camera 1
camera1_indices = find(camera_times== 1);

% Find the index of the first and last pulse of 1
first_pulse_index = camera1_indices(1);
last_pulse_index = camera1_indices(end);
% Extract data from the first to the last pulse

camera_inpt = camera_times(first_pulse_index:last_pulse_index);
cam_start_time = (first_pulse_index/samplingFrequency) - (1/finalFPS);
cam_end_time = last_pulse_index/samplingFrequency;
% Find the differences between consecutive elements
laser_diff = diff(laser_ones);

% Find the indices where the laser turns on (i.e., where the difference is 1)
laser_onset = find(laser_diff == 1) + 1;
laser_onset_times = laser_onset/samplingFrequency;
% laser_duration = 0.1; % it is in seconds. 
% laser has been changed to 2 s long with pulses of 50 ms. 
% laser_pulse = 0.1;
% eps = 0.1;
% duty_cycle = 0.5; % it means it is a 50% duty cycle.
laser_duration = 0.5;
% laser_tmp  = laser_onset_times(2:end) - laser_onset_times(1:(end-1));
% las_diffs = find(laser_tmp>(laser_pulse +eps));
% laser_onset_times = [laser_onset_times(1),laser_onset_times(las_diffs+1)];

%%
if size(allConcatenatedData,1) >2
    pseudo_laser_ones = allConcatenatedData(3,:);
    pseudolaser_diff = diff(pseudo_laser_ones);

    % Find the indices where the laser turns on (i.e., where the difference is 1)
    pseudolaser_onset = find(pseudolaser_diff == 1) + 1;
    pseudolaser_onset_times = pseudolaser_onset/samplingFrequency;
end
%%%%%%
%%
camTimes = [cam_start_time, cam_end_time];
eMouse.stimuli.camTimes = camTimes;
eMouse.stimuli.laserTimes = laser_onset_times; 
eMouse.stimuli.laserDuration = laser_duration;
if exist('pseudolaser_onset_times','var')
    eMouse.stimuli.pseudolaserTimes = pseudolaser_onset_times;    
end
if exist('laser_pulse','var')
    eMouse.stimuli.laserPulse = laser_pulse;
    eMouse.stimuli.laserDutyCycle = duty_cycle;
end


%fill in the NaN values by averaging edge values.
disp('filling in NaN values by averaging edge values.')
new_tail = remove_nanvalues(tail);  
new_lr = remove_nanvalues(lr);
new_lf = remove_nanvalues(lf);
new_rr = remove_nanvalues(rr);
new_rf = remove_nanvalues(rf);
new_nose = remove_nanvalues(nose);

eMouse.mouse2D.tail = new_tail;
eMouse.mouse2D.lr = new_lr;
eMouse.mouse2D.lf = new_lf;
eMouse.mouse2D.rr = new_rr;
eMouse.mouse2D.rf = new_rf;
eMouse.mouse2D.nose = new_nose;
eMouse.mouse2D.params = params;

save(fullfile(mousePosedir,'eMouse.mat'),'eMouse','-mat')