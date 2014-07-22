function [results] = diffsBeforeAfter(DataNTB,signalName,tempStart, tempTarget, plots)
% DIFFSBEFOREAFTER compares values of signal at two temperatures
%
% inputs:
%
% DataNTB:              data struct as produced by DataAnalyse
% nameChrom:            name of the considered signal 
% tempStart/tempTarget: start and target temperatures
% plots:                create plots? true/false
% 
% 
% outputs:
% 
% results.
%  pigN:                  subject ID
%  group:                 treatment Group
%  signal:                name of signal analysed ('HbDiff', 'HbT',..)
%  chromStartMean / Std : mean / standard deviation of datapoints at tempStart
%  chromTargetMean / Std: mean / standard deviation of datapoints at tempTarget
%  chromDiff(Std):        difference between chromStartMean & chromTargetMean (uncertainty)
%  h:                     difference statistically significant? (1:yes, 0:no)
%  p:                     p-Value of significance test
%
% Lukas Beichert, l.beichert@stud.uni-heidelberg.de
% June 2014
 
c = find(strcmp(DataNTB(1).headers,signalName));

% initialise results struct
results.pigN = [];
results.group = [];
results.signal = [];
results.signalStartMean = [];
results.signalStartStd = [];
results.signalTargetMean = [];
results.signalTargetStd = [];
results.signalDiff = [];
results.signalDiffStd = [];
results.h = [];
results.p = [];

for n = 1:length(DataNTB)
    
    % load data into variables
    S = DataNTB(n);
    time = S.elapsed;
    signalData = S.data(:,c);
    temp = S.data(:,3);
    pigN = {S.subj};
    group = S.group;
    
    
    % make sure temperature range is covered
    tempMax = max(temp);
    tempMin = min(temp);
    
    if ~(tempMax>tempStart) || ~(tempMin<tempTarget)
        % disp([cell2mat(pigN),' ', namesignal, ': temperature range not covered'])
        continue
    end
    
    % find positions of T=tempStart and T=tempTarget
    k = 1:length(time)-1;
    timeTarget = find((temp(k) > tempTarget) & (temp(k+1) < tempTarget), 1);
    timeStart = find((temp(k) > tempStart) & (temp(k+1) < tempStart), 1);
    
    % check if dataset is long enough
    if ~(timeTarget-timeStart > 40)
        % disp([pigN,' ', namesignal, ': dataset not long enough'])
        continue
    end
    
    
    
    %% calculate means of signal at timeStart and timeTarget
    
    signalStart = signalData(timeStart:timeStart+19);
    signalStartMean = mean(signalStart);
    signalStartStd = std(signalStart);    
    signalTarget = signalData((timeTarget-19):timeTarget);
    signalTargetMean = mean(signalTarget);
    signalTargetStd = std(signalTarget);

    
    %% calculate difference in signal
    signalDiff = signalTargetMean - signalStartMean;
    signalDiffStd = sqrt(signalTargetStd^2 + signalStartStd^2);
    
    
    %% create plot (if wanted)
    if( plots )
        f = figure();
        %         subplot(2,1,1)
        plot(time(1:timeTarget+5),signalData(1:timeTarget+5), 'color','r');
        l1 = line([time(timeStart),time(timeStart+20)], [signalStartMean,signalStartMean], 'color', 'k');
        l2 = line([time(timeTarget-20),time(timeTarget)], [signalTargetMean,signalTargetMean],'color', 'k');
        set(l1, 'LineWidth', 2);
        set(l2, 'LineWidth', 2);
        title(pigN);
        ylabel([signalName, ' [µM]'])
        xlabel('time [s]');
        %         subplot(2,1,2)
        %         plot(time(1:timeTarget+5), temp(1:timeTarget+5));
    end
    
    %% check if signalStart and signalTarget are normally distributed, yes->ttest, no->wilcoxon, in order to check significance of change
    try
        if lillietest(signalStart) || lillietest(signalTarget)
            % disp([S.subj, ': ', namesignal, ' not normally distributed'])
            [p, h] = ranksum(signalStart, signalTarget, 'alpha', 0.01);
        else
            [h, p] = ttest(signalStart,signalTarget, 0.01);
        end
        
    catch err
        disp(['error performing lilleford test for ', S.subj, ': ', signalName]);
        disp(err.message);
    end
    
    %% save results into results struct
    
    results.pigN = [results.pigN;pigN];
    results.group = [results.group;group];
    results.signal = [results.signal; signalName];
    results.signalStartMean = [results.signalStartMean;signalStartMean];
    results.signalStartStd = [results.signalStartStd; signalStartStd];
    results.signalTargetMean = [results.signalTargetMean; signalTargetMean];
    results.signalTargetStd = [results.signalTargetStd; signalTargetStd];
    results.signalDiff = [results.signalDiff; signalDiff];
    results.signalDiffStd = [signalDiffStd; results.signalDiffStd];
    results.h = [results.h;h];
    results.p = [results.p;p];
    
end


% create strings for output (mean +/- std)
for j=1:length(results.pigN)
    if strcmp(signalName, 'HbDiff') || strcmp(signalName, 'HbT')
        signalDiffStr(j) = {sprintf('%4.2f +/- %4.2f', results.signalDiff(j), results.signalDiffStd(j))};
        
        % add (*) if t/Wilcoxon test non-significant
        if ~isnan(results.h(j))
            if ~results.h(j)
                signalDiffStr(j) = {[signalDiffStr{j},' (*)']};
            end
        else
            signalDiffStr(j) = {[signalDiffStr{j},' (?)']};
        end
        
    elseif strcmp(signalName, 'CtOx')
        signalDiffStr(j) = {sprintf('%4.3f +/- %4.3f', results.signalDiff(j), results.signalDiffStd(j))};
        
        % add (*) if t/Wilcoxon test non-significant
        if ~isnan(results.h(j))
            if ~results.h(j)
                signalDiffStr(j) = {[signalDiffStr{j},' (*)']};
            end
        else
            signalDiffStr(j) = {[signalDiffStr{j},' (?)']};
        end
        
    else
        signalDiffStr(j) = {sprintf('%4.1f +/- %4.1f', results.signalDiff(j), results.signalDiffStd(j))};
        
        % add (*) if t/Wilcoxon test non-significant
        if ~isnan(results.h(j))
            if ~results.h(j)
                signalDiffStr(j) = {[signalDiffStr{j},' (*)']};
            end
        else
            signalDiffStr(j) = {[signalDiffStr{j},' (?)']};
        end
        
    end
end
results.signalDiffStr = signalDiffStr;

end