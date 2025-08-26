%% Trial Sequence Generator
% Parameters
numCSplus  = 90;   % Number of CS+ trials (1)
numCSminus = 100;  % Number of CS- trials (0)
numProbe   = 10;   % Number of Probe trials (2)
maxConsec  = 3;    % Maximum allowed identical consecutive trials

%% Step 1: Create initial pool of CS+ and CS- trials
trials = [ones(1, numCSplus), zeros(1, numCSminus)];

%% Step 2: Shuffle and check constraints for CS+/CS- only
isValid = false;
while ~isValid
    shuffled = trials(randperm(length(trials)));
    isValid = allConsecOK(shuffled, maxConsec);
end

%% Step 3: Insert probes evenly throughout the sequence
totalTrials = numCSplus + numCSminus + numProbe;
interval = floor((numCSplus + numCSminus) / numProbe);  % spacing within original sequence

finalSeq = shuffled;
probePositions = round(linspace(interval, length(shuffled), numProbe));

% Make sure probe positions don’t exceed the current length
probePositions(probePositions > length(finalSeq)) = length(finalSeq);

% Insert starting from the back so indices stay valid
for p = numel(probePositions):-1:1
    pos = probePositions(p);
    % If pos is at the very end, just append
    if pos > length(finalSeq)
        finalSeq = [finalSeq, 2];
    else
        finalSeq = [finalSeq(1:pos), 2, finalSeq(pos+1:end)];
    end
end

%% Step 4: Re-check constraint with probes (reshuffle if invalid)
isValid = allConsecOK(finalSeq, maxConsec);
attempts = 0;
while ~isValid && attempts < 100
    shuffled = trials(randperm(length(trials)));
    finalSeq = shuffled;
    for p = numel(probePositions):-1:1
        pos = probePositions(p);
        if pos > length(finalSeq)
            finalSeq = [finalSeq, 2];
        else
            finalSeq = [finalSeq(1:pos), 2, finalSeq(pos+1:end)];
        end
    end
    isValid = allConsecOK(finalSeq, maxConsec);
    attempts = attempts + 1;
end

if ~isValid
    warning('Could not satisfy max consecutive trial rule with probes after 100 attempts.');
end

%% Step 5: Ask user where to save
[filename, pathname] = uiputfile('*.txt', 'Save Trial Sequence As');
if isequal(filename,0) || isequal(pathname,0)
    disp('User canceled save.');
else
    outputFile = fullfile(pathname, filename);
    writematrix(finalSeq(:), outputFile, 'Delimiter', 'tab');
    disp(['Trial sequence saved to ', outputFile]);
end

%% --- Helper Function ---
function ok = allConsecOK(seq, maxConsec)
    count = 1;
    ok = true;
    for i = 2:length(seq)
        if seq(i) == seq(i-1)
            count = count + 1;
            if count > maxConsec
                ok = false;
                return;
            end
        else
            count = 1;
        end
    end
end
