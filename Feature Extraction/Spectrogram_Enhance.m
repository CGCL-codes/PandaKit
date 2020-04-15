function outSpec = Spectrogram_Enhance(inSpec, wSpecClean, sigma)
%% Spectrogram Denoising
%Input: CSI Spectrogram, CSI Sequence
%Output: Denoised Spectrogram
%   Input:
%       inSpec - a 2-D matrix of spectrogram
%       wSpecClean - size of spectrogram de-noise window 
%       sigma - std for 'gaussian' imfilter
%   Output:
%       outSpec - the de-noised spectrogram
mdlSpecLpf = fspecial('gaussian', wSpecClean, sigma); % Build filter
outSpec = imfilter(inSpec,mdlSpecLpf); % Smoothing
end

