function outCSI = HPF(inCSI, samFreq, cutFreq, N)
%High pass filter
%Input: CSI Sequence, Sample Frequency, Cutoff Frequency, Order
%Output: Filtered CSI Sequence
    [row, column] = size(inCSI);
    [a, b] = butter(N, cutFreq/(samFreq/2), 'High');
    outCSI = inCSI;
    for i = 1:row
        outCSI(i,:) = filter(a, b, inCSI(i,:));
    end
end