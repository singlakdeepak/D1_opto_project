%% --- Creates main plot for the session recording --- %%
masterFig = figure;
ax1 = subplot(2,3,1);
ax2 = subplot(2,3,2);

ax3 = subplot(2,3,4);
ax4 = subplot(2,3,5);
ax5 = subplot(2,3,6);

% -- Left column --4%
% top: mean trace of Cue 1, Cue 2, and Probe
% bot: mean angular velocity at 0.2 to 0.8 s
plotAngVel_finalAll(smooth_resamp_vels, trial_arrays, trialTypes, finalFPS, [precue,postcue], doBaseline, analysisWindow, ax1);
plot_sessionMean(sessionStats, analysisWindow, ax2)

% -- Right column -- %
% top: heatmap Cue 1
% mid: heatmap Cue 2
% bot: heatmap Probe 

plotTrialHeatmaps(smooth_resamp_vels, trial_arrays, trialTypes, finalFPS, [precue, postcue], doBaseline, [ax3, ax4, ax5]);

