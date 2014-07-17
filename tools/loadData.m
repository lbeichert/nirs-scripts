function [] = loadData(suffix)
% LOADDATA load (processed) pigData into workspace
%
% input:
% suffix: '31p', 'cooling', '1h', ...
%     
% output:
% pigDataNTB
% 
% Lukas Beichert, l.beichert@stud.uni-heidelberg.de
% June 2014


% data directory specified by appdata-variable 'pigletdatadir'
datadir = getappdata(0, 'pigletdatadir');

% load (processed) data from 'datadir/argon-dex/output/cooling/pigData.m'
try
    Data = load([datadir,filesep,'argon-dex',filesep,'output',filesep,suffix,filesep,'pigData']);
catch err
    disp('no such folder');
    pigDataNTB = NaN;
    return
end

% save into variable 'pigDataNTB' used by other scripts
pigDataNTB = Data.pigDataNTB;
assignin('base', 'pigDataNTB', pigDataNTB);
end