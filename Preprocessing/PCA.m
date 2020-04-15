function outCSI = PCA(inCSI,pcaConfig)
%% Principal Components Analysis for de-noising
%   Input description:
%       inCSI - a complex matrix with size of [packetNum, subcarrierNum*links]
%       pcaConfig - a numeric array of pca parameters
%   Output description:
%       outCSI - a real matrix

%% Input parsing
lenChunk = deal(pcaConfig(1)); % Chunk size
rawComCfg = pcaConfig(2:end); % Get candidate components
% Ignoring the outlier parameters
comCfg = rawComCfg(rawComCfg>0 & rawComCfg<size(inCSI,2)); 
csiPCA = inCSI;

%% Computing the pca of non-overlapped chunks
totalLen = size(inCSI,1);
idxChunk = 1;
while idxChunk < totalLen
    if idxChunk+lenChunk-1 < totalLen
        idxChunkEnd = idxChunk+lenChunk-1;
    else
        idxChunkEnd = totalLen;
    end
    chunk = inCSI(idxChunk:idxChunkEnd,:);
    [~,score,~,~,~] = pca(chunk);
    csiPCA(idxChunk:idxChunkEnd,:) = score;
    idxChunk = idxChunkEnd + 1;
end

outCSI = csiPCA(:,comCfg);
end