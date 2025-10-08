%% Initialize storage
allStimuli = struct();
i = 1;

% --- Select the main folder (e.g., TD161) ---
mainFolder = uigetdir(pwd, 'Select the main mouse folder');
if isequal(mainFolder,0)
    error('No folder selected. Exiting...');
end

% --- Look for subfolders starting with 1_, 2_, 3_, 4_, 5_ ---
subDirs = dir(mainFolder);
subDirs = subDirs([subDirs.isdir]); % keep only directories
subDirs = subDirs(~ismember({subDirs.name},{'.','..'})); % remove . and ..

% Filter for folders that start with a number followed by "_"
validSubDirs = {};
for k = 1:numel(subDirs)
    name = subDirs(k).name;
    if ~isempty(regexp(name, '^[1-5]_','once')) % match "1_", "2_", ..., "5_"
        validSubDirs{end+1} = fullfile(mainFolder, name);
    end
end

% Sort the valid subfolders in natural numeric order (1_ before 10_)
validSubDirs = sort(validSubDirs);

% --- Load stimuli.mat from each valid subfolder ---
for k = 1:numel(validSubDirs)
    stimFile = fullfile(validSubDirs{k}, 'stimuli.mat');
    if exist(stimFile, 'file')
        loadedStim = load(stimFile);
        if isfield(loadedStim,'stimuli')
            allStimuli(i).stimuli = loadedStim.stimuli;
            allStimuli(i).folder = validSubDirs{k};
            allStimuli(i).filename = 'stimuli.mat';
            fprintf('Loaded stimuli.mat from: %s\n', validSubDirs{k});
            i = i + 1;
        else
            warning('No variable named "stimuli" in %s. Skipping...', stimFile);
        end
    else
        warning('No stimuli.mat found in %s. Skipping...', validSubDirs{k});
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
%% --- Plot mean angular velocity of all trial types ---
trialTypes  = {'Cue 1','Cue 2','Probe'};
trial_arrays = {new_cue1, new_cue2, cue_probe};

precue = 1;
postcue = 5;
doBaseline = 0;
doAbs = 1;
analysisWindow = [0 1]; % seconds after onset for mean stats
[sessionStats, meanTraces_all, t] = plotAngVel_finalAll(doAbs, smooth_resamp_vels, trial_arrays,...
                trialTypes, finalFPS, [precue,postcue], ...
                doBaseline, analysisWindow);

%% Close all figures %%
close all;