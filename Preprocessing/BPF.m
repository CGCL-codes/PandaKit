function outCSI = BPF(inCSI, samFreq, LcutFreq, HcutFreq, N)
%Band pass filter
%Input: CSI Sequence, Sample Frequency, Low Cutoff Frequency, High Cutoff Frequency, Order
%Output: Filtered CSI Seq
    [row, column] = size(inCSI);
    [a, b] = butter(N/2, [LcutFreq HcutFreq]/(samFreq/2));
    outCSI = inCSI;
    for i = 1:row
        outCSI(i,:) = filter(a, b, inCSI(i,:));
    end
end