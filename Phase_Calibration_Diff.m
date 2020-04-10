function outPhase = Phase_Calibration_Diff(inCSI, Ntx, Nrx)
%Using phase difference to calibrate phase
%Input: Complex CSI sequence, Ntx, Nrx
%Output: Calibrated Phase Sequence
    if Nrx >= 2
        for i = 1:Ntx
            for j = 1:Nrx-1
                outPhase((i*j-1)*30+1:(i*j)*30,:) = inCSI((i*j-1)*30+1:(i*j)*30,:) ./ inCSI((i*j)*30+1:(i*j+1)*30,:);
            end
        end
    else
        disp("Number of receive antenna (Nrx) <=1, ");
        disp("Does not meet the requirements for phase difference calibration");
    end
    outPhase = angle(outPhase);
end