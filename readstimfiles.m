function [selectedpaths, gratMice] = readstimfiles(runPath)
% this file reads all the stim files and stores them in a struct array. 
    selectedpaths=uipickfiles('FilterSpec',...
                        runPath);  %prompts to pick subjects.
    gratMice = [];
    for subjectind = 1:length(selectedpaths)
    
        if length(subjects) > 1
            disp(['subject ' num2str(subjectind) '.'])
        end
        
        stimulidir = selectedpaths{subjectind};
    
        % load the stimuli file
        load(fullfile(stimulidir, 'stimuli.mat'));
        
        gratMice = [gratMice, stimuli];
    end
    
end