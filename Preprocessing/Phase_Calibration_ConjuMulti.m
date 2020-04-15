function csiCM = Phase_Calibration_ConjuMulti(csi,subcarrierNum)
%% Using conjugate multiplication to realize phase calibration
%   Input:
%       inCSI - Complex 2-d matrix with size of [packetNum, subcarrierNum*links]
%       subcarrierNum - The number of subcarriers between a certain T-R pair
%   Output: two sub-matrix
%       csiMaxMean - sub-matrix of the links with the max average amplitude
%       csiMaxVar - sub-matrix of the links with the max variance

[csiMaxVar,csiMaxMean] = Antenna_Select(csi,subcarrierNum);
if ~isempty(csiMaxVar) && ~isempty(csiMaxMean)
    % The order of csiMaxVar and csiMaxMean is very important
    %csiCM = csiMaxVar .* conj(csiMaxMean);
    csiCM = csiMaxMean .* conj(csiMaxVar);
else
    csiCM = {};
end