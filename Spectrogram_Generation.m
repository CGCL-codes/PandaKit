function orgAbsSpecCSI = Spectrogram_Generation(inCSI, lenStftWindow,noverlap,Fs)
%Spectrogram Generation
%Input: CSI Sequence£¬STFT Window Size£¬Overlap Size£¬Sample Frequency
%Output: CSI Spectrogram
    lenTargetFeature = length(inCSI(:,1));
    cyclicalFrequency = lenStftWindow;
    freqRange = 1:80; % 1:80
    lenFreqRange = length(freqRange);
    [s,~,~,~,~,~] = spectrogram(inCSI(1,:),lenStftWindow,noverlap,cyclicalFrequency,Fs);
    if lenFreqRange > size(s,1)
        freqRange = 1:size(s,1);
        lenFreqRange = length(freqRange);
    end
    orgAbsSpecCSI = zeros(lenFreqRange,size(s,2),lenTargetFeature);

    for i = 1:lenTargetFeature
        [s,~,~] = spectrogram(inCSI(i,:),lenStftWindow,noverlap,cyclicalFrequency,Fs);

        orgAbsSpecCSI(:,:,i) = abs(s(freqRange,:));
    end
    %------ spectrum ------%
    hndl = imagesc(10*log10(orgAbsSpecCSI(:,:,1)+eps)); hndl.Parent.YDir = 'normal'; colorbar; colormap Jet;
end

