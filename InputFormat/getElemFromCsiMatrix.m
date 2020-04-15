function csiMatrixExtract = getElemFromCsiMatrix(csiMatrix,csiMatrixInfo,varargin)
%% Get the elements of the csiMatrix
% ===========================================================================
%% Syntax:
%  elem = getElemFromCsiMatrix(csiMatrix) - Default case extracts all csi value
%  elem = getElemFromCsiMatrix(csiMatrix,csiMatrixInfo,'Ntx',[1 3],'Nrx',[2 3]) - Link selection
%
%  Tips:
%  csiMatrixInfo - a necessary argument providing the broundaries to check
%  the selection configs.
%
% Updating:
%   Parsing 12/4/2020 - Created by Credo
% ===========================================================================
%% Input validation
p = inputParser;    % Parser generation

% Adding csiMatrix validation rules
validFunCsiMatrix = @(x) ~isempty(x) && isstruct(x);
addRequired(p,'csiMatrix',validFunCsiMatrix);

% Adding csiMatrixInfo validation rules
validFunCsiMatrixInfo = @(x) ~isempty(x) && isstruct(x);
addRequired(p,'csiMatrixInfo',validFunCsiMatrixInfo);

% Adding timestamp_low validation rules
% - should be an increasing numeric array with size of [1,2]
% - should be in the range of timestamp_low refering to csiMatrixInfo
validFunTimestampLow = @(x) validateattributes(x, ...
    'numeric', {'size', [1,2], 'increasing', ...
    '>=',csiMatrixInfo.timestamp_low(1),'<=',csiMatrixInfo.timestamp_low(2)}, 'Rankings');
defaultTimestampLow = [0 0];    % Default value of 'timestamp_low'
addParameter(p,'timestamp_low',defaultTimestampLow,validFunTimestampLow); % timestamp_low

% Adding bfee_count validation rules
% - should be an increasing numeric array with size of [1,2]
% - should be in the range of bfee_count refering to csiMatrixInfo
validFunBfeeCount = @(x) validateattributes(x, ...
    'numeric', {'size', [1,2], 'increasing', ...
    '>=',csiMatrixInfo.bfee_count(1),'<=',csiMatrixInfo.bfee_count(2)}, 'Rankings');
defaultBfeeCount = [0 0];    % Default value of optional arg 'bfee_count'
addParameter(p,'bfee_count',defaultBfeeCount,validFunBfeeCount); % bfee_count

% Adding Nrx validation rules
nrxValidFun = @(x) validateattributes(x, ...
    'numeric',{'>=',1,'<=',csiMatrixInfo.Nrx},'Rankings');
defaultNrx = 1:csiMatrixInfo.Nrx;    % Default value of optional arg 'Nrx'
addParameter(p,'Nrx',defaultNrx,nrxValidFun);

% Adding Ntx validation rules
ntxValidFun = @(x) validateattributes(x, ...
    'numeric',{'>=',1,'<=',csiMatrixInfo.Ntx},'Rankings');
defaultNtx = 1:csiMatrixInfo.Ntx;    % Default value of optional arg 'Ntx'
addParameter(p,'Ntx',defaultNtx,ntxValidFun);

% Adding signal validation rules
defaultSignal = 'csi'; % Default value of optional arg 'signal'
expectedSignal = {'csi','rssi','all'};
addParameter(p,'signal',defaultSignal,...
                 @(x) any(validatestring(x,expectedSignal)));

% Adding MAC address validation rules
defaultMacAdd = "00:00:00:00:00:00";    % Default value of MAC_Des/MAC_Src
addParameter(p,'MAC_Des',defaultMacAdd,...
                 @(x) any(validatestring(x,csiMatrixInfo.MAC_Des))); % MAC_Des
addParameter(p,'MAC_Src',defaultMacAdd,...
                 @(x) any(validatestring(x,csiMatrixInfo.MAC_Src))); % MAC_Src

% Adding Payloads validation rules
defaultPayloads = "000000";
addParameter(p,'Payloads',defaultPayloads,...
                 @(x) any(validatestring(x,csiMatrixInfo.Payloads)));

parse(p,csiMatrix,csiMatrixInfo,varargin{:}); % Validation

%% Elements extraction
% Step 1. determine the satisfying sub-csiMatrix
csiMatrixCutoff = cutoffCsiMatrixBasedOnParser(csiMatrix,p);

% Step 2. extract the satifying elements from the csiMatrixCutoff
csiMatrixExtract = extractCsiMatrixBasedOnParser(csiMatrixCutoff,p);

