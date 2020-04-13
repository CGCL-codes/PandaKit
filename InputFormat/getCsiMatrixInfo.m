function csiMatrixInfo = getCsiMatrixInfo(csiMatrix)
%% Make statistic on the field values of csiMatrix 
% ===========================================================================
% csiMatrix - a struct array obtained by getReadingFromDatFile()
%
% Updating:
%   Parsing 12/4/2020 - Created by Credo
% ===========================================================================

% timestamp_low - estimating approximate sampling rate
y = [csiMatrix(:).timestamp_low];
csiMatrixInfo.timestamp_low = [ ...
    csiMatrix(1).timestamp_low, ... % start 
    csiMatrix(end).timestamp_low, ... % end
    1000000/mean(y(2:end)-y(1:end-1))]; % Sampling rate

% bfee_count - counting the missing records
y = [csiMatrix(:).bfee_count];
csiMatrixInfo.bfee_count = [ ...
    csiMatrix(1).bfee_count, ... % start
    csiMatrix(end).bfee_count, ... % end
    find((y(2:end)-y(1:end-1))>1)]; % Sampling rate

% Nrx/Ntx - counting the available receiving/transmitting antennas number
csiMatrixInfo.Nrx = unique([csiMatrix(:).Nrx]);
csiMatrixInfo.Ntx = unique([csiMatrix(:).Ntx]);

% MAC_Des/MAC_Src - counting the available MAC address
csiMatrixInfo.MAC_Des = unique({csiMatrix(:).MAC_Des});
csiMatrixInfo.MAC_Src = unique({csiMatrix(:).MAC_Src});

% Payloads - counting the available payloads
csiMatrixInfo.Payloads = unique({csiMatrix(:).Payloads});
end