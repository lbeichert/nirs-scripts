% DIFFSBEFOREAFTERALL executes diffsBeforeAfter for several signals  and saves results to excel-sheets
%


% load data
clear resultsTtest ;
datadir = getappdata(0, 'pigletdatadir');

% determine where to save the output files
outputDir = 'output/diffsBeforeAfter/';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

if(~exist('pigDataNTB', 'var'))
    pigDataNTB = loadData('cooling');
end

% define start and target temperature
tempStart = 37.0;
tempTarget = 33.8;
plots = 0;

% perform calculations
resultsTtest(1) = diffsBeforeAfter(pigDataNTB,'HbT', tempStart, tempTarget, plots);
resultsTtest(2) = diffsBeforeAfter(pigDataNTB,'Hb',tempStart, tempTarget, plots);
resultsTtest(3) = diffsBeforeAfter(pigDataNTB,'HbO2', tempStart, tempTarget, plots);
resultsTtest(4) = diffsBeforeAfter(pigDataNTB,'HbDiff', tempStart, tempTarget, plots);
resultsTtest(5) = diffsBeforeAfter(pigDataNTB,'CtOx', tempStart, tempTarget,plots);
resultsTtest(6) = diffsBeforeAfter(pigDataNTB,'BP3 Mean', tempStart, tempTarget, plots);
resultsTtest(7) = diffsBeforeAfter(pigDataNTB,'BP3 Rate', tempStart, tempTarget, plots);
resultsTtest(8) = diffsBeforeAfter(pigDataNTB,'SpO2', tempStart, tempTarget, plots);


% save results to excel sheets

id = regexprep(num2str(tempStart), '\.', 'dot');

% output in string format ( value +/- std)
header = {'Piglet', 'Group', 'HbT', 'HbDiff', 'oxCCO', 'MABP', 'Heartrate', 'SpO2'};
col = [];
col = [col, resultsTtest(1).pigN, resultsTtest(1).group];
for j = [1,4,5,6,7,8]
    col = [col,resultsTtest(j).sChromDiff'];
end

sheet = [header;col];

xlswrite([outputDir,'dba',id,'.xlsx'], sheet);


% numerical format output

col2 = [];
col2 = [col2, resultsTtest(1).pigN, resultsTtest(1).group];
for j = [1,4,5,6,7,8]
    col2 = [col2, num2cell(resultsTtest(j).chromDiff)];
end

sheet2 = [header;col2];

xlswrite([outputDir,'num_dba',id,'.xlsx'], sheet2);

