%% Creates .txt file with each row designated to a single 0, 1, or 2 %%
% includes randomizing x number of CS+ (1) trials and y number CS- (0) trials
% adds probe trials (2) after every 10 CS+ and CS- trials
% makes sure no more than 3 consecutive same trials

%% Trial Sequence Generator
% Parameters
numCSplus  = 100;  % Number of CS+ trials (1)
numCSminus = 100;  % Number of CS- trials (0)
probeEvery = 13;  % Insert a probe (2) after every N CS+ or CS- trials
maxConsec  = 3;   % Maximum allowed identical consecutive trials

%% Step 1: Create initial pool of CS+ and CS- trials
trials = [ones(1, numCSplus), zeros(1, numCSminus)];

%% Step 2: Shuffle and check constraints
isValid = false;
while ~isValid
    shuffled = trials(randperm(length(trials)));
    isValid = allConsecOK(shuffled, maxConsec);
end

%% Step 3: Insert probe trials after every 'probeEvery' CS+/CS- trials
finalSeq = [];
counter = 0;
for t = shuffled
    finalSeq(end+1) = t;
    counter = counter + 1;
    if counter == probeEvery
        finalSeq(end+1) = 2;
        counter = 0;
    end
end

%% Step 4: Ask user where to save
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
