function xf = filterpass(x,p,fs)
% filterpass 4th order Butter band-pass filter
% Copyright 2022 Jorge Ibáñez Gijón    
    Nyq = fs/2;
    [b,a]=butter(2,p./Nyq);
    xf = filtfilt(b,a,x);
end
