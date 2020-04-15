function [psd,frequency,time] = Spectrogram_Generation(inCSI,wStft,overlap,Fs,wSpecClean)
%% Spectrogram Generation
%   Input:
%       inCSI - a complex matrix with size of [packetNum, subcarrierNum]
%       wStft - window of short-time fourier transformation 
%       noverlap - window sliding stride length = wStft - noverlap
%       Fs -  sampling rate
%       wSpecClean - window of spectrogram clean function, and '0' means
%       no clean operation
%   Output:
%       psd - power spectrum density
%       frequency - frequencies at which the STFT is evaluated
%       time - time instants
[s,frequency,time] = stft(inCSI(:,1),Fs,'Window',gausswin(wStft),'OverlapLength',overlap,'FFTLength',wStft,'Centered',true);
psd = abs(s);
for i = 2:size(inCSI,2)
    [s,~,~] = stft(inCSI(:,i),Fs,'Window',gausswin(wStft),'OverlapLength',overlap,'FFTLength',wStft,'Centered',true);  
    psd = psd + abs(s);
end

%% Spectrogram De-noising
if wSpecClean > 0
    psd = Spectrogram_Enhance(psd, wSpecClean, 0.95); % Spectrogram de-noise
end

end

