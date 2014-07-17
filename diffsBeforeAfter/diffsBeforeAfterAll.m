function results = diffsBeforeAfterAll(pigDataNTB)
% DIFFSBEFOREAFTERALL executes diffsBeforeAfter for several signals  and saves results to excel-sheets
%
% inputs: None
%
% output:
% results: vector containing result-structs from diffsBeforeAfter for
% various signals
% 
% Lukas Beichert, l.beichert@stud.uni-heidelberg.de
% June 2014

% add /tools to path
addpath('../tools/');

% determine where to save the output files
outputDir = 'output/';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% define start and target temperature
tempStart = 37.0;
tempTarget = 33.8;
plots = 0;

% perform calculations
results(1) = diffsBeforeAfter(pigDataNTB,'HbT', tempStart, tempTarget, plots);
results(2) = diffsBeforeAfter(pigDataNTB,'Hb',tempStart, tempTarget, plots);
results(3) = diffsBeforeAfter(pigDataNTB,'HbO2', tempStart, tempTarget, plots);
results(4) = diffsBeforeAfter(pigDataNTB,'HbDiff', tempStart, tempTarget, plots);
results(5) = diffsBeforeAfter(pigDataNTB,'CtOx', tempStart, tempTarget,plots);
results(6) = diffsBeforeAfter(pigDataNTB,'BP3 Mean', tempStart, tempTarget, plots);
results(7) = diffsBeforeAfter(pigDataNTB,'BP3 Rate', tempStart, tempTarget, plots);
results(8) = diffsBeforeAfter(pigDataNTB,'SpO2', tempStart, tempTarget, plots);


% save results to excel sheets

id = regexprep(num2str(tempStart), '\.', 'dot');

% output in string format ( value +/- std)
header = {'Piglet', 'Group', 'HbT', 'HbDiff', 'oxCCO', 'MABP', 'Heartrate', 'SpO2'};
col = [];
col = [col, results(1).pigN, results(1).group];
for j = [1,4,5,6,7,8]
    col = [col,results(j).sChromDiff'];
end

sheet = [header;col];

xlswrite([outputDir,'dba',id,'.xlsx'], sheet);


% numerical format output

col2 = [];
col2 = [col2, results(1).pigN, results(1).group];
for j = [1,4,5,6,7,8]
    col2 = [col2, num2cell(results(j).chromDiff)];
end

sheet2 = [header;col2];

xlswrite([outputDir,'num_dba',id,'.xlsx'], sheet2);
end

