function y = DC_Remove(x, wMean, strideLen)
%% Removing the Static DC component
%   Input:
%       x - a matrix with size of [packetNum, subcarrierNum]
%       wMean - the size of sliding window
%       strideLen - length of stride
%   Output:
%       y - a matrix with size of [packetNum, subcarrierNum]
y = x;
totalLen = size(x,1);

% Removing the static component of the initial sliding window
[idxChunkStart,idxChunkEnd] = deal(1,wMean);
avgVec = mean(x(idxChunkStart:idxChunkEnd,:));

y(idxChunkStart:idxChunkEnd,:) = ...
    x(idxChunkStart:idxChunkEnd,:) - avgVec;

% Removing static components
while idxChunkEnd < totalLen
    idxChunkStart = idxChunkEnd + 1;
    if idxChunkEnd + strideLen < totalLen        
        idxChunkEnd = idxChunkEnd + strideLen;
    else
        idxChunkEnd = totalLen;
    end
    avgVec = mean(x(idxChunkEnd-wMean+1:idxChunkEnd,:));
    y(idxChunkStart:idxChunkEnd,:) = ...
        x(idxChunkStart:idxChunkEnd,:) - avgVec;
end
end