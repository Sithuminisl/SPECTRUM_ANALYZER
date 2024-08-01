function main()
    % Parameters
    duration = 0.1;
    sampling_rate1 = 1e6;  % This for constructing the combined sinusoidal signal
    sampling_rate2 = 2020;  % This apply for the sampling (select bit higher value than nyquist frequency)
    frequencies = [100, 200, 300, 400, 800, 1000];
    amplitudes = [1, 0.5, 2, 3, 2, 1];  % Corresponding amplitudes for each frequency
    buffer_size = 16;
    overlap = 8;  % For accurate result apply overlaps at buffering

    % Generate the time vector
    t = linspace(0, duration, duration * sampling_rate1);

    % Generate the complex signal
    signal = generate_complex_signal(frequencies, amplitudes, t);

    % Plot the combined signal
    figure;
    subplot(4, 1, 1);
    plot(t, signal, 'k', 'LineWidth', 2);
    title('Combined Signal with Frequency Components');
    xlabel('Time (s)');
    ylabel('Amplitude');
    hold on;

    % Plot the sketches of frequency components
    for i = 1:length(frequencies)
        plot(t, amplitudes(i) * sin(2 * pi * frequencies(i) * t), 'DisplayName', [num2str(frequencies(i)) ' Hz']);
    end
    legend;

    % Resample the signal
    resampling_factor = round(sampling_rate1 / sampling_rate2);
    resampled_signal = signal(1:resampling_factor:end);
    t_resampled = t(1:resampling_factor:end);

    % Plot the resampled signal as discrete points
    subplot(4, 1, 2);
    stem(t_resampled, resampled_signal, 'k', 'Marker', 'none', 'BaseValue', 0);
    title('Resampled Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');

    % Apply buffering process with overlap
    buffers = buffer_signal(resampled_signal, buffer_size, overlap);

    % Apply Hamming window to each buffer
    windowed_buffers = cellfun(@(buf) apply_hamming_window(buf), buffers, 'UniformOutput', false);

    % Plot the first windowed buffer
    figure;
    subplot(1, 2, 1);
    stem(windowed_buffers{1}, 'k', 'Marker', 'none', 'BaseValue', 0);
    title('Windowed Buffer 1');
    xlabel('Sample Index');
    ylabel('Amplitude');

    % Plot the second windowed buffer
    subplot(1, 2, 2);
    stem(windowed_buffers{2}, 'r', 'Marker', 'none', 'BaseValue', 0);
    title('Windowed Buffer 2');
    xlabel('Sample Index');
    ylabel('Amplitude');

    % Compute and plot the FFT of the first windowed buffer using built-in FFT
    plot_fft(windowed_buffers{1}, sampling_rate2, 'Built-in FFT of Windowed Buffer 1');

    % Compute and plot the FFT of the second windowed buffer using built-in FFT
    plot_fft(windowed_buffers{2}, sampling_rate2, 'Built-in FFT of Windowed Buffer 2');

    % Compute and plot the FFT of the first windowed buffer using custom 16-point FFT
    custom_fft_16(windowed_buffers{1}, sampling_rate2, 'Custom FFT of Windowed Buffer 1');

    % Compute and plot the FFT of the second windowed buffer using custom 16-point FFT
    custom_fft_16(windowed_buffers{2}, sampling_rate2, 'Custom FFT of Windowed Buffer 2');
end

function signal = generate_complex_signal(frequencies, amplitudes, t)
    signal = zeros(size(t));
    for i = 1:length(frequencies)
        signal = signal + amplitudes(i) * sin(2 * pi * frequencies(i) * t);
    end
end

function buffers = buffer_signal(signal, buffer_size, overlap)
    step_size = buffer_size - overlap;
    num_buffers = floor((length(signal) - overlap) / step_size);
    buffers = cell(1, num_buffers);
    for i = 1:num_buffers
        buffers{i} = signal((i-1) * step_size + 1 : (i-1) * step_size + buffer_size);
    end
end

function windowed_buffer = apply_hamming_window(buffer)
    windowed_buffer = buffer .* hamming(length(buffer))';
end

function plot_fft(buffer, sampling_rate, title_str)
    L = length(buffer);
    Y = fft(buffer);
    P2 = abs(Y / L);
    P1 = P2(1:floor(L / 2) + 1);
    P1(2:end-1) = 2 * P1(2:end-1);
    f = sampling_rate * (0:(L/2)) / L;

    figure;
    stem(f, P1, 'k', 'Marker', 'none', 'BaseValue', 0);
    title(title_str);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
