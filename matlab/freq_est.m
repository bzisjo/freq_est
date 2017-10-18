close all
clear all
clc
%% Some parameters
Fs2 = 16e6;
downrate = 200;
Fs = downrate * Fs2;
dT = 1/Fs;
RF_ampl = 2;
LO_ampl = 1;
RF_freq = 2.440e8;
LO_freq = RF_freq + 2.5e6;


% Generate some tone at RF
N = 1e6;
t = 0:dT:(N-1)*dT;
MSK = RF_ampl * sin(2*pi*RF_freq*t);
LO = LO_ampl * sin(2*pi*LO_freq*t)+LO_ampl;
IF = LO .* MSK;

% Remove high frequency mixing content
[b,a] = butter(5,40e6/(Fs/2));
IF_filt = filter(b,a,IF);

% Downsample to 16 MHz before further processing
Iout_un = IF_filt(1:downrate:end);
t = t(1:downrate:end);

%% Quantize
Iout = round(6.5*Iout_un);