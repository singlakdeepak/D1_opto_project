% --- Direction ---

% Initialize variables
directionMatrix = zeros(1, length(channelA)); % Initialize matrix to store directions
direction = -1; % -1 for undefined, 0 for clockwise, 1 for counterclockwise
prevA = channelA(1);
prevB = channelB(1);

% Threshold adjustment (example values, adjust as needed)
thresholdA = 0.8; % Adjust based on signal stability
thresholdB = 0.8; % Adjust based on signal stability

% Loop through the channels to determine direction
for i = 2:length(channelA)
    if prevA < thresholdA && channelA(i) >= thresholdA && prevB < thresholdB && channelB(i) < thresholdB
        direction = 0; % Clockwise
    elseif prevA < thresholdA && channelA(i) < thresholdA && prevB < thresholdB && channelB(i) >= thresholdB
        direction = 1; % Counterclockwise
    else
        direction = -1; % Encoder not moving
    end
    
    % Save direction to matrix
    directionMatrix(i) = direction;
    
    % Update previous values
    prevA = channelA(i);
    prevB = channelB(i);
end

% Initialize variables
cumulativeCWCount = 0;
cumulativeCCWCount = 0;
position = zeros(1, length(directionMatrix)); % Initialize position array

% Initialize with known initial position if applicable
initialPositionDegrees = 0; 
position(1) = initialPositionDegrees;

% Loop through the direction matrix to update counts and position
for i = 2:length(directionMatrix)
    if directionMatrix(i) == 0 % Clockwise
        cumulativeCWCount = cumulativeCWCount + 1;
    elseif directionMatrix(i) == 1 % Counterclockwise
        cumulativeCCWCount = cumulativeCCWCount + 1;
    end
    
    % Check for a change in direction before updating position
    % if directionMatrix(i) ~= -1 && directionMatrix(i) ~= directionMatrix(i - 1)
    if directionMatrix(i) ~= -1
        currentPositionDegrees = initialPositionDegrees + (cumulativeCWCount - cumulativeCCWCount) * (360 / PPR);
        position(i) = currentPositionDegrees; % Store current position
    else
        position(i) = position(i - 1); % Maintain previous position if no change in direction
    end
end

timeSeconds = (0:length(directionMatrix) - 1) / samplingFrequency;

% Plot the position graph with adjusted x-axis for time in seconds
figure()
plot(timeSeconds, position/360*circum, 'k');
xlabel('Time (seconds)');
ylabel('Position (mm)');
title('Position (mm) vs. Time');
grid on;

hold on; 
numLines = floor(max(timeSeconds) / 60); % Blue line every 60 seconds
for k = 1:numLines
    xline(k * 60, 'b', '--');
end
hold off;

numRevs = position(end)/360;

% sgolay on position data
position = resample(position, finalFPS, samplingFrequency);
position = sgolayfilt(position,3, 11);

% Raw angular velocity and resample
totalTime = length(position)/finalFPS/60;
ang_vels = diff(position);
ang_vels = [ang_vels(1),ang_vels]; % accounts for diff problem of first index not having previous value by appending
resamp_ang_vels =  ang_vels*finalFPS/360; % degrees to revolutions/second
% resamp_ang_vels = resample(ang_vels, finalFPS, samplingFrequency); % revolutions/second

% Smooth with a moving window average 
mov_window_dur = 200; % 200 ms current sweet spot
mov_window_samps = mov_window_dur*finalFPS*0.001;
smooth_resamp_vels = smooth(resamp_ang_vels, mov_window_samps,'sgolay');

newTime = 0:1/finalFPS:(60*totalTime);

%% Identifying startFrames and endFrames based on abs(acceleration)
if get_startendFrames == 1
startFrames = [];
endFrames = [];
inBout = false;

% --- 1. get acceleration, convert to magnitude, and determine frames when acceleration is 0 or not ---
accl_this_ses = [0;diff(smooth_resamp_vels)*finalFPS];
accl = abs(accl_this_ses); % more sensitive to spikes
accl_round = round(accl, decimal_round); % round to avoid floating decimals
downTimeFrames = downTime*finalFPS; % convert to frames

is_zero = abs(accl_round) < accl_threshold; % creates array to find when accl_round == 0; 0 = not zero, 1 = is zero
is_one = (accl_round > accl_threshold); % creates array to find when accl_round > 0; 0 = zero, 1 = not zero

