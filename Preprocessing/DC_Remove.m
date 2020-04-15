function outCSI = DC_Remove(inCSI, wMean, strideLen)
%% Removing the Static DC component
%   Input:
%       inCSI - a complex matrix with size of [packetNum, subcarrierNum]
%       wMean - the size of sliding window
%       strideLen - length of stride
%   Output: Filtered CSI Sequence
outCSI = inCSI;
totalCsiLen = size(inCSI,1);

% Removing the static component of the initial sliding window
[idxChunkStart,idxChunkEnd] = deal(1,wMean);
avgVec = mean(inCSI(idxChunkStart:idxChunkEnd,:));
outCSI(idxChunkStart:idxChunkEnd,:) = ...
    inCSI(idxChunkStart:idxChunkEnd,:) - avgVec;

% Removing static components
while idxChunkEnd < totalCsiLen
    idxChunkStart = idxChunkEnd + 1;
    if idxChunkEnd + strideLen < totalCsiLen        
        idxChunkEnd = idxChunkEnd + strideLen;
    else
        idxChunkEnd = totalCsiLen;
    end
    avgVec = mean(inCSI(idxChunkEnd-wMean+1:idxChunkEnd,:));
    outCSI(idxChunkStart:idxChunkEnd,:) = ...
        inCSI(idxChunkStart:idxChunkEnd,:) - avgVec;
end
end