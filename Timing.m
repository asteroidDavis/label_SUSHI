function [timing] = Timing(npts, SPS)
%Timing - Create a timing struct with everything necassary for a frequency
%spectrum plot
%PARAMETERS
%   npts - number of points in the time vector
%   SPS - samples per second,sampling frequency
%Returns a struct with
%   deltaF - change in frequency between elements of the frequecy vector
%   dt - change in time between elements of the time vector
%   F - the frequency vector
%   Fn - nyquist frequency
%   npts - number of points in the time vector
%   SPS - samples per second
%   Tmax - the highest time element in the time vector
%   t - the time vector
%EXAMPLE
%   timing = Timing(512, 256);
%   %generate a wave
%   wave = sin(2*pi*timing.t);
%VERSION
%   0.1(First release)

%parameters
timing.npts = npts;
timing.SPS = SPS;
%calculate the rest of the members
%nyquist frequency is half the sampling frequency
timing.Fn = timing.SPS/2;
%the time of each sample is the inverser of the sampling frequency
timing.dt = 1/timing.SPS;
%max time in the time vector
timing.Tmax = timing.npts*timing.dt-timing.dt;
%change in frequency between elements of the frequency vector is the
%inverse of the max time in the time vector
timing.deltaF = 1/timing.Tmax;

%time vector
timing.t = [0:timing.dt:timing.Tmax]';
%frequency vector
timing.F = [0:timing.deltaF:timing.Fn , -timing.Fn:...
    timing.deltaF:0]';
end