% --- 2. filter small ball jitters < walk_bout_min_dur ---
i = 1;  % Initialize index for main loop
while i <= length(is_one) 
    if is_one(i) == 1
        % Found start of a potential movement bout
        startidx = i;
        zero_count = 0;  % Counter for consecutive 0s
        j = i + 1;       % Secondary index to look ahead

        % Search forward to find when the bout ends (based on 0s)
        while j <= length(is_one)
            if is_one(j) == 0
                zero_count = zero_count + 1;  % Count consecutive 0s
            else
                zero_count = 0;  % Reset counter if we hit a 1 again
            end

            % If we've found finalFPS/2 consecutive 0s, declare end of bout
            if zero_count >= round(finalFPS/2)
                endidx = j - zero_count;  % Last 1 before the stretch of 0s
                break;
            end
            j = j + 1;  % Advance look-ahead index
        end

        % If no long enough 0-gap is found, assume end of data is end of bout
        if j > length(is_one)
            endidx = length(is_one);
        end

        % Check if the bout is too short to be valid
        if (endidx - startidx + 1) < walk_bout_min_dur * finalFPS
            % If too short, zero it out in the acceleration and movement indicators
            accl_round(startidx:endidx) = 0;
            is_one(startidx:endidx) = 0;
        end

        % Move to next index after this bout
        i = endidx + 1;

    else
        % If current index is not a 1, just move forward
        i = i + 1;
    end
end

% --- 3. find intervals of downTime that's 0 acceleration ---

% Label connected components of 1s
labels = bwlabel(is_zero);

% Get properties of each region
props = regionprops(labels, 'Area', 'PixelIdxList');

% Filter regions with more than downTimeFrames 
long_intervals = [];
for i = 1:length(props)
    if props(i).Area > downTimeFrames
        long_intervals = [long_intervals; props(i).PixelIdxList(1), props(i).PixelIdxList(end)];
    end
end

% if ~is
startFrames = long_intervals(1:end-1,2);
endFrames = long_intervals(2:end,1);

% --- 4. change startFrames to when acceleration > threshold (0.25), also checks false bout identification ---

new_startFrames = []; % Create temp startFrames
new_endFrames = []; % Create temp endFrames
for i = 1:length(startFrames)
    idx = startFrames(i);
    max_idx = endFrames(i);  % limit search to within the bout

    % Search within the bout for the first time accel > threshold
    while idx <= max_idx && accl_round(idx) <= accl_threshold
        idx = idx + 1;
    end

    % Only save the bout if threshold is crossed before end of bout
    if idx <= max_idx
        new_startFrames(end+1) = idx;         % use threshold-adjusted start
        new_endFrames(end+1) = endFrames(i);  % keep original end
    else
        % skip this bout entirely
        % (nothing is appended to new_* arrays)
    end
end

% Replace old start frames with the threshold-adjusted ones
startFrames = new_startFrames';
endFrames = new_endFrames';

% --- 5. fine-tune adjustment of startFrames to start at actual walking bout start (previously would sometimes start a little after start of walking) ---

required_count = round(finalFPS);  % Number of consecutive low values required
new_startFrames = [];

for i = 1:length(startFrames)
    idx = startFrames(i);  % Starting point
    count = 0;             % Counter for low-accel values
    back_idx = idx;        % Working index for backward search

    % Move backward through accl
    while back_idx > 1
        if accl(back_idx) < accl_threshold
            count = count + 1;
            if count >= required_count
                break;
            end
        else
            count = 0;  % Reset if streak breaks
        end
        back_idx = back_idx - 1;
    end

    % If we found a valid segment, use the last high point *before* the streak
    if count >= required_count
        new_startFrames(end+1) = back_idx + required_count;  % move forward to last high point
    else
        new_startFrames(end+1) = startFrames(i);  % fallback: keep original
    end
end

% Replace old startFrames with adjusted ones
startFrames = new_startFrames';

% --- 6. final rejection of bouts with smoothed velocity below threshold of 0.1 ---

valid_startFrames = [];
valid_endFrames = [];

for i = 1:length(startFrames)
    % Extract velocity segment for this bout
    bout_vels = smooth_resamp_vels(startFrames(i):endFrames(i));

    % Compute mean velocity (absolute to avoid direction canceling)
    mean_bout_vel = mean(abs(bout_vels));

    % Only keep bouts above threshold
    if mean_bout_vel >= final_vel_threshold
        valid_startFrames(end+1,1) = startFrames(i);
        valid_endFrames(end+1,1)   = endFrames(i);
    end
end

% Replace old start/endFrames with filtered ones
startFrames = valid_startFrames;
endFrames   = valid_endFrames;
%% Calculate number of bouts per minute

% Initialize the minute-by-minute bout count array
totalDuration = length(smooth_resamp_vels) / finalFPS; % Total duration in seconds
numMinutes = ceil(totalDuration / 60); % Number of minutes in the data
boutsPerMinute = zeros(numMinutes, 1);

% Calculate the start time of each bout in seconds
startTimes = startFrames / finalFPS;

% Count the number of bouts in each minute
for i = 1:numMinutes
    % Find bouts that start within the current minute
    boutsPerMinute(i) = sum(startTimes >= (i-1)*60 & startTimes < i*60);
