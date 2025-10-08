function [lat_CSplus_first, lat_CSplus_peak, lat_probe_first, lat_probe_peak] = computeLatency(meanTraces_all, CSplus_ID, t, threshStd, threshold)
% computeLatency - find first-crossing latency and first absolute peak post-cue
%
% Inputs:
%   meanTraces_all : 1 x N cell, each containing 1 x 3 cell of mean traces (Cue1, Cue2, Probe)
%   CSplus_ID      : N x 1 vector (1 = Cue1, 2 = Cue2) for each session
%   t              : 1 x M vector (time in seconds)
%   threshStd      : numeric, number of standard deviations above zero to count as first movement
%   threshold      : absolute threshold value
%
% Outputs:
%   lat_CSplus_first : N x 1 vector, first crossing latency for CSplus
%   lat_CSplus_peak  : N x 1 vector, latency of first absolute peak post-cue (0–2s) for CSplus
%   lat_probe_first  : N x 1 vector, first crossing latency for Probe
%   lat_probe_peak   : N x 1 vector, latency of first absolute peak post-cue (0–2s) for Probe

nSessions = numel(meanTraces_all);
lat_CSplus_first = NaN(nSessions,1);
lat_CSplus_peak  = NaN(nSessions,1);
lat_probe_first  = NaN(nSessions,1);
lat_probe_peak   = NaN(nSessions,1);

% Define post-cue window for peak detection
peakWindow = t >= 0 & t <= 2; % 0–2 s
idxPost = find(t >= 0);

for s = 1:nSessions
    cs_idx = CSplus_ID(s); 
    meanTrace_CS = meanTraces_all{s}{cs_idx};
    meanTrace_probe = meanTraces_all{s}{3}; % Probe is always 3rd

    % ------------------------------
    % First-crossing latency (SD above zero)
    % ------------------------------
    th_CS = threshStd * std(meanTrace_CS(idxPost));
    dev_CS = abs(meanTrace_CS(idxPost));
    firstIdx_CS = find(dev_CS > th_CS, 1, 'first');
    if ~isempty(firstIdx_CS)
        lat_CSplus_first(s) = t(idxPost(firstIdx_CS));
    end

    th_probe = threshStd * std(meanTrace_probe(idxPost));
    dev_probe = abs(meanTrace_probe(idxPost));
    firstIdx_probe = find(dev_probe > th_probe, 1, 'first');
    if ~isempty(firstIdx_probe)
        lat_probe_first(s) = t(idxPost(firstIdx_probe));
    end

    % ------------------------------
    % First absolute peak in 0–2 s using findpeaks
    % ------------------------------
    % CSplus
    absTrace_CS = zeros(size(meanTrace_CS)); 
    absTrace_CS(peakWindow) = abs(meanTrace_CS(peakWindow)); 
    [pks_CS, peakIdx_CS] = findpeaks(absTrace_CS, 'MinPeakHeight', threshold);
    if ~isempty(peakIdx_CS)
        lat_CSplus_peak(s) = t(peakIdx_CS(1)); % first valid peak
    else
        lat_CSplus_peak(s) = NaN; % no peak found
    end

    % Probe
    absTrace_probe = zeros(size(meanTrace_probe)); 
    absTrace_probe(peakWindow) = abs(meanTrace_probe(peakWindow)); 
    [pks_probe, peakIdx_probe] = findpeaks(absTrace_probe, 'MinPeakHeight', threshold);
    if ~isempty(peakIdx_probe)
        lat_probe_peak(s) = t(peakIdx_probe(1));
    else
        lat_probe_peak(s) = NaN;
    end
end
end
