function [user,gesture,number,intensity,loc,dir,date] = getExpConfigFromFileName(filename)
%% Parsing filename w.r.t. "Data Collection Table.xlsx"
%   - Standard format of filename is 
%      'U1_G1_N10_L_L1_D0_20200408_1'
strArray = split(filename,"_");

%% User
str = strArray{1};
userFmtchk = @(x) (x(1)=='U' && prod(isstrprop(x(2:end),'digit')));
assert(userFmtchk(str),'Wrong input format of getExpConfigFromFileName(filename)');
user = str2double(str(2:end));

%% Gesture
str = strArray{2};
gesFmtchk = @(x) (x(1)=='G' && prod(isstrprop(x(2:end),'digit')));
assert(gesFmtchk(str),'Wrong input format of getExpConfigFromFileName(filename)');
gesture = str2double(str(2:end));

%% Number
str = strArray{3};
numFmtchk = @(x) (x(1)=='N' && prod(isstrprop(x(2:end),'digit')));
assert(numFmtchk(str),'Wrong input format of getExpConfigFromFileName(filename)');
number = str2double(str(2:end));

%% Intensity
str = strArray{4};
intenseFmtchk = @(x) (length(x)==1 && (x=='L' || x=='H'));
assert(intenseFmtchk(str),'Wrong input format of getExpConfigFromFileName(filename)');
intensity = str;

%% Loc
str = strArray{5};
locFmtchk = @(x) (x(1)=='L' && prod(isstrprop(x(2:end),'digit')));
assert(locFmtchk(str),'Wrong input format of getExpConfigFromFileName(filename)');
loc = str2double(str(2:end));

%% Dir
str = strArray{6};
dirFmtchk = @(x) (x(1)=='D' && prod(isstrprop(x(2:end),'digit')));
assert(dirFmtchk(str),'Wrong input format of getExpConfigFromFileName(filename)');
dir = str2double(str(2:end));

%% Date
str = strArray{7};
dateFmtchk = @(x) (prod(isstrprop(x,'digit'))==1);
assert(dateFmtchk(str),'Wrong input format of getExpConfigFromFileName(filename)');
date = str2double(str);

end