end

function csiMatrixExtract = extractCsiMatrixBasedOnParser(csiMatrixCutoff,p)
    % Determine the target antennas and signal
    ntx = sort(unique(p.Results.Ntx));
    nrx = sort(unique(p.Results.Nrx));
    signal = p.Results.signal;
    
    % Extracting the elements in the order of [tsl, bfee] - [csi] - [rssi]
    csiMatrixExtract = [[csiMatrixCutoff.timestamp_low]',[csiMatrixCutoff.bfee_count]'];
    switch signal
        case 'csi'
            csiMatrixExtract = [csiMatrixExtract, extractCsi(csiMatrixCutoff,ntx,nrx)];
        case 'rssi'
            csiMatrixExtract = [csiMatrixExtract, extractRssi(csiMatrixCutoff,nrx)];
        case 'all'
            csiMatrixExtract = [csiMatrixExtract, extractCsi(csiMatrixCutoff,ntx,nrx)];
            csiMatrixExtract = [csiMatrixExtract, extractRssi(csiMatrixCutoff,nrx)];
    end
end

function csiMatrixExtract = extractCsi(csiMatrixCutoff,ntx,nrx)    
    % Cellfun has some unkown bug that cannot successfully generate
    % the csi matrix. Hence, we now uses a loop framework to get the
    % csi matrix.
    csiMatrixExtract = ...
        zeros(length(csiMatrixCutoff),numel(ntx)*numel(nrx)*30);
    
    for i = 1:length(csiMatrixCutoff)
        idxInsert = 1;
        for t = ntx
            for r = nrx
                csiMatrixExtract(i,idxInsert:idxInsert+30-1) = ...
                    csiMatrixCutoff(i).csi(t,csiMatrixCutoff(i).perm(r),:);
                idxInsert = idxInsert + 30;
            end
        end
    end
end

function csiMatrixExtract = extractRssi(csiMatrixCutoff,nrx)
    % Only conforms to nrx
    csiMatrixExtract = [];
    if ismember(1,nrx)
        csiMatrixExtract = [csiMatrixExtract, [csiMatrixCutoff.rssi_a]'];
    end
    if ismember(2,nrx)
        csiMatrixExtract = [csiMatrixExtract, [csiMatrixCutoff.rssi_b]'];
    end 
    if ismember(3,nrx)
        csiMatrixExtract = [csiMatrixExtract, [csiMatrixCutoff.rssi_c]'];
    end
    csiMatrixExtract = [csiMatrixExtract, [csiMatrixCutoff.noise]'];
end

function csiMatrixCut = cutoffCsiMatrixBasedOnParser(csiMatrix,p)
    idxCsiMatrixCut = ones(1,length(csiMatrix));
    
    % timestamp_low
    if ~ismember('timestamp_low',p.UsingDefaults)
        idxTsl = arrayfun( ...
            @(x) (x>=p.Results.timestamp_low(1) && x<=p.Results.timestamp_low(2)), ...
            [csiMatrix(:).timestamp_low]);
        idxCsiMatrixCut = idxCsiMatrixCut & idxTsl;
    end

    % bfee_count
    if ~ismember('bfee_count',p.UsingDefaults)
        idxBfee = arrayfun( ...
            @(x) (x>=p.Results.bfee_count(1) && x<=p.Results.bfee_count(2)), ...
            [csiMatrix(:).bfee_count]);
        idxCsiMatrixCut = idxCsiMatrixCut & idxBfee;
    end

    % MAC_Des
    if ~ismember('MAC_Des',p.UsingDefaults)
        idxMacDes = arrayfun( ...
            @(x) (contains(x,p.Results.MAC_Des)), {csiMatrix(:).MAC_Des});
        idxCsiMatrixCut = idxCsiMatrixCut & idxMacDes;
    end

    % MAC_Src
    if ~ismember('MAC_Src',p.UsingDefaults)
        idxMacSrc = arrayfun( ...
            @(x) (contains(x,p.Results.MAC_Src)), {csiMatrix(:).MAC_Src});
        idxCsiMatrixCut = idxCsiMatrixCut & idxMacSrc;
    end

    % Payloads
    if ~ismember('Payloads',p.UsingDefaults)
        idxPayloads = arrayfun( ...
            @(x) (contains(x,p.Results.Payloads)), {csiMatrix(:).Payloads});
        idxCsiMatrixCut = idxCsiMatrixCut & idxPayloads;
    end
    
    csiMatrixCut = csiMatrix(idxCsiMatrixCut==1);
end