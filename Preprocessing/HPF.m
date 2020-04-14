function outCSI = HPF(inCSI, fc, fs)
%% High pass filter
%   Input format:
%   inCSI - a complex matrix with size of [packetNum, subcarrierNum]
%   fc - cutoff frequency a scalar
%   fs - sampling frequency a scalar
%
%   Output: Filtered CSI
%   inCSI - a complex matrix with size of [packetNum, subcarrierNum]
    [a, b] = butter(3, fc(1)/(fs/2), 'High');
    outCSI = inCSI;
    for i = 1:size(inCSI,2)
        outCSI(:,i) = filter(a, b, inCSI(:,i));
    end
end