function outCSI = Antenna_Select(inCSI)
%Pair of Antennas selection
%Input: CSI Amplitude Seq from different antenna pairs
%Output: Ordered CSI of subchannels: from CSI of Small Amplitude Large Variance subchannel
%                    to CSI of Large Amplitude Small Variance subchannel
    CSIAmp = abs(inCSI);
    rowNum = length(CSIAmp(:,1));
    outCSI = inCSI;
    
    if rowNum >= 60
        stdRes = mapminmax(std(CSIAmp, 0, 2), 0, 1);
        sumRes = mapminmax(sum(CSIAmp, 2), 0, 1);
        Res = sumRes - stdRes;
    else
        disp("Number of subchannel <= 1 without the need of antenna selection.");
    end
    
    subChannelNum = floor(rowNum/30);
    stdResSum=zeros(1,subChannelNum);
    for i = 1:subChannelNum
        stdResNum(1,i) = sum(Res((i-1)*30+1 : i*30, 1));
    end
    [B, index] = sort(stdResNum);
    for i = 1:subChannelNum
        outCSI((i-1)*30+1 : i*30, :) = inCSI((index(i)-1)*30+1 : index(i)*30, :);
    end
end