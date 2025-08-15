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
runPath = fullfile(pwd, runPath);


%% set up parameters
trialTypes = {'CS+','CS-','CS+ probe'};
precue = 1;
postcue = 5;
setBlocks = 5; % this sets the blocks of trials for plotAngVel_byCueOverT;

%% read the stim files from runPath
[selectedpaths, gratMice] = readstimfiles(runPath);
nsub = length(gratMice);

for mid = 1:nsub
    % convert to the format required for plotting
    thisM = gratMice(mid);
    thisvel = thisM.ballvelocity;
    fs = thisM.ballvelsamplingrate;
    cuelaserdelay = thisM.meancue1laserdelay;

    c1 = thisM.cue1times;
    c2 = thisM.cue2times;
    cp = thisM.probetimes;

    c1mod = struct();
    c1mod.onsetTime = c1;
    c2mod = struct();
    c2mod.onsetTime = c2;
    cpmod = struct();
    cpmod.onsetTime = cp;
    
    trial_arrays = [c1mod, c2mod,cpmod];
    
    
    plotAngVel_byCue(thisvel, trial_arrays,...
                trialTypes, fs, [precue,postcue]);

    plotAngVel_byCueOverT(thisvel, trial_arrays,...
                trialTypes, fs, cuelaserdelay,setBlocks);
end