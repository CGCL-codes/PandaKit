function [sumDist, segmentPoints] = segmentUpdate(inCSI, minLen, maxLen, temp)
%Update segmentation for pattern fitting

    sumDist = 0;
    index = 2;
    start = 1;
    segmentPoints(1,1) = 1;
    while length(inCSI(1,start:end)) >= minLen
        len = length(inCSI(1,start:end));
        minDist = 10000000;
        for i=minLen:maxLen
            if (start+i) > length(inCSI)
                segmentPoints(1,index) = start+i-1;
                break;
            end
            cs = spline(1:length(temp), temp);
            xx = linspace(1,length(temp),i);
            csTemp = ppval(cs, xx);
            dist = norm(inCSI(1,start:start+i-1)-csTemp);
            if dist < minDist
                minDist = dist;
                segmentPoints(1,index) = start+i-1;
            end
        end
        index = index + 1;
        sumDist = sumDist + minDist;
        start = segmentPoints(1,index-1)+1;
    end
end

