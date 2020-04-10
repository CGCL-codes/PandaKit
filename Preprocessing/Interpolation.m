function InterpData = Interpolation(data)
%Using interpolation to process time sequence
%Input: Time sequence with timestamp
%Output: Interpolation data

   column = length(data(1,:));
   data(:,1) = floor(data(:,1).*100); %Calibration Timestamp
   segmenLen = 200; %Piecewise interpolation

   MaxTime = data(end,1);

   InterpData(:,1) = 1:MaxTime;
   for i=2:column
       for j=1:segmenLen:length(data(:,1))-segmenLen
           cs = spline(1:segmenLen, data(j:j+(segmenLen-1),i));
           xx = linspace(1,segmenLen, length(data(max(j-1,1),1)+1:data(j+(segmenLen-1),1)));
           csTemp = ppval(cs, xx);
           InterpData(data(max(j-1,1),1)+1:data(j+(segmenLen-1),1),i) = csTemp;
       end
       cs = spline(1:length(j+segmenLen:length(data(:,1))), data(j+segmenLen:end,i));
       xx = linspace(1,length(data(:,1))-j-(segmenLen-1), length(data(j+(segmenLen-1),1)+1:MaxTime));
       csTemp = ppval(cs, xx);
       InterpData(data(j+(segmenLen-1),1)+1:MaxTime,i) = csTemp;
   end
end

