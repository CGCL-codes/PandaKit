function outSpec = Spectrogram_Enhance(inSpec, inCSI, freqRange)
%Spectrogram Denoising
%Input: CSI Spectrogram, CSI Sequence
%Output: Denoised Spectrogram
    lenTargetFeature = length(inCSI(:,1));
    %freqRange = 3:80; % 1:80
    lenFreqRange = length(freqRange);
    lpfWindowSize = 5; % The size of LPF-window
    sigma = 0.8;

    lpf_mdl = fspecial('gaussian', lpfWindowSize, sigma); % Build filter

    subAbsSpecCSI = zeros(lenFreqRange,size(inSpec,2)); % Saving the result of spectral subtraction

    for i = 1:lenTargetFeature
        subAbsSpecCSI = subAbsSpecCSI + inSpec(:,:,i);
    end
    noiseRemoveSig = subAbsSpecCSI / lenTargetFeature;
    outSpec = imfilter(noiseRemoveSig,lpf_mdl,'replicate'); % Smoothing
    
    figure;
    hndl = imagesc(outSpec+eps); hndl.Parent.YDir = 'normal'; colorbar; colormap Jet;
end

