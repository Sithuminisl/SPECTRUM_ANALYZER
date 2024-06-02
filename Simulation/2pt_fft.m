% generate a signal with two frequencies and compute its FFT

% generate a signal with two frequencies
Fs = 1000; % sampling frequency
t = 0:1/Fs:1; % time vector
f1 = 50; % frequency of the first sinusoid
f2 = 120; % frequency of the second sinusoid
x = 0.7*sin(2*pi*f1*t) + sin(2*pi*f2*t); % signal

% compute the FFT
N = length(x); % number of samples
X = fft(x); % compute the FFT
X = X(1:N/2+1); % consider only the first half of X
f = Fs*(0:N/2)/N; % frequency vector

% plot the signal
figure;
subplot(2,1,1);
plot(t,x);
xlabel('Time (s)');
ylabel('Amplitude');
title('Signal in the time domain');

% plot the FFT
subplot(2,1,2);
plot(f,abs(X));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Single-Sided Amplitude Spectrum of the Signal');
```