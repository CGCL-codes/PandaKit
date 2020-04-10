function outCSI = Outlier_Removal(inCSI, Nears)
%Outlier Removal
%Input: CSI sequence, Number of Outlier neighbor
%Output: Processed CSI sequnece
    [row, column] = size(inCSI);
    outCSI = inCSI;
    for i=1:row
        outCSI(i,:) = hampel(inCSI(i,:), Nears);
    end
end

