function output = preprocessSuitInFit(csi,s)
%% Input validation
%   - The parameters have been validated in preprocess()
%   - Only validating the suit name whether it is 'InFit'
%
%   Input description:
%   csi - a complex matrix with size of [packetNum, subcarrierNum*links]
%   s - a struct of processing suite
assert(contains(s.suite,'InFit','IgnoreCase',true),'The suite of preprocessSuitInFit() should be InFit');

%% Conjugate multiplication for phase calibration
if contains(s.device,'iwl5300','IgnoreCase',true)
    subCarrierNum = 30;
end
csiCM = Phase_Calibration_ConjuMulti(csi,subCarrierNum);
if isempty(csiCM)
    csiCM = csi;
end

%% Noise Filtering using Butterworth Filter
if contains(s.filter,'bpf')
    csiFilter = BPF(csiCM,s.fc,s.fs); % Band-pass filter
elseif contains(s.filter,'lpf')
    csiFilter = LPF(csiCM,s.fc,s.fs); % Low-pass filter
elseif contains(s.filter,'hpf')
    csiFilter = HPF(csiCM,s.fc,s.fs); % High-pass filter
end

%% PCA-based denoising
csiPCA = PCA(csiFilter,s.pca);

%% Spectrogram Generation
[output.psd,output.frequency,output.time] = Spectrogram_Generation( ...
    csiPCA, s.stft(1), s.stft(1)-s.stft(2), s.fs, s.stft(3));
end

