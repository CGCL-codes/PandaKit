function outSegPoints = varSegment(inCSI, winSize, threshSelect)
%Using variance to segment CSI sequence
%Input: CSI Sequence, Windoe Size, Threshold Select
%Output: Segmentation Points
    [row, column] = size(inCSI);
    num = row/30;
    sumCSI = zeros(num, column);
    for i = 1:num
        sumCSI(i,:) = sum(inCSI((i-1)*30+1: i*30,:));
    end
    numWin = floor(column/winSize);
    varCSI = zeros(num, numWin);
    for i = 1:numWin
        varCSI(:,i) = var(sumCSI(:,(i-1)*winSize+1: i*winSize), 0, 2);
    end
    for i = 1: num
        varCSI(i,:) = mapminmax(varCSI(i,:),0,1);
    end
    sumCSI = sum(varCSI);
    threshhold = quantile(sumCSI, threshSelect);
    index = 1;
    for i = 1:numWin-1
        if(sumCSI(1,i) >= threshhold && sumCSI(1,i+1) <= threshhold || sumCSI(1,i) <= threshhold && sumCSI(1,i+1) >= threshhold)
            segPoints(1,index) = i*winSize - floor(winSize/2);
            index = index + 1;
        end
    end
    len = length(segPoints);
    outSegPoints = segPoints(1,1:floor(len/2)*2);
end

