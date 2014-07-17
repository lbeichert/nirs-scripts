function recoveryData = recoveryFractionAll(pigData, signalName, halfWidth)
% RECOVERYFRACTIONALL calls recoveryFraction for all piglets in pigDataNTB
% for signal 'signalName' with half width 'halfWidth'
%
% inputs:
% pigData: pigDataNTB or pigDataPTB, use tools/loadData to load
% signalName: name of signal to be analysed (spelled as in headers of pigData)
% halfWidth: half width of the averaging-window
% 
% outputs:
% recoveryData: matrix of with rows
%     {LWP..., meanBaseline, stdBaseline, meanInsult, stdInsult, meanRecovered, stdRecovered, recoveryFraction}
%
% Lukas Beichert, l.beichert@stud.uni-heidelberg.de
% July 2014


% array data is saved into
recoveryData = cell(length(pigData), 7);

for N = 1:length(pigData)
    S =  pigData(N);
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

end