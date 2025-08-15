% Make sure the VLSE Neuro functions are in workspace. 
clear all;
clc;

% have this function at the start of every script that runs analysis.
setOSDetails;

%%
warning off
scrsz=get(0,'ScreenSize');
if (osid == 1)
    runPath = '..\';
elseif (osid ==2)
    runPath = '../';
end
selectedpaths=uipickfiles('FilterSpec',...
                    runPath);  %prompts to pick subjects.

for subjectind = 1:length(selectedpaths)

    if length(subjects) > 1
        disp(['subject ' num2str(subjectind) '.'])
    end
    
    emousedir = subjects{subjectind};
    
    tic

end