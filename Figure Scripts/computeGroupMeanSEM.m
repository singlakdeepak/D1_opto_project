function [CSplus_mean, CSplus_sem, CSminus_mean, CSminus_sem, CSplus_all, CSminus_all] = ...
         computeGroupMeanSEM(meanTraces, CSplusID, CSminusID)

    nMice = length(meanTraces);

    CSplus_all = [];
    CSminus_all = [];

    for i = 1:nMice
        % Grab CS+ and CS- traces
        CSplus_trace = abs(meanTraces{i}{CSplusID(i)});
        CSminus_trace = abs(meanTraces{i}{CSminusID(i)});

        % Store per-mouse traces
        CSplus_all(i,:) = CSplus_trace;
        CSminus_all(i,:) = CSminus_trace;
    end

    % Mean and SEM
    CSplus_mean  = mean(CSplus_all, 1);
    CSplus_sem   = std(CSplus_all, 0, 1) / sqrt(nMice);

    CSminus_mean = mean(CSminus_all, 1);
    CSminus_sem  = std(CSminus_all, 0, 1) / sqrt(nMice);
end
