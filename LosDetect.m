function LoSSignal = LoSDetect(inCSI)
%LoS signal detection by CIR
%Input: Complex CSI Sequence
%Output: LoS signal Sequence
    csi_length = size(inCSI,2);
    stream_num = size(inCSI,1);
    channel_num = 30; % Intel 5300;
    antennas_pair = stream_num / channel_num;

    LosSignal = zeros(antennas_pair,csi_length);

    for i = 1:csi_length
        for j = 1:antennas_pair
            packet = inCSI((j-1)*channel_num+1:j*channel_num,i);
            packet_ifft = ifft(packet);
            cB = abs(packet_ifft);
            LosSignal(j,i) = max(cB);
        end
    end
    figure;
    plot(LosSignal(1,:));
end

