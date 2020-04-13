function outPhase = Phase_Calibration_ConjuMulti(inCSI)
%% Using conjugate multiplication to realize phase calibration
%   inCSI - Complex 2-d matrix with size of [packetNum, subcarrierNum*links]
%   outCSI - the conjugation multiple result of the CSI sequences of two links
%               with size of [packetNum, subcarrierNum]

selectedCSI = Antenna_Select(inCSI);
outPhase = selectedCSI(1:30,:) .* conj(selectedCSI(end-29:end,:));

end