function csiMatrix = getReadingFromDatFile(file, varargin)
%% This function is simply reading the .dat file.
% ==============================================================
% Reading and transforming the raw csi data
% ===========================================================================
%% Syntax:
%  mCSI = getReadingFromDatFile('filename') - Reading the .dat file
%  mCSI = getReadingFromDatFile('filename','save','csv') - Reading and saving the data
%
%  Tips:
%   - Only supporting INTEL 5300 NIC readings with 30 subcarriers,
%     up to 3 transmitting antennas and up to 3 receiving antennas
%   - A modified version of read_bf_file() that supports
%     reading MAC address and payloads is required.
%   - The raw csi_trace data is saved as a cell array in .dat file.
%   - mCSI is a flat version os csi_trace suitable for other save format
%     e.g., csv
%
% Updating:
%   9/4/2020 - Created by Credo
% ===========================================================================

%% Input validation
defaultSave = 'mat';    % Default value of optional arg 'save'
expectedSave = {'mat','csv'};   % Available values of 'save'

p = inputParser;    % Parser generation

% Adding validation rules
validCharOrStr = @(x) isstring(x) || ischar(x);
addRequired(p,'filename',validCharOrStr);
addParameter(p,'save',defaultSave,...
                 @(x) any(validatestring(x,expectedSave)));

parse(p,file,varargin{:}); % Validation

%% Read data
csi_trace = read_bf_file(file);

%% Flatten raw data from cell array to string matrix
% Determing the max size of matrx w.r.t. the max size of 'csi'
maxSizeCSI = max(cellfun(@(x) numel(x.csi), csi_trace));
% Flatten
csiMatrix = cellfun(@(x) csiFlatten(x,maxSizeCSI), csi_trace, 'UniformOutput', false);

%% Save data
% Step 1: 'save' checking
saveCheck = cellfun(@(x) contains(x,'save'), p.UsingDefaults);
if sum(saveCheck) == 0
    % Step 2: filename parsing
    file = split(file,"\");
    file = split(file(end),".");
    filename = file(1);
    
    % Step 3: saving type determination
    switch p.Results.save
        case 'mat'
            saveFileName = filename + ".mat";
            save(saveFileName,'csiMatrix');
        case 'csv'
            saveFileName = filename + ".csv";
            writecell(csiMatrix,saveFileName);
    end
end
end % getReadingFromDatFile

function mCSI = csiFlatten(csi, mSizeCSI)
% Flatten raw data from cell array to matrix
% 'mSizeCSI' avoids the format/size error caused by data missing
% Format refers to the FAQ 2 in
%   https://dhalperi.github.io/linux-80211n-csitool/faq.html

% Permulating csi readings
csiPerm = zeros(1,mSizeCSI);
assignStartLoc = 1;
for t = 1:csi.Ntx
    for r = csi.perm
        csiPerm(assignStartLoc:assignStartLoc-1+30) = csi.csi(t,r,:);
        assignStartLoc = assignStartLoc + 30;
    end
end

% Set default values of MAC_Des, MAC_Src, Payloads
if isfield(csi, 'MAC_Des')
    MAC_Des = csi.MAC_Des;
else
    MAC_Des = "00:00:00:00:00:00";
end

if isfield(csi, 'MAC_Src')
    MAC_Src = csi.MAC_Src;
else
    MAC_Src = "00:00:00:00:00:00";
end

if isfield(csi, 'Payloads')
    Payloads = csi.Payloads;
else
    Payloads = "000000";
end

% Flatten
mCSI = [ ...
    string(csi.timestamp_low), ... % Occupying 1 components
    string(csi.bfee_count), ... % Occupying 1 components
    string(csi.Nrx), ... % Occupying 1 components
    string(csi.Ntx), ... % Occupying 1 components
    string(csi.rssi_a), ... % Occupying 1 components
    string(csi.rssi_b), ... % Occupying 1 components
    string(csi.rssi_c), ... % Occupying 1 components
    string(csi.noise), ... % Occupying 1 components
    string(csi.agc), ... % Occupying 1 components
    string(csi.rate), ... % Occupying 1 components
    string(csiPerm), ... % Occupying Ntx*Nrx*30 components
    string(MAC_Des), ... % Occupying 1 components
    string(MAC_Src), ... % Occupying 1 components
    string(Payloads), ... % Occupying 1 components
    ];

end % csiFlatten