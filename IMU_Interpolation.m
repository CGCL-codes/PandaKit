function [Gyroscope,Acceleration, Magnetometer] = IMU_Interpolation(filename)

   Gyro = csvread("D:\master\work\user3-park-需要插值\"+ filename + "\Gyroscope.csv", 1, 0);
   Acce = csvread("D:\master\work\user3-park-需要插值\"+ filename + "\Linear Acceleration.csv", 1, 0);
   Magn = csvread("D:\master\work\user3-park-需要插值\"+ filename + "\Magnetometer.csv", 1, 0);
   
   Gyro(:,1) = floor(Gyro(:,1).*100);
   Acce(:,1) = floor(Acce(:,1).*100);
   Magn(:,1) = floor(Magn(:,1).*100);
   
   MaxTime = max([Gyro(end,1), Acce(end,1), Magn(end,1)]);
   
   Gyroscope(:,1) = 1:MaxTime;
   for i=2:4
       for j=1:200:length(Gyro(:,1))-200
           cs = spline(1:200, Gyro(j:j+199,i));
           xx = linspace(1,200, length(Gyro(max(j-1,1),1)+1:Gyro(j+199,1)));
           csTemp = ppval(cs, xx);
           Gyroscope(Gyro(max(j-1,1),1)+1:Gyro(j+199,1),i) = csTemp;
       end
       cs = spline(1:length(j+200:length(Gyro(:,1))), Gyro(j+200:end,i));
       xx = linspace(1,length(Gyro(:,1))-j-199, length(Gyro(j+199,1)+1:MaxTime));
       csTemp = ppval(cs, xx);
       Gyroscope(Gyro(j+199,1)+1:MaxTime,i) = csTemp;
   end
   
   Acceleration(:,1) = 1:MaxTime;
   for i=2:4
       for j=1:200:length(Acce(:,1))-200
           cs = spline(1:200, Acce(j:j+199,i));
           xx = linspace(1,200, length(Acce(max(j-1,1),1)+1:Acce(j+199,1)));
           csTemp = ppval(cs, xx);
           Acceleration(Acce(max(j-1,1),1)+1:Acce(j+199,1),i) = csTemp;
       end
       cs = spline(1:length(j+200:length(Acce(:,1))), Acce(j+200:end,i));
       xx = linspace(1,length(Acce(:,1))-j-199, length(Acce(j+199,1)+1:MaxTime));
       csTemp = ppval(cs, xx);
       Acceleration(Acce(j+199,1)+1:MaxTime,i) = csTemp;
   end
   
   Magnetometer(:,1) = 1:MaxTime;
   for i=2:4
       for j=1:200:length(Magn(:,1))-200
           cs = spline(1:200, Magn(j:j+199,i));
           xx = linspace(1,200, length(Magn(max(j-1,1),1)+1:Magn(j+199,1)));
           csTemp = ppval(cs, xx);
           Magnetometer(Magn(max(j-1,1),1)+1:Magn(j+199,1),i) = csTemp;
       end
       cs = spline(1:length(j+200:length(Magn(:,1))), Magn(j+200:end,i));
       xx = linspace(1,length(Magn(:,1))-j-199, length(Magn(j+199,1)+1:MaxTime));
       csTemp = ppval(cs, xx);
       Magnetometer(Magn(j+199,1)+1:MaxTime,i) = csTemp;
   end
   
   csvwrite("D:\master\work\user3_park_interpolation\"+ filename + "\Gyroscope.csv", Gyroscope);
   csvwrite("D:\master\work\user3_park_interpolation\"+ filename + "\Linear Acceleration.csv", Acceleration);
   csvwrite("D:\master\work\user3_park_interpolation\"+ filename + "\Magnetometer.csv", Magnetometer);
end

