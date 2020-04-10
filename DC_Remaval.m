function outCSI = DC_Remaval(inCSI, samFreq, LcutFreq, HcutFreq, N)
%Static DC Removal
%Input: CSI sequence
%Output: Filtered CSI Sequence
    [row, column] = size(inCSI);
    avgVec = mean(inCSI, 2);
    outCSI = inCSI;
    for i = 1:row
        outCSI(i,:) = inCSI(i,:)-avgVec(i,1);
    end
end