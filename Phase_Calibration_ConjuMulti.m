function outPhase = Phase_Calibration_ConjuMulti(inCSI)
%Using conjugate multiplication to realize phase calibration
%Input: Complex CSI sequence
%Output: Calibrated CSI sequence
    selectedCSI = Antenna_Select(inCSI);
    outPhase = selectedCSI(1:30,:) .* conj(selectedCSI(end-29:end,:));
    outPhase = angle(outPhase);
end