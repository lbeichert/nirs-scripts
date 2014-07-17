function [results] = diffsBeforeAfter(DataNTB,nameChrom,tempStart, tempTarget, plots)
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
 
 
c = find(strcmp(DataNTB(1).headers,nameChrom));

% initialise results struct
results.pigN = [];
results.group = [];
results.signal = [];
results.chromStartMean = [];
results.chromStartStd = [];
results.chromTargetMean = [];
results.chromTargetStd = [];
results.chromDiff = [];
results.chromDiffStd = [];
results.h = [];
results.p = [];

for n = 1:length(DataNTB)
    
    % load data into variables
    S = DataNTB(n);
    time = S.elapsed;
    chromData = S.data(:,c);
    temp = S.data(:,3);
    pigN = {S.subj};
    group = S.group;
    
    
    % make sure temperature range is covered
    tempMax = max(temp);
    tempMin = min(temp);
    
    if ~(tempMax>tempStart) || ~(tempMin<tempTarget)
        % disp([cell2mat(pigN),' ', nameChrom, ': temperature range not covered'])
        continue
    end
    
    % find positions of T=tempStart and T=tempTarget
    k = 1:length(time)-1;
    timeTarget = find((temp(k) > tempTarget) & (temp(k+1) < tempTarget), 1);
    timeStart = find((temp(k) > tempStart) & (temp(k+1) < tempStart), 1);
    
    % check if dataset is long enough
    if ~(timeTarget-timeStart > 40)
        % disp([pigN,' ', nameChrom, ': dataset not long enough'])
        continue
    end
    
    
    
    %% calculate means of signal at timeStart and timeTarget
    
    chromStart = chromData(timeStart:timeStart+19);
    chromStartMean = mean(chromStart);
    chromStartStd = std(chromStart);    
    chromTarget = chromData((timeTarget-19):timeTarget);
    chromTargetMean = mean(chromTarget);
    chromTargetStd = std(chromTarget);

    
    %% calculate difference in chrom
    chromDiff = chromTargetMean - chromStartMean;
    chromDiffStd = sqrt(chromTargetStd^2 + chromStartStd^2);
    
    
    %% create plot (if wanted)
    if( plots )
        f = figure();
        %         subplot(2,1,1)
        plot(time(1:timeTarget+5),chromData(1:timeTarget+5), 'color','r');
        l1 = line([time(timeStart),time(timeStart+20)], [chromStartMean,chromStartMean], 'color', 'k');
        l2 = line([time(timeTarget-20),time(timeTarget)], [chromTargetMean,chromTargetMean],'color', 'k');
        set(l1, 'LineWidth', 2);
        set(l2, 'LineWidth', 2);
        title(pigN);
        ylabel([nameChrom, ' [µM]'])
        xlabel('time [s]');
        %         subplot(2,1,2)
        %         plot(time(1:timeTarget+5), temp(1:timeTarget+5));
    end
    
    %% check if chromStart and chromTarget are normally distributed, yes->ttest, no->wilcoxon, in order to check significance of change
    try
        if lillietest(chromStart) || lillietest(chromTarget)
            % disp([S.subj, ': ', nameChrom, ' not normally distributed'])
            [p, h] = ranksum(chromStart, chromTarget, 'alpha', 0.01);
        else
            [h, p] = ttest(chromStart,chromTarget, 0.01);
        end
        
    catch err
        disp(['error performing lilleford test for ', S.subj, ': ', nameChrom]);
        disp(err.message);
    end
    
    %% save results into results struct
    
    results.pigN = [results.pigN;pigN];
    results.group = [results.group;group];
    results.signal = [results.signal; nameChrom];
    results.chromStartMean = [results.chromStartMean;chromStartMean];
    results.chromStartStd = [results.chromStartStd; chromStartStd];
    results.chromTargetMean = [results.chromTargetMean; chromTargetMean];
    results.chromTargetStd = [results.chromTargetStd; chromTargetStd];
    results.chromDiff = [results.chromDiff; chromDiff];
    results.chromDiffStd = [chromDiffStd; results.chromDiffStd];
    results.h = [results.h;h];
    results.p = [results.p;p];
    
end


% create strings for output (mean +/- std)
for j=1:length(results.pigN)
    if strcmp(nameChrom, 'HbDiff') || strcmp(nameChrom, 'HbT')
        sChromDiff(j) = {sprintf('%4.2f +/- %4.2f', results.chromDiff(j), results.chromDiffStd(j))};
        
        % add (*) if t/Wilcoxon test non-significant
        if ~isnan(results.h(j))
            if ~results.h(j)
                sChromDiff(j) = {[sChromDiff{j},' (*)']};
            end
        else
            sChromDiff(j) = {[sChromDiff{j},' (?)']};
        end
        
    elseif strcmp(nameChrom, 'CtOx')
        sChromDiff(j) = {sprintf('%4.3f +/- %4.3f', results.chromDiff(j), results.chromDiffStd(j))};
        
        % add (*) if t/Wilcoxon test non-significant
        if ~isnan(results.h(j))
            if ~results.h(j)
                sChromDiff(j) = {[sChromDiff{j},' (*)']};
            end
        else
            sChromDiff(j) = {[sChromDiff{j},' (?)']};
        end
        
    else
        sChromDiff(j) = {sprintf('%4.1f +/- %4.1f', results.chromDiff(j), results.chromDiffStd(j))};
        
        % add (*) if t/Wilcoxon test non-significant
        if ~isnan(results.h(j))
            if ~results.h(j)
                sChromDiff(j) = {[sChromDiff{j},' (*)']};
            end
        else
            sChromDiff(j) = {[sChromDiff{j},' (?)']};
        end
        
    end
end
results.sChromDiff = sChromDiff;

end