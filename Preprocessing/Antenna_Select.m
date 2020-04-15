function [csiMaxVar,csiMaxMean] = Antenna_Select(inCSI,subCarrierNum)
%% Determine the links with max average amplitude and max amplitude variance
%   Input:
%       inCSI - Complex 2-d matrix with size of [packetNum, subcarrierNum*links]
%       subcarrierNum - The number of subcarriers between a certain T-R pair
%   Output: two sub-matrix
%       csiMaxMean - sub-matrix of the links with the max average amplitude
%       csiMaxVar - sub-matrix of the links with the max variance
[csiMaxVar,csiMaxMean] = deal({});

%% Input check
linkNum = floor(size(inCSI,2)/subCarrierNum);
if linkNum < 2 % Antenna selection needs at least two links
    return;
end

csiAmp = abs(inCSI);

% Compute the ratio refering to WiDance
ratioAmpToStd = mean(csiAmp) ./ std(csiAmp); 

% Reshape the ratio list to a matrix with size of [subCarrierNum,links]
ratioReshape = mean(reshape(ratioAmpToStd,subCarrierNum,[]));
minRatioIdx = find(ratioReshape==min(ratioReshape));
maxRatioIdx = find(ratioReshape==max(ratioReshape));

csiMaxVar = inCSI(:,(minRatioIdx-1)*subCarrierNum+1:minRatioIdx*subCarrierNum);
csiMaxMean = inCSI(:,(maxRatioIdx-1)*subCarrierNum+1:maxRatioIdx*subCarrierNum);
end