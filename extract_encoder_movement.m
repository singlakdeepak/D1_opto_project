%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Andrew Weakley, Deepak Singla
% This file gets the position data from encoder and finds the start and
% stop of walking bouts. 
% Last updated on: 08/06/2025
%% Get correct walking bout startFrames and endFrames from encoder

 
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
        if any(allConcatenatedData(3,:) == 1)
            camera1_indices = find(allConcatenatedData(3,:) == 1);
            first_pulse_index = camera1_indices(1);
            last_pulse_index = camera1_indices(end);
            camera = allConcatenatedData(3, first_pulse_index:last_pulse_index);
        end
    
        % Synchronize data and save only from the start of camera recording to the end of camera recording (first to the last pulse)
        channelB = allConcatenatedData(2, first_pulse_index:last_pulse_index);
        channelA = allConcatenatedData(1, first_pulse_index:last_pulse_index);
        cam_start_time = (first_pulse_index/samplingFrequency) - (1/finalFPS);  % start time of camera recording in seconds
        cam_end_time = last_pulse_index/samplingFrequency;
    
        % If laser exists
        if size(allConcatenatedData,1)>=4 && any(allConcatenatedData(4,:) == 1)
            laser = allConcatenatedData(4,:);
            % Find the differences between consecutive elements
            laser_diff = diff(laser);
    
            % Find the indices where the laser turns on (i.e., where the difference is 1)
            laser_onset = find(laser_diff == 1) + 1;
        end
    
        % Check if CS+ exists.
        if size(allConcatenatedData,1)>=5 && any(allConcatenatedData(5,:) == 1)
            CS_p = allConcatenatedData(5,:);
        end
        
        % Check if CS- exists. 
        if size(allConcatenatedData,1)>=6 && any(allConcatenatedData(6,:) == 1)
            CS_n = allConcatenatedData(6,:);
        end
        
    
    end
else
    disp('Channel info is present in the data folder. Mapping Channels.');
    possible_names = {'channelA',...
                        'channelB',...
                        'cameras_ball_pup',...
                        'laser',...
                        'audio_cue_cs+',...
                        'audio_cue_cs-',...
                            'cs+',...
                            'cs-',...
                            'VR_syn'};
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
            case {5, 7}
                CS_p = allConcatenatedData(cid,:);
            case {6, 8}
                CS_n = allConcatenatedData(cid,:);
            case 9
                VR_syn = allConcatenatedData(cid,:);
            end
        else
            disp('This channel is not recorded: ',custom_chnames{cid},'.\n');
            disp('Make changes in extract_encoder_movement.m');
        end
    end
    
    if exist('camera1_indices','var')
        % Find indices of all pulses of 1 from Camera 1 and find indexes
        a1 = find(camera1_indices== 1);
        first_pulse_index = a1(1);
        last_pulse_index = a1(end);
        camera = camera1_indices(first_pulse_index:last_pulse_index);
    
        % Synchronize data and save only from the start of camera recording to the end of camera recording (first to the last pulse)
        channelB = channelB(first_pulse_index:last_pulse_index);
        channelA = channelA(first_pulse_index:last_pulse_index);
        cam_start_time = (first_pulse_index/samplingFrequency) - (1/finalFPS);  % start time of camera recording in seconds
        cam_end_time = last_pulse_index/samplingFrequency;
    
        % If laser exists
        if exist('laser','var')
            
            laser_diff = diff(laser);
    
            % Find the indices where the laser turns on (i.e., where the difference is 1)
            laser_onset = find(laser_diff == 1) + 1;
        end
        
    
    end
    
end
