function outCSI = LPF(inCSI, samFreq, cutFreq, N)
%Low pass filter
%Input: CSI Seq, Sample Frequency, Cutoff Frequency, Order
%Output: Filtered CSI Seq
    [row, column] = size(inCSI);
    [a, b] = butter(N, cutFreq/(samFreq/2));
    outCSI = inCSI;
    for i = 1:row
        outCSI(i,:) = filter(a, b, inCSI(i,:));
    end
end

