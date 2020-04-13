function output = Preprocessing_Suit_CARM(csi,suit)
%% Useless parameters
% FILTER, PERMITBAND, ANTSEL

%% CARM only deals with the amplitude of csi
csi_amp = abs(csi');

%% Computing the initial approximate DC component
lenBigWindow = floor(suit.FS*suit.WINBIG);
endIdxBIGWIN = lenBigWindow; % The end point of the big window
dc_approx = mean(csi_amp(1:endIdxBIGWIN,:).^2); % Computing the static components

%% Initializing the record space
totalLength = length(csi_amp); % Total length of received signal
csi_pca = zeros(totalLength,size(csi_amp,2));

%% Calculating the number of complete chunks in the received stream
lenChunk = floor(suit.FS*suit.WINPCA);
numChunk = floor( totalLength / lenChunk); % The number of chunks, the last one won't be considered

%% Removing the static noise and PCA-based denoising by chunks
for i = 1:numChunk
    % Remove the DC component only when the current chunk is in the big window
    if i*lenChunk > endIdxBIGWIN
        endIdxBIGWIN = endIdxBIGWIN + lenChunk; % Moving the big window
        if endIdxBIGWIN > totalLength
            endIdxBIGWIN = totalLength; % Avoiding the illegal case
        end
        
        % Updating the static components
        dc_approx = mean(csi_amp(endIdxBIGWIN-lenBigWindow+1:endIdxBIGWIN,:).^2); 
    end
       
    % Removing the static component
    chunk = csi_amp(i*lenChunk-lenChunk+1:i*lenChunk,:);    
    H = abs(chunk.^2 - dc_approx);
    
    % Create total score sequences
    [~,score,~,~,~] = pca(H); % PCA
    csi_pca(i*lenChunk-lenChunk+1:i*lenChunk,:) = score;
end

% The algorithm above makes sure that the big window has moved to the end.
% dc_approx has no need to update
% Only ensure that numChunk*lenChunk+1 is smaller than totalLength
if numChunk*lenChunk+1 < totalLength
    chunk = csi_amp(numChunk*lenChunk+1:totalLength,:);
    if size(chunk,1) < size(chunk,2)
    % When records is shorter than feature's number
        chunk_size = size(chunk,1);
        chunk = [chunk; zeros(size(chunk,2)-size(chunk,1)+1,size(chunk,2))];
    end
    H = abs(chunk.^2 - dc_approx);
    [~,score,~,~,~] = pca(H);
    
    if exist('chunk_size','var')
        score = score(1:chunk_size,:);
    end
    csi_pca(numChunk*lenChunk+1:totalLength,:) = score;
end

%% Spectrogram De-noising Configuration
if suit.CLEANSPEC
    sigma = 0.95;
    mdl_spec_lpf = fspecial('gaussian', suit.WINSPECLPF, sigma); % Build filter
end
    
%% Spectrogram Generation
[s,frequency,time] = stft(csi_pca(:,1),suit.FS,'Window',gausswin(suit.WINSTFT),'OverlapLength',suit.OVERLAP,'FFTLength',suit.FS,'Centered',true);
psd = zeros(size(s)); % To store Power Spectrul Density (PSD)
for i = suit.PCC
    [s,~,~] = stft(csi_pca(:,i),suit.FS,'Window',gausswin(suit.WINSTFT),'OverlapLength',suit.OVERLAP,'FFTLength',suit.FS,'Centered',true);
    
   %% Spectrogram De-noising
    if suit.CLEANSPEC
        s = imfilter(s,mdl_spec_lpf); % Smoothing
    end

    psd = psd + abs(s) / length(suit.PCC); % Aggregate the spectrograms
end

output = {psd,frequency,time};
end

