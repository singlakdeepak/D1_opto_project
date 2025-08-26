%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Andrew Weakley, Deepak Singla
% This file gets the position data from encoder and finds the start and
% stop of walking bouts. 
% Last updated on: 08/06/2025
%% Load concatenatedData

% Select the folder with the concatenatedData
if osid ==1
    folderPath = uigetdir('D:\Phase 2_Training\',...
            'Select the folder containing concatenatedData .mat files');
elseif (osid ==2)
    folderPath = uigetdir('/media/deeplabcutpc/Expansion/',...
            'Select the folder containing concatenatedData .mat files');
end
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
        ch_info_file = fullfile(folderPath, 'channel_info.mat');
        if exist(ch_info_file,'file')
            load(ch_info_file);
            chinfo_present = 1;
        else
            chinfo_present = 0;
        end
        % Now, allConcatenatedData contains the combined data from all .mat files
        disp(['All concatenatedData files have been loaded and combined from: ', folderPath]); disp(' ');
    end
end

% Syncing camera with encoder - gather positioning based on camera
if (chinfo_present == 0)
    disp('Channel info is not present in the data folder. No mapping of Intan channels done.');
    channelB = allConcatenatedData(2,:);
    channelA = allConcatenatedData(1,:);
    if size(allConcatenatedData,1)>=3 && (any(allConcatenatedData(3,:) == 1))
        % Find indices of all pulses of 1 from Camera 1 and find indexes
        camera1_indices = find(allConcatenatedData(3,:) == 1);
        first_pulse_index = camera1_indices(1);
        last_pulse_index = camera1_indices(end);
        camera = allConcatenatedData(3, first_pulse_index:last_pulse_index);
    
        % Synchronize data and save only from the start of camera recording to the end of camera recording
        channelB = allConcatenatedData(2, first_pulse_index:last_pulse_index);
        channelA = allConcatenatedData(1, first_pulse_index:last_pulse_index);
        cam_start_time = (first_pulse_index/samplingFrequency) - (1/finalFPS);  
        cam_end_time = last_pulse_index/samplingFrequency;
    
        % If laser exists
        if size(allConcatenatedData,1)>=4 && any(allConcatenatedData(4,:) == 1)
            laser = allConcatenatedData(4,:);  
            laser = laser(first_pulse_index:last_pulse_index); % synchronize laser
            laser_diff = diff(laser);
            laser_onset = find(laser_diff == 1) + 1;
        end
    
        % Check if CS+ exists.
        if size(allConcatenatedData,1)>=5 && any(allConcatenatedData(5,:) == 1)
            cue1 = allConcatenatedData(5,:);
        end
        
        % Check if CS- exists. 
        if size(allConcatenatedData,1)>=6 && any(allConcatenatedData(6,:) == 1)
            cue2 = allConcatenatedData(6,:);
        end
    end
else
    disp('Channel info is present in the data folder. Mapping Channels.');
    possible_names = {'channelA', 'channelB', 'cameras_ball_pup', 'laser', ...
                      'audio_cue_cs+', 'cue1', 'cs+', 'audio_cue_cs-', 'cue2', 'cs-', 'VR_syn'};
    custom_chnames = {channel_info.custom_channel_name};
    for cid = 1:length(custom_chnames)
        [isMatch, idx] = ismember(custom_chnames{cid}, possible_names);
        if isMatch
            switch idx
            case 1
                channelA = allConcatenatedData(cid,:);
            case 2
                channelB = allConcatenatedData(cid,:);
            case 3 
                camera1_indices = allConcatenatedData(cid,:);
            case 4
                laser = allConcatenatedData(cid,:);
            case {5, 6, 7}
                cue1 = allConcatenatedData(cid,:);
            case {8, 9, 10}
                cue2 = allConcatenatedData(cid,:);
            case 11
                VR_syn = allConcatenatedData(cid,:);
            end
        else
            disp(['This channel is not recorded: ', custom_chnames{cid}, '. Make changes in extract_encoder_movement.m']);
        end
    end
    
    if exist('camera1_indices','var')
        first_pulse_index = find(camera1_indices==1, 1, 'first');
        last_pulse_index = find(camera1_indices==1, 1, 'last');
        camera = camera1_indices(first_pulse_index:last_pulse_index);
    
        % Synchronize data
        channelB = channelB(first_pulse_index:last_pulse_index);
        channelA = channelA(first_pulse_index:last_pulse_index);
        cam_start_time = (first_pulse_index/samplingFrequency) - (1/finalFPS);  
        cam_end_time = last_pulse_index/samplingFrequency;

        if exist('laser','var')
            laser = laser(first_pulse_index:last_pulse_index); % synchronize laser
            laser_diff = diff(laser);
            laser_onset = find(laser_diff == 1) + 1;
        end
    end
end
