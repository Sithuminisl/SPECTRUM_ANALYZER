function main
    % Parameters
    num_components = 10;       % number of sinusoidal components
    duration = 0.00001;        % duration of the signal in seconds
    sampling_rate = 350e6;     % sampling rate in Hz
    frequencies = [200, 500, 800, 1e3, 5e3, 15e3, 100e3, 200e3, 300e3, 500e3];
    buffer_size = 500;         % buffer size
    num_buffers_to_plot = 6;   % number of buffers to plot
    
    % Generate complex signal
    [t, signal, components] = generate_complex_signal(frequencies, duration, sampling_rate);
    
    % Plot all sinusoidal components and the combined signal
    figure;
    hold on;
    for i = 1:length(components)
        plot(t, components{i}, '--', 'DisplayName', sprintf('Component %d', i));
    end
    plot(t, signal, 'k', 'LineWidth', 2, 'DisplayName', 'Combined Signal');
    title('Sinusoidal Components and Combined Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend show;
    grid on;
    hold off;

    % Apply buffering process
    buffers = buffer_signal(signal, buffer_size);

    % Plot only the first six buffers
    figure;
    for i = 1:min(num_buffers_to_plot, length(buffers))
        subplot(3, 2, i);
        plot(buffers{i}, 'k');
        title(sprintf('Buffer %d', i));
        xlabel('Sample Index');
        ylabel('Amplitude');
        grid on;
    end
    tight_layout();

    % Sample each buffer at Nyquist rate and combine sampled buffers
    sampled_buffers = cell(1, length(buffers));
    for i = 1:length(buffers)
        buffer = buffers{i};
        num_samples = floor(length(buffer) / 2);  % Nyquist rate sampling
        sampled_buffer = buffer(1:num_samples:end);
        sampled_buffers{i} = sampled_buffer;
    end
    sampled_signal = cell2mat(sampled_buffers');

    % Plot the final sampled signal
    figure;
    plot(sampled_signal, 'k');
    title('Final Sampled Signal (Nyquist Rate)');
    xlabel('Sample Index');
    ylabel('Amplitude');
    grid on;
    
    % Apply Hamming window to each buffer
    windowed_buffers = cellfun(@apply_hamming_window, buffers, 'UniformOutput', false);

    % Sample each buffer at Nyquist rate
    sampled_buffers = cell(1, length(windowed_buffers));
    for i = 1:length(windowed_buffers)
        buffer = windowed_buffers{i};
        num_samples = floor(length(buffer) / 2);  % Nyquist rate sampling
        sampled_buffer = buffer(1:num_samples:end);
        sampled_buffers{i} = sampled_buffer;
    end
    sampled_signal = cell2mat(sampled_buffers');

    % Plot the final sampled signal with Hamming window
    figure;
    plot(sampled_signal, 'k');
    title('Final Sampled Signal (Nyquist Rate) with Hamming Window and Sampling');
    xlabel('Sample Index');
    ylabel('Amplitude');
    grid on;

    % Plot each buffer along with the applied Hamming window
    figure;
    for i = 1:min(num_buffers_to_plot, length(windowed_buffers))
        subplot(3, 2, i);
        plot(buffers{i}, 'b', 'DisplayName', 'Original Buffer');
        hold on;
        plot(windowed_buffers{i}, 'r', 'DisplayName', 'Buffer with Hamming Window');
        title(sprintf('Buffer %d', i));
        xlabel('Sample Index');
        ylabel('Amplitude');
        legend;
        grid on;
    end
    tight_layout();
    
    % Step 1: Generate a signal with multiple frequency components
    Fs = 1000;  % Sampling frequency
    T = 1;  % Duration of signal in seconds
    t = 0:1/Fs:T-1/Fs;  % Time vector
    frequencies = [50, 120];  % Frequencies of the sine waves in Hz
    signal = sum(sin(2 * pi * frequencies' * t), 1);

    % Step 2: Divide the signal into chunks (each containing 8 points)
    chunk_size = 8;
    num_chunks = floor(length(signal) / chunk_size);
    chunks = mat2cell(signal(1:num_chunks*chunk_size), 1, repmat(chunk_size, 1, num_chunks));

    % Step 3: Compute the FFT manually for each chunk and extract dominant frequency components
    final_freqs = [];
    final_magnitudes = [];

    for i = 1:length(chunks)
        chunk = chunks{i};
        n = length(chunk);
        k = 0:n-1;
        T = n / Fs;
        frq = k / T;   % Two-sided frequency range
        frq = frq(1:floor(n/2));  % One-sided frequency range

        % Compute FFT manually
        Y = zeros(1, floor(n/2));
        for m = 1:length(Y)
            Y(m) = sum(chunk .* exp(-1j * 2 * pi * k * (m-1) / n));
        end

        % Convert each point in the chunk to its corresponding frequency
        freqs = frq * Fs / n;

        % Find the two highest peaks in the magnitude spectrum
        [sorted_mags, sorted_indices] = sort(abs(Y), 'descend');
        dominant_freqs = freqs(sorted_indices(1:2));
        dominant_mags = sorted_mags(1:2);

        % Add the dominant frequency components to the final output
        final_freqs = [final_freqs, dominant_freqs];
        final_magnitudes = [final_magnitudes, dominant_mags];
    end

    % Step 4: Plot the final frequency spectrum
    figure;
    stem(final_freqs, final_magnitudes, 'filled');
    title('Final Frequency Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
end

function [t, signal, components] = generate_complex_signal(frequencies, duration, sampling_rate)
    t = linspace(0, duration, floor(duration * sampling_rate));
    signal = zeros(size(t));
    components = cell(1, length(frequencies));

    for i = 1:length(frequencies)
        component = sin(2 * pi * frequencies(i) * t);
        signal = signal + component;
        components{i} = component;
    end
end

function buffers = buffer_signal(signal, buffer_size)
    num_buffers = floor(length(signal) / buffer_size);
    remainder = mod(length(signal), buffer_size);
    if remainder ~= 0
        % Pad the signal with zeros to ensure the last buffer is complete
        signal = [signal, zeros(1, buffer_size - remainder)];
        num_buffers = num_buffers + 1;
    end
    buffers = mat2cell(signal, 1, repmat(buffer_size, 1, num_buffers));
end

function windowed_buffer = apply_hamming_window(buffer)
    windowed_buffer = buffer .* hamming(length(buffer))';
end

function tight_layout()
    % Adjust subplots to fit into figure window without overlapping
    ha = get(gcf, 'Children');
    N = length(ha);
    M = ceil(sqrt(N));
    for i = 1:N
        pos = get(ha(i), 'Position');
        pos(1) = mod(i-1, M) / M;
        pos(2) = 1 - ceil(i / M) / M;
        pos(3) = 1 / M;
        pos(4) = 1 / M;
        set(ha(i), 'Position', pos);
    end
end

% Run the main function
main;