end

%% Display number of bouts and average walking bout length

%  Convert indexes to actual times in seconds
startTimes = startFrames/finalFPS;
endTimes = endFrames/finalFPS;

% Accumulator to store time and counter to count
sumTimeDiff = 0; % accumulator

% Checks length of time for each bout
for i = 1:length(startTimes)
    timeDiff = endTimes(i) - startTimes(i);
    sumTimeDiff = sumTimeDiff + timeDiff;
end

%% Displays important statistics for online google sheets
disp(['Number of total revolutions: ', num2str(numRevs)]);
disp(['Number of bouts accepted: ', num2str(length(startFrames))]);
disp(['Average length of walking bouts: ', num2str(sumTimeDiff/length(startFrames)), ' seconds.']);
disp(['Avg number of bouts per minute: ', num2str(mean(boutsPerMinute))]); disp(' ');

%% Plot bouts overlayed with mean and SD

% Set window before and after startTimes
sample_window = round(onset * finalFPS);

% Overlay walking bouts on top of each other if there exists walking bouts
if length(endFrames) >= 3
    figure()
    total_bout_vel = [];
    total_bout_accl = [];
    time_vector = [];
    hold on;

    for i = 2:length(startFrames) % Can set i = 2:... to ignore first bout which can be caught while in the middle of walking
        onset_index = startFrames(i);
        start_index = onset_index - sample_window;
        end_index = onset_index + sample_window;

        if plotting_speed
            bout_vel = abs(smooth_resamp_vels(start_index:end_index) * circum); % Convert to speed in mm/s
            bout_accl = [0; diff(bout_vel)];
        else
            bout_vel = smooth_resamp_vels(start_index:end_index) * circum; % Convert to linear velocity in mm/s
            bout_accl = [0; diff(bout_vel)];
        end
        total_bout_vel = [total_bout_vel; bout_vel'];
        total_bout_accl = [total_bout_accl; bout_accl'];

        time_vector = (start_index:end_index) / finalFPS - (onset_index / finalFPS);
    end 
    
    plot(time_vector, total_bout_vel, 'Color', [0.7, 0.7, 0.7]);

    % Calculate mean and std of total_bout_vel
    avg_bout_vel = mean(total_bout_vel);
    avg_bout_accl = mean(total_bout_accl);
    std_bout_vel = std(total_bout_vel);
    
    % Calculate standard error and plot it
    n = size(total_bout_vel, 1); % Number of walking bouts
    stderr_bout_vel = std_bout_vel / sqrt(n);

    fill([time_vector, fliplr(time_vector)], ...
    [avg_bout_vel + stderr_bout_vel, fliplr(avg_bout_vel - stderr_bout_vel)], ...
    'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

    % Plot average bout data in mm/s
    plot(time_vector, avg_bout_vel, 'k');
    
    % Additional plot settings
    xline(0, '--k'); 
    xlim([time_vector(1) time_vector(end)]);
    flat_vals = total_bout_vel(:); 
    ylims = prctile(flat_vals, [1 98]); % removes outliers below lowest 1% and top 98%
    ylim(ylims);
    yline(0, 'k');
    xlabel('Time (seconds)');

    if plotting_speed % Change ylabel if plotting speed or velocity
        ylabel('Walking speed (mm/s)');
    else
        ylabel('Linear velocity (mm/s)');
    end
    title('Onset of Walking Bouts');
else
    disp(' '); disp('No bouts identified so no plot');
end
end
%% Debugging extractSignals 

% --- debug params ---
debug = false; % set to true to debug with plots
bouts = 1:14;
onset2 = 10;

% --- debug plots of smooth_resamp_vels, accl, and accl_round ---

if debug
    for b = bouts
        % Ensure index doesn't exceed array size
        if b > length(startFrames) || b > length(endFrames)
            break;
        end
    
       
        start_idx = startFrames(b);
        end_idx = endFrames(b);
    
        % Define the plotting region (±finalFPS around the bout)
        region_start = max(1, start_idx - onset2*finalFPS);
        region_end = min(length(accl_round), end_idx + onset2*finalFPS);
        region = region_start:region_end;
    
        % Create figure for this bout
        figure;
    
        subplot(3,1,1)
        plot(region, smooth_resamp_vels(region))
        xline(start_idx, '--r', 'Start');
        xline(end_idx, '--g', 'End');
        title(['Smoothed Velocity - Bout ' num2str(b)])
    
        subplot(3,1,2)
        plot(region, accl(region))
        xline(start_idx, '--r');
        xline(end_idx, '--g');
        title(['Acceleration - Bout ' num2str(b)])
    
        subplot(3,1,3)
        plot(region, accl_round(region))
        xline(start_idx, '--r');
        xline(end_idx, '--g');
        title(['Rounded Acceleration - Bout ' num2str(b)])
    end
end

