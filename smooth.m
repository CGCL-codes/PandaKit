function outCSI = smooth(inCSI, winSize)
%Smoothing CSI sequence through weighted moving averaging algorithm 
%Input: CSI Sequence, Window Size
%Output: Smoothed CSI Sequence
    [row, column] = size(inCSI);
    
    csi = [zeros(1,winSize), inCSI];
    res = 0;
    for i = winSize + 1:column + winSize
        for j = 1:winSize
            res = res + csi(i-winSize-1+j)*j;
        end
        outCSI(1,i-winSize) = res/(((1+winSize)*winSize)/2);
        res = 0;
    end
end

