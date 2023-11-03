%% Spurious Free Dynamic Range

close all; clear; clc;

% Compiling the mex file of the fractional resampler while ensuring that
% the files are in the same folder.
% 
% Refer to: https://github.com/alphanumericslab/OSET/tree/staging/cpp/fractional-resampler

mex resampler_mex.cpp resampler.cpp

%% Create input signals

f = 0:pi:5000; % range of frequencies of the signals, with non-integer step size to prevent harmonics
duration = 30.0; % Duration of each sinusoid in seconds
fs_in=11025; % Sample rate in Hz (adjust as needed)

N = round(fs_in * duration); % number of data points
n = 0 : N - 1;  % data point vector

fs_out = 4000; % Output signal sample rate to be adjusted

% Initialize lists to hold SFDR values
sf_in=zeros(1,length(f));sf_o2=zeros(1,length(f));sf_o3=zeros(1,length(f));sf_o4=zeros(1,length(f));
% Initialize lists to hold Largest Spur power values
spur_pow_in=zeros(1,length(f));spur_pow_o2=zeros(1,length(f));spur_pow_o3=zeros(1,length(f));spur_pow_o4=zeros(1,length(f));
% Initialize lists to hold signal power values
sig_pow_in=zeros(1,length(f));sig_pow_o2=zeros(1,length(f));sig_pow_o3=zeros(1,length(f));sig_pow_o4=zeros(1,length(f));

index=0;

for f_in = f
    index=index+1;

    in_signal = sin(2*pi*n*f_in/fs_in); % Create input signals
    [r_in,pow_spur_in,]=sfdr(in_signal,fs_in);
    sf_in(index)=r_in;
    spur_pow_in(index)=pow_spur_in;
    sig_pow_in(index)=pow2db(rms(in_signal)^2);

    outputSignal_o2 = resampler_mex(in_signal, fs_out/fs_in, 2); % create resampled signal (order 2)
    [r_o2,pow_spur_o2,]=sfdr(outputSignal_o2,fs_out);
    sf_o2(index)=r_o2;
    spur_pow_o2(index)=pow_spur_o2;
    sig_pow_o2(index)=pow2db(rms(outputSignal_o2)^2);

    outputSignal_o3 = resampler_mex(in_signal, fs_out/fs_in, 3);
    [r_o3,pow_spur_o3,]=sfdr(outputSignal_o3,fs_out);
    sf_o3(index)=r_o3;
    spur_pow_o3(index)=pow_spur_o3;
    sig_pow_o3(index)=pow2db(rms(outputSignal_o3)^2);

    outputSignal_o4 = resampler_mex(in_signal, fs_out/fs_in, 4);
    [r_o4,pow_spur_o4,]=sfdr(outputSignal_o4,fs_out);
    sf_o4(index)=r_o4;
    spur_pow_o4(index)=pow_spur_o4;
    sig_pow_o4(index)=pow2db(rms(outputSignal_o4)^2);
end

figure(1)
plot(f,sf_in,f,sf_o2,f,sf_o3,f,sf_o4)
legend('Original Signal','Order 2 Resampled Signal','Order 3 Resampled Signal','Order 4 Resampled Signal')
title(sprintf('Comparison of SFDR for %.2f Hz and %.2f Hz fractional resampled signals',fs_in,fs_out))
xlabel('Frequency')
ylabel('SFDR in db')

figure(2)
plot(f,spur_pow_in,f,spur_pow_o2,f,spur_pow_o3,f,spur_pow_o4)
legend('Original Signal','Order 2 Resampled Signal','Order 3 Resampled Signal','Order 4 Resampled Signal')
title(sprintf('Comparison of Power of Spurs for %.2f Hz and %.2f Hz fractional resampled signals',fs_in,fs_out))
xlabel('Frequency')
ylabel('Power of largest spur in dB')

figure(3)
plot(f,sig_pow_in,f,sig_pow_o2,f,sig_pow_o3,f,sig_pow_o4)
legend('Original Signal','Order 2 Resampled Signal','Order 3 Resampled Signal','Order 4 Resampled Signal')
title(sprintf('Comparison of Signal powers for %.2f Hz and %.2f Hz fractional resampled signals',fs_in,fs_out))
xlabel('Frequency')
ylabel('Total signal power in dB')
