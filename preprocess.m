function y = preprocess(csiMat,varargin)
%% De-noise, calibration and interpolation
% ==============================================================
% Preprocessing the wireless signals for sensing problem
% ===========================================================================
%% Syntax:
%  y = Preprocessing(csiMat)
%  y = Preprocessing(csiMat,varargin)
%   - e.g., [psd,frequency,~] = Preprocessing(x,'suite','infit')
%
% 'csiMat': a numeric 2-D matrix contains timestamp_low/bfee_count/csi/rssi
%   - The size(csiMat,1) is the packetNum.
%
% Updating:
%   13/4/2020 - Suite: 'InFit'
%   10/23/2019 - Suite: 'CARM'
% ===========================================================================
%% Parameter description
% ===========================================================================
% 'Suite': the default processing method
%   - 'InFit': The default suite
%   - 'WiDance': Spectrogram generation using the method of WiDance
%   - 'CARM': Spectrogram generation using the method of CARM
% 
% 'fs': the sampling rate
%   - scalra numeric: 1000
%
% 'filter': set the filter-based denoise method
%   - 'lpf': low-pass filter
%   - 'bpf': band-pass filter
%   - 'hpf': high-pass filter
%
% 'fc': set the parameter of cutoff frequency
%   - scalar numeric, e.g., 200
%   - 2-D numeric array, e.g., [2 200]
%
% 'pca': pca-based de-noise
%   - 2-D numeric array: [PCA window, Candidate components]
%
% 'stft': The size of STFT window.
%   - numeric array: [Window Size, Stride Length, Spectrogram Clean Window Size]
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
defaultFc = [2,200]; % fc for lpf/bpf/hpf filter
defaultPca = [4000,1000,2:15]; % PCA
defaultStft = [512,16,5]; % stft
defaultPhaseCallibration = 'conjuMulti'; % phaseCalibration
expectedPhaseCallibration = {'conjuMulti'};
defaultDevice = 'iwl5300'; % device
expectedDevice = {'iwl5300'};

%% Input validation
p = inputParser;    % Parser generation

% 'csiMat' should be a numeric 2-d matrix
validFunCSI = @(x) validateattributes(x, {'numeric'}, {'2d','nonnan'});
addRequired(p,'csiMat',validFunCSI);

% suite: 'InFit', 'WiDance', 'CARM'
addParameter(p,'suite',defaultSuiteName, @(x) any(validatestring(x,expectedSuite)));

% Sampling frequency should be a numeric number
validFunFs = @(x) validateattributes(x, {'numeric'}, {'scalar','positive'});
addParameter(p,'fs',defaultFs,validFunFs);

% filter: 'lpf', 'bpf', 'hpf'
addParameter(p,'filter',defaultFilter, @(x) any(validatestring(x,expectedFilter)));

% fc validation
validFunFc = @(x) validateattributes(x, {'numeric'}, {'positive','increasing'});
addParameter(p,'fc',defaultFc,validFunFc);

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
parse(p,csiMat,varargin{:}); % Validation

%% Suite check - if customized the parameters
customSuite.suite = p.Results.suite;
customSuite.device = p.Results.device;

%% Preprocessing
% Parsing the csiMat
timeInfo = real(csiMat(:,1:2)); % timestamp_low and bfee_count
if contains(customSuite.device,'iwl5300','IgnoreCase',true)
    csiLinkNum = round(size(csiMat,2)/30);
    csiColEndIdx = 3+csiLinkNum*30-1;
    if csiColEndIdx > 3
        csi = csiMat(:,3:csiColEndIdx); % csi
    end
    if csiColEndIdx < size(csiMat,2)
        rssi = csiMat(:,csiColEndIdx+1:size(csiMat,2)); % rssi
    end
end

% Preprocessing according to the suite name
switch upper(customSuite.suite)
    case 'INFIT'
        customSuite.fs = p.Results.fs;
        customSuite.filter = p.Results.filter;
        customSuite.fc = p.Results.fc;
        customSuite.pca = p.Results.pca;
        customSuite.stft = p.Results.stft;
        customSuite.phaseCalibration = p.Results.phaseCalibration;
        
        output = preprocessSuitInFit(csi,customSuite);
        
    case 'WIDANCE'
        % Change the parameter of default WiDance suite
        customSuite.fs = p.Results.fs;
        customSuite.filter = p.Results.filter;
        customSuite.fc = p.Results.fc;
        customSuite.pca = p.Results.pca;
        customSuite.stft = p.Results.stft;
        customSuite.phaseCalibration = p.Results.phaseCalibration;

        output = preprocessSuitWidance(csi,customSuite);
        
    case 'CARM'
        customSuite.fs = p.Results.fs;
        customSuite.pca = p.Results.pca;
        customSuite.stft = p.Results.stft;
        
        output = preprocessSuitCarm(csi,customSuite);
end

y = output;

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