%% Plot Heatmaps of all trials of a specific condition: Normal, Reverse, Reverse + Trace %%
clear all;
close all;
clc;

setOSDetails;
%% Initialize storage
allStimuli = struct();
i = 1;

disp('Select folders containing stimuli.mat files. Press Cancel when done.');

while true
    folderPath = uigetdir(pwd, 'Select a folder with stimuli.mat');
    if isequal(folderPath,0)
        break; % user pressed cancel
    end
    
    stimFile = fullfile(folderPath,'stimuli.mat');
    if exist(stimFile,'file')
        loadedStim = load(stimFile);
        if isfield(loadedStim,'stimuli')
            allStimuli(i).stimuli = loadedStim.stimuli;
            allStimuli(i).folder = folderPath;
            allStimuli(i).filename = 'stimuli.mat';
            fprintf('Loaded stimuli.mat from: %s\n', folderPath);
            i = i + 1;
        else
            warning('No variable named "stimuli" found in %s. Skipping...', stimFile);
        end
    else
        warning('No stimuli.mat found in %s. Skipping...', folderPath);
    end
end

if isempty(fieldnames(allStimuli))
    error('No valid stimuli.mat files were loaded.');
else
    disp(['Loaded ' num2str(numel(allStimuli)) ' stimuli structures.']);
end

%% --- Concatenate allStimuli into one big structure ---
% Assume allStimuli(i).stimuli exists
nSessions = numel(allStimuli);

% Initialize containers
smooth_resamp_vels = [];
Cue1_times = [];
Cue2_times = [];
laser_trial_times = [];

% Use first session’s constants (assuming they don’t change)
samplingFrequency = allStimuli(1).stimuli.stimsamplingrate;
finalFPS = allStimuli(1).stimuli.downsamplingrate;
circum = allStimuli(1).stimuli.ball_circum;

laser_pulse_dur = allStimuli(1).stimuli.lasertimes.laserPulseDur;
laser_trial_freq = allStimuli(1).stimuli.lasertimes.laserFreq;
laser_trial_dur = allStimuli(1).stimuli.lasertimes.laserDur;

%% --- Store session velocities and cue/laser times without cumulative offset ---
% smooth_resamp_vels will be a cell array (each cell = one session)
smooth_resamp_vels = cell(1, nSessions);

% Determine max number of cues/lasers across sessions for padding
maxCue1 = max(cellfun(@(s) numel(s.stimuli.cue1times), num2cell(allStimuli)));
maxCue2 = max(cellfun(@(s) numel(s.stimuli.cue2times), num2cell(allStimuli)));
maxLaser = max(cellfun(@(s) numel(s.stimuli.lasertimes.laserontimes), num2cell(allStimuli)));

% Initialize numeric arrays with NaNs for cues and lasers
Cue1_times = nan(nSessions, maxCue1);
Cue2_times = nan(nSessions, maxCue2);
laser_trial_times = nan(nSessions, maxLaser);

for i = 1:nSessions
    stim = allStimuli(i).stimuli;

    % --- store session velocities ---
    smooth_resamp_vels{i} = stim.ball_angular_vel;

    % --- pad cue/laser times with NaNs to fit numeric array ---
    Cue1_times(i,1:numel(stim.cue1times)) = stim.cue1times;
    Cue2_times(i,1:numel(stim.cue2times)) = stim.cue2times;
    laser_trial_times(i,1:numel(stim.lasertimes.laserontimes)) = stim.lasertimes.laserontimes;
end


%% Build Cue structures
Cue1 = struct();
Cue1.onsetID   = Cue1_times * samplingFrequency;
Cue1.onsetTime = Cue1_times;

Cue2 = struct();
Cue2.onsetID   = Cue2_times * samplingFrequency;
Cue2.onsetTime = Cue2_times;

%% --- separates probe trials from cue + laser trials ---
% automatically detects which cue has laser paired
% pads values with NaNs to allow easier plotting down the line

[new_cue1, new_cue2, cue_probe, CSplus_ID] = ...
    reclassify_cues(Cue1, Cue2, laser_trial_times);

%% --- Plot trial by trial angular velocity heatmaps ---

trialTypes  = {'Cue 1','Cue 2','Probe'};
trial_arrays = {new_cue1, new_cue2, cue_probe};

precue = 1;
postcue = 5;
doBaseline = 0; % Only really matters if mouse is runnning a lot before cue onset

plotTrialHeatmaps2(smooth_resamp_vels, trial_arrays, trialTypes, finalFPS, [precue, postcue], doBaseline);

%% --- Save figures: CHANGE NAME ---
% parts = strsplit(ch_info_file, filesep); % split into parts
% 
% name = parts{4};
% session = parts{5};
% tokens = regexp(session, '^(\d+)_', 'tokens'); % extracts session number before underscore
% sessionNum = str2double(tokens{1}{1});
% 
% doSave = 0;
% if doSave
%     saveas(figure(1), sprintf('%s_session%d.png', name, sessionNum))
%     saveas(figure(2), sprintf('%s_session%d_Cue1trials.png', name, sessionNum))
%     saveas(figure(3), sprintf('%s_session%d_Cue2trials.png', name, sessionNum))
%     saveas(figure(4), sprintf('%s_session%d_probetrials.png', name, sessionNum))
% end

saveas(figure(1), 'TD156_allcue1.png')
saveas(figure(2), 'TD156_allcue2.png')
saveas(figure(3), 'TD156_allprobe.png')
