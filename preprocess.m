function varargout = preprocess(csiMatrix,varargin)
%% De-noise, calibration and interpolation
% ==============================================================
% Preprocessing the wireless signals for sensing problem
% ===========================================================================
%% Syntax:
%  y = Preprocessing(x) - Default case: InFit
%  y = Preprocessing(x,'suite','infit') - Set this suite: WiDance
%  y = Preprocessing(' ',varargin) - Set the other arguments
%  Tips: 'SUITE' shoud be set before other arguments
%
% Updating:
%   13/4/2020 - Suite: 'InFit'
%   10/23/2019 - Suite: 'CARM'
% ===========================================================================
%% Options for common configuration %%
% Input format: Preprocessing(x, '[Field Name]', '[Permitted Argument]')
%
% Argument Description format:
% '[Field Name]': Description
%   - '[Permitted Argument 1]':  Description (example)
%   - '[Permitted Argument 2]':  Description (example)
%
% Tips: field name is not case sensititive.
%
% ===========================================================================
% 'Suite': the default processing method
%   - 'WiDance': Spectrogram generation using the method of WiDance
%   - 'CARM': Spectrogram generation using the method of CARM
% ===========================================================================
% Arguments for spectrogram generation methods
% 
% 'fs': the sampling rate
%   - scalra numeric: 1000
%
% 'filter': set the filter-based denoise method
%   - 'lpf': low-pass filter
%   - 'bpf': band-pass filter
%   - 'hpf': high-pass filter
%
% 'passband': set the parameter of denoise methods
% 'lpf/hpf': scalar numeric, e.g., 200
% 'bpf': 2-D numeric array, e.g., [2 200]
%
% 'dcRemove': Window for removing the DC component.
%   - 2-D numeric array: [Window Size, Stride Length]
%   - window of dcRemove should be larger than aht of pca
%
% 'pca': pca-based de-noise
%   - 2-D numeric array: [Window Size, Stride Length, Candidate Components]
%
% 'stft': The size of STFT window.
%   - 2-D numeric array: [Window Size, Stride Length]
%
% 'phaseCalibration': Setting phase calibration methods
%   - 'conjMul': using conjugate multiplication to realize phase
%   calibration (WiDance)
%
% 'device': Set the device type
%   - 'iwl5300': Intel Wi-Fi Link 5000 Series adapters

%% Default suite configuration - using InFit
defaultSuiteName = 'infit'; % Suite
expectedSuite = {'infit','widance','carm'};
defaultFs = 1000; % Samping rate
defaultFilter = 'bpf'; % Filter
expectedFilter = {'lpf','bpf','hpf'};
defaultPassband = [2,200]; % passband for lpf/bpf/hpf filter
defaultDcRemove = [4000,1000]; % DC removal
defaultPca = [1000,1000,2:15]; % PCA
defaultStft = [512,32,5]; % stft
defaultAntSel = true; % Antenna selection
defaultPhaseCallibration = 'conjMul'; % phaseCalibration
expectedPhaseCallibration = {'conjMul'};
defaultDevice = 'iwl5300'; % device
expectedDevice = {'iwl5300'};

%% Input validation
p = inputParser;    % Parser generation

% 'csiMatrix' should be a numeric 2-d matrix
validFunCSI = @(x) validateattributes(x, {'numeric'}, {'2d','nonnan'});
addRequired(p,'csiMatrix',validFunCSI);

% suite: 'InFit', 'WiDance', 'CARM'
addParameter(p,'suite',defaultSuiteName, @(x) any(validatestring(x,expectedSuite)));

% Sampling frequency should be a numeric number
validFunFs = @(x) validateattributes(x, {'numeric'}, {'scalar','positive'});
addParameter(p,'fs',defaultFs,validFunFs);

% filter: 'lpf', 'bpf', 'hpf'
addParameter(p,'filter',defaultFilter, @(x) any(validatestring(x,expectedFilter)));

% Passband validation
validFunPassband = @(x) validateattributes(x, {'numeric'}, {'positive','increasing'});
addParameter(p,'passband',defaultPassband,validFunPassband);

