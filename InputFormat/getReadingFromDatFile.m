function csiMatrix = getReadingFromDatFile(filepath)
%% This function is simply reading the .dat file.
% ==============================================================
% Reading and transforming the raw csi data
% ===========================================================================
%% Syntax:
%  csiMatrix = getReadingFromDatFile(filename) - Reading the .dat file
%  e.g., csiMatrix = getReadingFromDatFile('U1_G1_N10_L_L1_D0_20200101_1.dat')
%
%  Output is a struct array
%
%  Tips:
%   - Only supporting INTEL 5300 NIC readings with 30 subcarriers,
%     up to 3 transmitting antennas and up to 3 receiving antennas
%   - A modified version of read_bf_file() that supports
%     reading MAC address and payloads is required.
%   - The raw csi_trace data is saved as a cell array in .dat file.
%
% Updating:
%   12/4/2020 - Created by Credo
% ===========================================================================

%% Input validation
p = inputParser;    % Parser generation

% Adding validation rules
% - A simple vadation because this function is only called by readDatFile()
% - Only check if the input type is string or char array
validCharOrStr = @(x) isstring(x) || ischar(x);
addRequired(p,'filename',validCharOrStr);
parse(p,filepath); % Validation

%% Read data
csi_trace_raw = read_bf_file(filepath);

%% Unified format
csiMatrix = cellfun(@(x) csiUnified(x), csi_trace_raw);
end % getReadingFromDatFile

function csiUni = csiUnified(csi)
%%   Unify the csi format since some unknown factor may cause
% different data format. For example, sparse records cannot
% successfully read the payloads and mac address.
%
% Format refers to the FAQ 2 in
%   https://dhalperi.github.io/linux-80211n-csitool/faq.html
%
% "Payloads" and "Mac address" can be received when using a
% received version of CSI Tool.
% Refer to the FAQ 12 in
%   https://dhalperi.github.io/linux-80211n-csitool/faq.html
%
% In order to unify the input format, we assign default value
%   "00:00:00:00:00:00" to the mac address and "000000"
%   to the payloads.

% Set default values of MAC_Des, MAC_Src, Payloads
if ~isfield(csi, 'MAC_Des')
    csi.MAC_Des = '00:00:00:00:00:00';
end

if ~isfield(csi, 'MAC_Src')
    csi.MAC_Src = '00:00:00:00:00:00';
end

if ~isfield(csi, 'Payloads')
    csi.Payloads = '000000';
end

csiUni = csi;
end % csiUnified