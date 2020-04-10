function outSegPoints = slidingWinSegment(inCSI, winSize, stepLen, staticVar, threshSelect)
%Using siliding window to segment CSI sequence in real time
%Input: CSI Sequence, Window Size, Step Length, Static Variance, Threshold Select
%Output: Segmentation Points
    [row, column] = size(inCSI);
    num = row/30;
    sumCSI = zeros(num, column);
    for i = 1: row
        inCSI(i,:) = mapminmax(inCSI(i,:),0,1);
    end
    for i = 1:num
        sumCSI(i,:) = sum(inCSI((i-1)*30+1: i*30,:));
    end
    threshhold = staticVar * threshSelect;
    index = 1;
    startPoint = 1;
    endPoint = winSize;
    mark = 0;
    while endPoint <= column
        varCSI = var(sumCSI(:,startPoint: endPoint), 0, 2);
        varCSI = sum(varCSI) / num;
        if(varCSI >= threshhold && mark == 0)
            segPoints(1,index) = floor((startPoint + endPoint)/2);
            index = index + 1;
            mark = 1;
        end
        if(varCSI <= threshhold && mark == 1)
            segPoints(1,index) = floor((startPoint + endPoint)/2);
            index = index + 1;
            mark = 0;
        end
        startPoint = startPoint + stepLen;
        endPoint = endPoint + stepLen;
    end
    len = length(segPoints);
    outSegPoints = segPoints(1,1:floor(len/2)*2);
end

