function output = preprocessSuitCarm(csi,s)
%% Input validation
%   - The parameters have been validated in preprocess()
%   - Only validating the suit name whether it is 'InFit'
%
%   Input description:
%   csi - a complex matrix with size of [packetNum, subcarrierNum*links]
%   s - a struct of processing suite
assert(contains(s.suite,'CARM','IgnoreCase',true),'The suite of preprocessingSuitCarm() should be CARM');

%% CARM only deals with the amplitude of csi
csiAmp2 = abs(csi).^2;

%% Static noise removing
csiAmp2DcRemove = DC_Remove(csiAmp2,s.pca(1)*4,s.pca(1));

%% PCA-based denoising
csiPCA = PCA(abs(sqrt(csiAmp2DcRemove)),s.pca);

%% Spectrogram Generation
[output.psd,output.frequency,output.time] = Spectrogram_Generation( ...
    csiPCA, s.stft(1), s.stft(1)-s.stft(2), s.fs, s.stft(3));
end