% stft/dcRemove should be a numeric array with 2 components
% - [Window Size], [Stride Length]
validFunDC = @(x) validateattributes(x, {'numeric'}, {'positive','numel',2});
addParameter(p,'dcRemove',defaultDcRemove,validFunDC);

% pca should be a numeric array with more than 2 components
% - [Window Size], [Stride Length], [Candidate Components]
validFunPca = @(x) validateattributes(x, {'numeric'}, {'positive','vector'});
addParameter(p,'pca',defaultPca,validFunPca);

% stft should be a numeric array with 3 components
% - [Window Size], [Stride Length], [Spectrogram Clear Window]
% - [Spectrogram Clear Window] = 0: no clear process
validFunStft = @(x) validateattributes(x, {'numeric'}, {'nonnegative','vector','numel',3});
addParameter(p,'stft',defaultStft,validFunStft);

% Antenna selection validation
addParameter(p,'phaseCalibration',defaultPhaseCallibration, @(x) any(validatestring(x,expectedPhaseCallibration)));

% 'device': 'iwl5300'
addParameter(p,'device',defaultDevice, @(x) any(validatestring(x,expectedDevice)));
             
% suite check
parse(p,csiMatrix,varargin{:}); % Validation

%% Suite check - if customized the parameters
customSuite.suite = p.Results.suite;
customSuite.fs = p.Results.fs;
customSuite.filter = p.Results.filter;
customSuite.passband = p.Results.passband;
customSuite.dcRemove = p.Results.dcRemove;
customSuite.pca = p.Results.pca;
customSuite.stft = p.Results.stft;
customSuite.phaseCalibration = p.Results.phaseCalibration;
customSuite.device = p.Results.device;

%% Preprocessing
% Parsing the csiMatrix
timeInfo = real(csiMatrix(:,1:2)); % timestamp_low and bfee_count
if contains(customSuite.device,'iwl5300','IgnoreCase',true)
    csiLinkNum = round(size(csiMatrix,2)/30);
    csiColEndIdx = 3+csiLinkNum*30-1;
    if csiColEndIdx > 3
        csi = csiMatrix(:,3:csiColEndIdx); % csi
    end
    if csiColEndIdx < size(csiMatrix,2)
        rssi = csiMatrix(:,csiColEndIdx+1:size(csiMatrix,2)); % rssi
    end
end

% Preprocessing according to the suite name
switch upper(customSuite.suite)
    case 'INFIT'
        output = preprocessSuitInFit(csi,customSuite);
        
    case 'WIDANCE'
        % Change the parameter of default WiDance suite
        customSuite.FILTER = 'BPF';
        customSuite.PERMITBAND = [2 200];
        customSuite.WINSTFT = 1024;
        customSuite.OVERLAP = 992;
        customSuite.PCC = 2;
        customSuite.ANTSEL = true;

        idx = ~cellfun(@(f)any(strcmp(f,fieldnames(customSuite))),cFld);
        if any(idx)
            error('Unsupported field name/s:%s\b',sprintf(' <%s>,',cFld{idx}))
        end
        suite = configComplete(customSuite,customSuite);
        output = Preprocessing_Suit_Widance(x,suite);
        
    case 'CARM'
        % Change the parameter of default CARM suite
        customSuite.CLEANSPEC = true;
        customSuite.WINSPECLPF = 5;
        customSuite.FILTER = 'LPF';
        customSuite.PERMITBAND = 200;
        customSuite.WINSTFT = 1024;
        customSuite.OVERLAP = 992;
        
        idx = ~cellfun(@(f)any(strcmp(f,fieldnames(customSuite))),cFld);
        if any(idx)
            error('Unsupported field name/s:%s\b',sprintf(' <%s>,',cFld{idx}))
        end
        suite = configComplete(customSuite,customSuite);
        output = Preprocessing_Suit_CARM(x,suite);
end

for i = 1:nargout
    varargout{i} = output{i};
end

end

%% Suite completion
function custom_suit = configComplete(custom_suit,default_suit)
    suit_fl = fieldnames(custom_suit);
    for i = 1:length(suit_fl)
        value = custom_suit.(suit_fl{i});
        default_suit.(suit_fl{i}) = value;
    end
    custom_suit = default_suit;
end