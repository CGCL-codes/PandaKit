function outCSI = BPF(inCSI, fc, fs)
%% Band pass filter
%   Input format:
%   inCSI - a complex matrix with size of [packetNum, subcarrierNum]
%   fc - cutoff frequency a vector with 2 elements
%   fs - sampling frequency a scalar
%
%   Output: Filtered CSI
%   inCSI - a complex matrix with size of [packetNum, subcarrierNum]
    [a, b] = butter(3, [fc(1) fc(2)]/(fs/2));
    outCSI = inCSI;
    for i = 1:size(inCSI,2)
        outCSI(:,i) = filter(a, b, inCSI(:,i));
    end
end