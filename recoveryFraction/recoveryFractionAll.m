% RECOVERYFRACTIONALL calls recoveryFraction for all piglets in pigDataNTB
% for signal 'signalName' with half width 'halfWidth'
%
% outputs:
% recoveryData: matrix of with rows
%     {LWP..., meanBaseline, stdBaseline, meanInsult, stdInsult, meanRecovered, stdRecovered, recoveryFraction}
%
% author: Lukas Beichert
% date: 11/07/2014

% load pigDataNTB into workspace before running

if ~exist('pigDataNTB', 'var')
    disp('load pigDataNTB into workspace first');
    return
end

% which signal to analyse?
signalName = 'HbDiff';
halfWidth = 10;

% array data is saved into
recoveryData = cell(length(pigDataNTB), 7);

for N = 1:length(pigDataNTB)
    S =  pigDataNTB(N);
    [baselineData, insultData, recoveredData] = recoveryFraction(signalName,S, halfWidth);
    if ~strcmp(baselineData, 'stop')
        recoveryData{N,1} = S.subj; % #piglet
        recoveryData{N,2} = baselineData(1); % mean
        recoveryData{N,3} = baselineData(2); % std
        recoveryData{N,4} = insultData(1); % mean
        recoveryData{N,5} = insultData(2); % std
        recoveryData{N,6} = recoveredData(1); % mean
        recoveryData{N,7} = recoveredData(2); % std
        recoveryData{N,8} = ((baselineData(1)-insultData(1))/(recoveredData(1)-insultData(1)))*100; % recovery fraction
    else
        break;
    end
end

% tidy up
clearList = {'signalName', 'halfWidth', 'N', 'S', 'baselineData', 'insultData', 'recoveredData', 'clearList'};
clear(clearList{:});