function [] = overviewPlots(pigDataNTB)
% OVERVIEWPLOTS create overview plots of piglet data and save them to files
% 
% inputs:
% pigDataNTB: 
% requires tools/printFigure in path
% 
% Lukas Beichert, l.beichert@stud.uni-heidelberg.de
% June 2014

close all;
if ~exist('pigDataNTB', 'var')
    loadCoolingData;
end

% location the figures are saved to
outputDir = 'output';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
 
for N = 1:length(pigDataNTB)
    S = pigDataNTB(N);
    
    pigN = S.subj;
    group = S.group{1};
    
    MABP = S.data(:,1); % mean arterial blood pressure
    HR = S.data(:,2); % heart rate
    T = S.data(:,3); % temperature    
    SpO2 = S.data(:,7); % oxygen saturation
    oxCCO = S.data(:,11); % oxidised cytochrome-c oxidase
    HbT = S.data(:,12); % total hemoglobin
    HbDiff = S.data(:,13); % hemoglobin difference
    
    
    
    f = figure('name', [pigN, ': Hb, CtOx (',group,')']);  
    
    %% plot HbDiff, HbT, oxCCO
    subplot('Position', [0.05, 0.65, 0.9, 0.30]);
    
    hold on
    plot(S.elapsed, HbDiff, 'r');
    [h, hline1, hline2] = plotyy(S.elapsed,HbT,S.elapsed,oxCCO);
    hold off
    
    set(h,{'fontsize'},{13;13}) ;
    set(h, {'ycolor'}, {'k';'k'});
    set(h, {'XTickLabel'}, {[];[]});
    set(get(h(1), 'ylabel'),'String','HbDiff, HbT [µM]', 'Color', 'k', 'FontSize', 14);
    set(get(h(2), 'ylabel'),'String','oxCCO [µM]','Color', 'k', 'FontSize', 14);
    set(hline1,'color', 'k');
    set(hline2,'color', 'g');
    
    grid;
    title(pigN,'FontSize', 16);
    legend('HbDiff', 'HbT','oxCCO');
    
    %% plot MABP and HR
    sh3 = subplot('Position', [0.05, 0.46, 0.9, 0.15]);
    
    [g, gline1, gline2] = plotyy(S.elapsed, MABP, S.elapsed, HR);
    
    set(g, {'ycolor'}, {'k';'k'});
    set(g, {'XTickLabel'}, {[];[]});
    set(g,{'fontsize'},{13;13}) ;
    set(g(1), 'ylim', [0,130], 'ytick', [0 40 80 120]);
    set(g(2), 'ylim', [0,300], 'ytick', [0 100 200 300]);
    set(get(g(1), 'ylabel'),'String','BPMean [mmHg]', 'Color', 'k', 'FontSize', 14);
    set(get(g(2), 'ylabel'),'String','BPRate [bpm]','Color', 'k', 'FontSize', 14);
    set(gline1,'color', 'k');
    set(gline2,'color', 'b');
    
    % make sure that MABP- and HR-axis non-negative
    ymin2 = get(g(2), 'ylim');
    if(ymin2(1) < 0)
        set(g(2), 'ylim', [0, ymin2(2)]);
    end
    grid;
    legend('BP Mean', 'BP Rate');
    
    %% plot SpO2
    sh4 = subplot('Position', [0.05, 0.27, 0.9, 0.15]);    
    
    h4 = plot(S.elapsed,SpO2);
    
    set(sh4, 'ylim', [80, 101],'XTickLabel',[]);
    set(sh4, 'fontsize', 13);
    grid;
    ylabel('SpO2 [%]', 'FontSize', 14);
    legend('SpO2 [%]');
    
    %% plot T
    sh2 = subplot('Position', [0.05, 0.08, 0.9, 0.15]);  

    h2 = plot(S.elapsed,T);
    
    grid;
    xlabel('Time [s]', 'FontSize', 14);
    ylabel('Temperature [°C]', 'FontSize', 14);
    set(sh2, 'FontSize', 13);
    legend('Temperature [°C]');
    
    %% save figures to files    
    printFigure(f, [outputDir,filesep,pigN,'_',group])
    saveas(f, [outputDir,filesep,pigN,'_', group], 'fig');
end