end

function custom_fft_16(buffer, sampling_rate, title_str)
    % Reorder the signal for 16-point FFT
    reordered_signal = bit_reversed_order(buffer);
    % Compute FFT stages
    W2 = exp(-2j * pi * (0:1) / 2);
    W4 = exp(-2j * pi * (0:3) / 4);
    W8 = exp(-2j * pi * (0:7) / 8);
    W16 = exp(-2j * pi * (0:15) / 16);
    two_point_fft_results = compute_two_point_ffts(reordered_signal, W2);
    four_point_fft_results = compute_four_point_ffts(two_point_fft_results, W4);
    eight_point_fft_results = compute_eight_point_ffts(four_point_fft_results, W8);
    sixteen_point_fft_results = compute_sixteen_point_ffts(eight_point_fft_results, W16);

    % Get the 16-point FFT result
    fft_result = sixteen_point_fft_results;
    L = length(fft_result);
    P2 = abs(fft_result / L);
    P1 = P2(1:floor(L / 2) + 1);
    P1(2:end-1) = 2 * P1(2:end-1);
    f = sampling_rate * (0:(L/2)) / L;

    figure;
    stem(f, P1, 'k', 'Marker', 'none', 'BaseValue', 0);
    title(title_str);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;
end

function reordered_signal = bit_reversed_order(signal)
    if length(signal) ~= 16
        error('Signal length must be 16 for 16-point FFT');
    end
    % Define the bit-reversed order for 16 points
    bit_reversed_indices = [0 8 4 12 2 10 6 14 1 9 5 13 3 11 7 15] + 1; % MATLAB uses 1-based indexing
    % Reorder the signal according to bit-reversed indices
    reordered_signal = signal(bit_reversed_indices);
end

function two_point_fft_results = compute_two_point_ffts(signal, W2)
    % Preallocate results array
    two_point_fft_results = zeros(8, 2);
    % Compute 2-point FFT for each pair
    for i = 1:8
        x0 = signal(2*i-1);
        x1 = signal(2*i);
        X0 = x0 + x1;
        X1 = x0 - x1;
        two_point_fft_results(i, :) = [X0, X1];
    end
end

function four_point_fft_results = compute_four_point_ffts(two_point_fft_results, W4)
    % Preallocate results array
    four_point_fft_results = zeros(4, 4);
    % Combine 2-point FFT results into groups for 4-point FFT
    for i = 1:4
        group = two_point_fft_results(2*i-1:2*i, :);
        four_point_fft_results(i, :) = compute_single_four_point_fft(group, W4);
    end
end

function eight_point_fft_results = compute_eight_point_ffts(four_point_fft_results, W8)
    % Preallocate results array
    eight_point_fft_results = zeros(2, 8);
    % Combine 4-point FFT results into groups for 8-point FFT
    for i = 1:2
        group = four_point_fft_results(2*i-1:2*i, :);
        eight_point_fft_results(i, :) = compute_single_eight_point_fft(group, W8);
    end
end

function sixteen_point_fft_results = compute_sixteen_point_ffts(eight_point_fft_results, W16)
    % Preallocate results array
    sixteen_point_fft_results = zeros(1, 16);
    % Combine 8-point FFT results into a single group for 16-point FFT
    group = eight_point_fft_results(:).';
    % Compute 16-point FFT for the group
    sixteen_point_fft_results = compute_single_sixteen_point_fft(group, W16);
end

function X = compute_single_four_point_fft(group, W4)
    X = zeros(1, 4);
    for k = 0:3
        X(k+1) = group(1 + mod(k, 2)) + W4(k+1) * group(3 + mod(k, 2));
    end
end

function X = compute_single_eight_point_fft(group, W8)
    X = zeros(1, 8);
    for k = 0:7
        X(k+1) = group(1 + mod(k, 4)) + W8(k+1) * group(5 + mod(k, 4));
    end
end

function X = compute_single_sixteen_point_fft(group, W16)
    X = zeros(1, 16);
    for k = 0:15
        X(k+1) = group(1 + mod(k, 8)) + W16(k+1) * group(9 + mod(k, 8));
    end
end

% Run the main function
main();