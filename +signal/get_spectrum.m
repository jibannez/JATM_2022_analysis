function [power, f] = get_spectrum(x,fs)
% get_spectrum Compute 1D signal power based on fourier decomposition
% Copyright 2022 Jorge Ibáñez Gijón
    y = fft(x);
    n = length(x);          % number of samples
    f = (0:n-1)*(fs/n);     % frequency range
    power = abs(y).^2/n;    % power of the DFT

    plot(f,power)
    xlabel('Frequency')
    ylabel('Power')
end
