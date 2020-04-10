function outCSI = PCA(inCSI,Fs)
%Principal Components Analysis
%Input: CSI Sequence£¬Outlier Number
%Output: PCA Sequence
    timeChunk = 1; % Chunk size 1s
    lenChunk = floor(Fs*timeChunk);
    numChunkInBigWindow = 4; % The number chunks in a big window
    lenBigWindow = numChunkInBigWindow * lenChunk;

    windowBig = abs(inCSI(:,1:numChunkInBigWindow*lenChunk));
    avgMagnitude2 = mean(windowBig.^2,2); % Computing the static components

    chunk_1 = abs(inCSI(:,1:lenChunk)); % Using at initialization phase
    chunk_2 = abs(inCSI(:,lenChunk+1:2*lenChunk)); 
    chunk_3 = abs(inCSI(:,2*lenChunk+1:3*lenChunk)); 
    chunk = abs(inCSI(:,3*lenChunk+1:4*lenChunk));

    H_1 = abs(sqrt((chunk_1.^2 - avgMagnitude2)')); % Remove the static components
    H_2 = abs(sqrt((chunk_2.^2 - avgMagnitude2)'));
    H_3 = abs(sqrt((chunk_3.^2 - avgMagnitude2)'));
    H = abs(sqrt((chunk.^2 - avgMagnitude2)'));
    
    totalLength = size(inCSI,2); % Total length of received signal
    numChunk = floor( totalLength / lenChunk); % The number of chunks, the last one won't be considered

    outCSI = zeros(numChunk*lenChunk,size(inCSI,1));

    [~,score_1,~,~,~] = pca(H_1);
    [~,score_2,~,~,~] = pca(H_2);
    [~,score_3,~,~,~] = pca(H_3);
    [~,score,~,~,~] = pca(H);

    outCSI(1:numChunkInBigWindow*lenChunk,:) = [score_1; score_2; score_3; score];

    for i = 5:numChunk
        % Create total score sequences
        windowBig = abs(inCSI(:,i*lenChunk-lenBigWindow+1:i*lenChunk));
        avgMagnitude2 = mean(windowBig.^2,2); % Computing the static components
        chunk = abs(inCSI(:,i*lenChunk-lenChunk+1:i*lenChunk));

        H = abs(sqrt((chunk.^2 - avgMagnitude2)')); % Remove the static components

        [~,score,~,~,~] = pca(H); % PCA
        outCSI(i*lenChunk-lenChunk+1:i*lenChunk,:) = score;
    end
    outCSI = outCSI';
end