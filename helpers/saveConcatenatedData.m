% written by Andrew Weakley 8/15/2024
% changed the paths to work on this PC
addpath(genpath('../VLSE neuro/'));
clear;
clc;
close all;

[file,pathNames] = uigetfile({'/media/deeplabcutpc/Expansion/*.rhd'}); 
processName = [];
disp(processName)
fileList = dir(fullfile(pathNames,'*.rhd*'));

nFile = length(fileList); 
date = [];
startTime = [];
recName = {};
for ii=1:nFile
    if exist([pathNames fileList(ii).name],'file')==2 % add pathway 7/18/2018
        fname = fileList(ii).name(1:end-4);
        recName = [recName;{fname}];
        k = strfind(fname,'_');
        date = [date;str2num(fname(k(end-1)+1:k(end)-1))];
        startTime = [startTime;str2num(fname(k(end)+1:end))];
    else
        warning('not a file')
    end
end

[startTime,ix] = sort(startTime);
recName = recName(ix);
thisDate = date(1);
year = floor(thisDate/10000);
month = floor((thisDate-year*10000)/100);
day = thisDate-year*10000-month*100;

% Initialize variables
concatenatedData = [];
file = cell(0,0);
batchSize = 35; % Number of files per batch

% Accounts for if there are multiple OR single files
for i = 1:nFile
    % Read data from each file
    % read_Intan_RHD2000_file(file, path, filterindex);
    % read_Intan_RHD2000_file(path, file, filterindex);
    read_Intan_RHD2000_file(pathNames,[recName{i} '.rhd'],fileList(i).bytes);
    
    % Concatenate the data to the existing concatenatedData matrix
    concatenatedData = horzcat(concatenatedData, board_dig_in_data);
    % concatenatedData = horzcat(concatenatedData, board_dig_in_channels);
    % Save data every 30 files
    if mod(i, batchSize) == 0 || i == nFile
        channel_info = board_dig_in_channels;
        batchNumber = ceil(i / batchSize);
        save(fullfile(path, ['concatenatedData', num2str(batchNumber), '.mat']), 'concatenatedData','-v7.3');
        save(fullfile(path, 'channel_info.mat'), 'channel_info','-v7.3');
        disp(['concatenatedData', num2str(batchNumber), ' saved to ', fullfile(path, ['concatenatedData', num2str(batchNumber), '.mat'])]);
        concatenatedData = []; % Reset for next batch
        
    end
end

