%% Read Data File
data = load("abs3.csv");
fs = 1000;

time = data(:,1) / 1000;
emg = data(:,2);


%% Zero mean data
% Remove varying DC offset by filtering
window_size = 100;     

% Moving avberage filter
b = ones(1, window_size) / window_size;                              

% Apply the filter to the signal
zeroMean = filtfilt(b, 1, emg);

% remove smoothed signal from original to apply zero average
emg = emg - zeroMean;



%% Normalize Data
div = max(emg);
if (abs(min(emg)) > div)
    div = abs(min(emg));
end
emg = emg ./ div;



%% Compute the wavelet transform
[wt, frequency] = cwt(emg, fs);
colorLimit = max(max(abs(wt)));
wt_old = wt;



%% Find Indexes of the upper and lower freq limits
lowerLim = 2;
upperLim = 40;
protectFrequency = 20;

% Indexs 
low = 0;
high = 0;

for f = 1:length(frequency)
    if (frequency(f) >= lowerLim)
        low = f;
    end
    if (frequency(f) >= upperLim)
        high = f;
    end
end

mask = [zeros(high,1); ones(low - high,1); zeros(size(wt, 1) - low,1)];



%% Use a sliding window and voting system to selectively filter
numWindows = 44;
windowSize = ceil((low - high) / numWindows);

if (length(low:-windowSize:high) > numWindows)
    iter = low:-windowSize:high+windowSize;
else
    iter = low:-windowSize:high;
end

numWindows = length(iter);
fprintf("Number of Windows: %d\n", length(iter));

threshold = 0.0285;

sz = size(wt,1);

for col = 1+19:size(wt,2)-20
    % Zero everything below lowLim frequency (ideal HPF)
    for i = low:sz
        wt(i,col) = 0;
    end
    
    % Averages the pixels above the upper frequency limit
    activity = sum(sum(abs(wt(1:high,col-19:col+20)))) / (high*40);

    % Reset confidence for each column of the wavelet transform
    confidence = 0;
    
    % Sliding Window filter
    for i = iter
        % If the average activity is high, only filter up to prtoected
        % frequency to avoid destroying emg signal
        if (activity > 0.0225 && frequency(i) >= protectFrequency)
            continue;
        end

        % Average all pixels in window
        result = sum(abs(wt(i:i+windowSize,col))) / windowSize;

        % If magnitude was greater than threshold and no more than 35% of
        % the windows were empty, then apply filter
        if (result > threshold && confidence < 0.35 * numWindows)
            wt(i:i+windowSize, col) = wt(i:i+windowSize,col) * 0.0;
        else
            % If window magnitude was not sufficient increase confidence
            confidence = confidence + 1;
        end
    end
end

% Compute inverse wavelt transform to get filtered signal
filteredEMG = icwt(wt);



%% Plot EMG signals
% Plot zero mean and normalized EMG data
figure(1);
subplot(2,1,1);
plot(time, emg);
xlabel("Time (s)");
ylabel("Normalized Voltage (V)");
title("Raw Data");
ylim([-1.1 1.1]);
xlim([0.75 2.3]);


% Plot filtered data
subplot(2,1,2);
plot(time, filteredEMG);
xlabel("Time (s)");
ylabel("Normalized Voltage (V)");
title("Filtered Data");
ylim([-1.1 1.1]);
xlim([0.75 2.3]);


%% Plot the wavelet trasnforms
% Plot unfiltered cwt
figure(2);
subplot(2,1,1);
imagesc(time, frequency, abs(wt_old));
colormap("gray");
colorbar;
clim([0 colorLimit]);
title("Initial Wavelet Transform");
xlabel("Time (s)");
ylabel("frequency (Hz)");
xlim([0.75 2.3]);

% Flip y axis so 0,0 is bottom left corner 
set(gca,'YDir','normal');

% Make y axis use log scale, "frequency" returned from cwt is in log scale
set(gca, 'YScale', 'log')

% Plot filtered cwt
subplot(2,1,2);
imagesc(time, frequency, abs(wt));
colormap("gray");
colorbar;
clim([0 colorLimit]);
title("Filtered Wavelet Transform");
xlabel("Time (s)");
ylabel("frequency (Hz)");
xlim([0.75 2.3]);

% Flip y axis so 0,0 is bottom left corner 
set(gca,'YDir','normal');
set(gca, 'YScale', 'log');




segments = 9;
window = hamming(floor(length(filteredEMG / segments)));
overlap = floor(length(window) / 2);
[powerInit f] =  pwelch(emg, window, overlap, [], fs);
[powerFinal f] =  pwelch(filteredEMG, window, overlap, [], fs);

figure(10);
subplot(2,1,1);
plot(f, powerInit);
title("Welch's Periodogram of Raw EMG");
xlabel("Frequency (Hz)");
ylabel("Relative magnitude");
xlim([0 300]);

subplot(2,1,2);
plot(f, powerFinal);
title("Welch's Periodogram of Filtered EMG");
xlabel("Frequency (Hz)");
ylabel("Relative magnitude");
xlim([0 300]);