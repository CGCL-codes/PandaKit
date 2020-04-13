function output = Preprocessing_Suit_Widance(csi,suit)

%% Antenna Selection
link_num = floor(size(csi,1)/suit.SUBCARRIER);
if suit.ANTSEL
    max_mean_link = 0;
    max_mean_link_id = 0;
    max_mean_link_value = 0;
    max_var_link = 0;
    max_var_link_id = 0;
    max_var_link_value = 0;
    for li = 1:link_num
        link = csi((li-1)*suit.SUBCARRIER+1:li*suit.SUBCARRIER,:);
        avg_mean = mean(mean(abs(link),2));
        avg_var = mean(var(abs(link),[],2));

        if avg_mean > max_mean_link_value && max_var_link_id ~= li
            max_mean_link = link;
            max_mean_link_id = li;
            max_mean_link_value = avg_mean;
        end

        if avg_var > max_var_link_value && max_mean_link_id ~= li
            max_var_link = link;
            max_var_link_id = li;
            max_var_link_value = avg_var;
        end
    end
else
    max_mean_link = csi((3-1)*suit.SUBCARRIER+1:3*suit.SUBCARRIER,:);
    max_var_link = csi((2-1)*suit.SUBCARRIER+1:2*suit.SUBCARRIER,:);
end

%% Conjugate Multiplication
cm_csi = max_mean_link .* conj(max_var_link);

%% Noise Filtering using Butterworth Filter
if strcmp(suit.FILTER,'BPF')
    csi_bandpass = bandpass(cm_csi',suit.PERMITBAND,suit.FS); % Band-pass filter, we select the speed between 0.15m/s and 2.8m/s
elseif strcmp(suit.FILTER,'LPF')
    csi_bandpass = lowpass(cm_csi',suit.PERMITBAND,suit.FS); % Low-pass filter, we select the speed under 2.8m/s
end

%% PCA-based denoising
lenChunk = floor(suit.FS*suit.WINPCA);
totalLength = length(csi_bandpass); % Total length of received signal
numChunk = floor( totalLength / lenChunk); % The number of chunks, the last one won't be considered

csi_pca = zeros(numChunk*lenChunk,size(csi_bandpass,2));

for i = 1:numChunk
    % Create total score sequences
    chunk = csi_bandpass(i*lenChunk-lenChunk+1:i*lenChunk,:);       
    [~,score,~,~,~] = pca(chunk); % PCA
    csi_pca(i*lenChunk-lenChunk+1:i*lenChunk,:) = score;
end

% The algorithm above makes sure that the big window has moved to the end.
% dc_approx has no need to update
% Only ensure that numChunk*lenChunk+1 is smaller than totalLength
if numChunk*lenChunk+1 < totalLength
    chunk = csi_bandpass(numChunk*lenChunk+1:totalLength,:);
    [~,score,~,~,~] = pca(chunk); % PCA
    csi_pca(numChunk*lenChunk+1:totalLength,:) = score;
end

%% Spectrogram Generation
[s,frequency,time] = stft(csi_pca(:,1),suit.FS,'Window',gausswin(suit.WINSTFT),'OverlapLength',suit.OVERLAP,'FFTLength',suit.FS,'Centered',true);
psd = zeros(size(s)); % To store Power Spectrul Density (PSD)
for i = suit.PCC
    [s,~,~] = stft(csi_pca(:,i),suit.FS,'Window',gausswin(suit.WINSTFT),'OverlapLength',suit.OVERLAP,'FFTLength',suit.FS,'Centered',true);
    psd = psd + abs(s) / length(suit.PCC);
end

output = {psd,frequency,time};
end

