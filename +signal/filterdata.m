function xf = filterdata(x, cutoff, nyqfreq, band)
% filterdata 4th order Butter band-pass filter
% Copyright 2022 Jorge Ibáñez Gijón
    %Raoul's parameters
    if nargin<4, band = 'low'; end
    if nargin<3, nyqfreq = 500; end
    if nargin<2, cutoff  = 12 ; end
    
    %4th order Butter low-pass filter
    [b,a]=butter(4,cutoff/nyqfreq,band);
    xf = filtfilt(b,a,x);
end
