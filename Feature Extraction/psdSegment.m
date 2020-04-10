function outSegPoints = psdSegment(inSpec, winSize)
%The function uses power spectral density (PSD) to segment time-frequency spectrogram
%Input: time-frequency spectrogram, smoothing window size
%Output: segmentaion points sequence
    [row, column] = size(inSpec);
    
    threshhold1 = quantile(inSpec(:)',0.75);%coutour extraction threshold1
    contour = zeros(1,column);
    for i=1:column
        couttourPoint = find(inSpec(:,i)>=threshhold1,1,'last');
        if isempty(couttourPoint)
            coutour(1,i) = 0;
        else
            coutour(1,i) = couttourPoint;
        end
    end
    halfWin=floor(winSize/2);
    coutour = [zeros(1,halfWin), coutour, zeros(1,halfWin)];
    for i= halfWin + 1:column+halfWin
        smoothCoutour(1,i-halfWin) = sum(coutour(1,i-halfWin:i+halfWin))/(halfWin*2+1);
    end
    threshold2 = quantile(smoothCoutour, 0.25); %coutour segmentation threshold
    index=1;
    for i=1:column-1
        if((smoothCoutour(1,i)>threshold2 && smoothCoutour(1,i+1)<threshold2) ||(smoothCoutour(1,i)<threshold2 && smoothCoutour(1,i+1)>threshold2) || smoothCoutour(1,i)==threshold2)
            outSegPoints(1,index) = i;
            index = index + 1;
        end
    end
%     figure;
%     plot(smoothCoutour);
%     hold on;
%     plot(threshold2*ones(1,column));
end

