function outSegPoints = patternFitSeg(inCSI, maxLen, minLen, threshold)
%Using pattern fitting to segment 
%Input: CSI vector, Minimum length of segmentation, Maximum length of
%       segmentation, Convergence threshold
%Output: segmentaion points sequence
    
    temp = zeros(1, floor((maxLen+minLen)/2));
    [sumDist, segmentPoints] = segmentUpdate(inCSI, maxLen, minLen, temp);
    for i=1:1000
        if(sumDist < threshold)
            break;
        end
        numPoints = length(segmentPoints);
        temp = zeros(1, floor((maxLen+minLen)/2));
        for j = 1:numPoints-1       %update template
            cs = spline(segmentPoints(1,j):segmentPoints(1,j+1), inCSI(1,segmentPoints(1,j):segmentPoints(1,j+1)));
            xx = linspace(segmentPoints(1,j),segmentPoints(1,j+1), length(temp));
            csTemp = ppval(cs, xx);
            temp = temp +csTemp;
        end
        temp = temp./j;
        [sumDist, segmentPoints] = segmentUpdate(inCSI, maxLen, minLen, temp);   
    end
%     disp(i);
%     disp(j);
%     disp(sumDist);
%     plot(temp);
    outSegPoints = segmentPoints;
end

