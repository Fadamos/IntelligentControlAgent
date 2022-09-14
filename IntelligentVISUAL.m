%% Script 
s0      = IntelligentDECISION(df, 1, "S0", 0.05, 1);
s_He    = IntelligentDECISION(df, 1, "S_He", 0.05, 1);
s_Ho    = IntelligentDECISION(df, 1, "S_Ho", 0.05, 1);
s1      = IntelligentDECISION(df, 1, "S1", 0.05, 1);
s2      = IntelligentDECISION(df, 1, "S2", 0.05, 1);
s3      = IntelligentDECISION(df, 1, "S3", 0.05, 1);
s4      = IntelligentDECISION(df, 1, "S4", 0.05, 1);
s5      = IntelligentDECISION(df, 1, "S5", 0.05, 1);
s6      = IntelligentDECISION(df, 1, "S6", 0.05, 1);
s7      = IntelligentDECISION(df, 1, "S7", 0.05, 1);
s8      = IntelligentDECISION(df, 1, "S8", 0.05, 1);
s9      = IntelligentDECISION(df, 1, "S9", 0.05, 1);
s10     = IntelligentDECISION(df, 1, "S10", 0.05, 1);
s11     = IntelligentDECISION(df, 1, "S11", 0.05, 1);

MatData = []; 
MatData1 = []; 

MetricsFieldname = fieldnames(s0.Metrics);
for metric = 1:numel(MetricsFieldname)
    for TP = 1:25
        %MatData(TP, 1, metric)  = s0.Metrics.(MetricsFieldname{metric}).mean(TP);
        %MatData(TP, 2, metric)  = s_He.Metrics.(MetricsFieldname{metric}).mean(TP);
        %MatData(TP, 3, metric)  = s_Ho.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 1, metric)  = s1.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 2, metric)  = s2.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 3, metric)  = s3.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 4, metric)  = s4.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 5, metric)  = s5.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 6, metric)  = s6.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 7, metric) = s7.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 8, metric) = s8.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 9, metric) = s9.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 10, metric) = s10.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 11, metric) = s11.Metrics.(MetricsFieldname{metric}).mean(TP);
    end
end


    figure(1) 
    subplot(2,3,1)
        ylim([0 1])
        boxplot(MatData(:,:,1)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M1','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Success','interpreter','latex', 'FontSize', 16)

    subplot(2,3,2)
        ylim([0 1])
        boxplot(MatData(:,:,2)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M2', 'interpreter','latex','FontSize', 16)
        ylabel('Mission Decision Stability','interpreter','latex', 'FontSize', 16)
    
    subplot(2,3,3)
        ylim([0 20])
        boxplot(MatData(:,:,3)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M3', 'interpreter','latex','FontSize', 16)
        ylabel('Swarm Decision Stability','interpreter','latex', 'FontSize', 16)

    subplot(2,3,4)
        ylim([0 0.4])
        boxplot(MatData(:,:,4)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M4','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Swarm Stability','interpreter','latex', 'FontSize', 16)
    
    subplot(2,3,5)
        ylim([0 9])
        boxplot(MatData(:,:,5)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs','interpreter','latex', 'FontSize', 16)
        title('Metric M5','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Completion Rate','interpreter','latex', 'FontSize', 16)
    
    subplot(2,3,6)
        ylim([0 0.3])
        boxplot(MatData(:,:,6)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs','interpreter','latex', 'FontSize', 16)
        title('Metric M6','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Speed Ratio','interpreter','latex', 'FontSize', 16)

    % sgtitle('TP Distribution for S$_0$','interpreter','latex','FontSize',20)

    figure(2) 
    subplot(1,2,1)
        boxplot(MatData1(:,:,1)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M1 for Scenario S$_{He}$','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Success','interpreter','latex', 'FontSize', 16)
        ylim([-0.01 1.1])
    subplot(1,2,2)
        heatmap(MatData(:,:,1)'), 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M1 for Scenario S$_{Ho}$','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Success','interpreter','latex', 'FontSize', 16)
        ylim([-0.01 1.1])


%% TABLES 

% S0 
for COLLECT = 1:5
    for DRIVE = 1:5 
    statsignif(COLLECT,DRIVE) = sum([s1.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s2.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s3.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s4.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s5.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s6.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s7.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s8.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s9.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s10.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s11.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE)]);
    end
end

statsignif/11*100

MetricsFieldname = fieldnames(s0.Metrics);
for metric = 1:numel(MetricsFieldname)
    for COLLECT = 1:5
        for DRIVE = 1:5 
        statsignifALL(COLLECT,DRIVE, metric) = sum([s1.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
        s2.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s3.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s4.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s5.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s6.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s7.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s8.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s9.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s10.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE), ...
        s11.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2(COLLECT,DRIVE)]);
        end
    end
end

sum(statsignifALL,3)/66*100

% S_He
for COLLECT = 1:5
    for DRIVE = 1:5 
    statsignif_He(COLLECT,DRIVE) = sum([s1.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s2.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s3.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s4.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE)]);
    end
end

statsignif_He/4*100

% S_Ho
for COLLECT = 1:5
    for DRIVE = 1:5 
    statsignif_Ho(COLLECT,DRIVE) = sum([s5.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s6.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s7.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s8.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s9.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s10.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE), ...
    s11.Metrics.MissionSuccess.HypothTest.ttest2(COLLECT,DRIVE)]);
    end
end

statsignif_Ho/7*100





%% Visualisations
boxplot(MatData')
title('Mission Success')
xlabel('Tactic Pair')
ylabel('Score')

spider_plot(MatData, ...
    'AxesLabels', {'S0' 'S_{He}' 'S_{Ho}' 'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8' 'S9' 'S10' 'S11'}, ...
    'AxesLimits', [0 0 0 0 0 0 0 0 0 0 0 0 0 0; 1 1 1 1 1 1 1 1 1 1 1 1 1 1], ...
    'Color', distinguishable_colors(25))
% Title and legend settings
title(sprintf('Mission Success'),...
    'FontSize', 16);
legend_str = {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'};
legend(legend_str, 'Location', 'eastoutside');


boxplot(MatData')

spider_plot(MatData, ...
    'AxesLabels', {'S0' 'S_{He}' 'S_{Ho}' 'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8' 'S9' 'S10' 'S11'}, ...
    'AxesLimits', [0 0 0 0 0 0 0 0 0 0 0 0 0 0; 1 1 1 1 1 1 1 1 1 1 1 1 1 1], ...
    'Color', distinguishable_colors(25))
% Title and legend settings
title(sprintf('Mission Success'),...
    'FontSize', 16);
legend_str = {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'};
legend(legend_str, 'Location', 'eastoutside');


%% max - mean - min - strombom 
mmms = nan(4,14);
mmms(4,:) = MatData(5,:);
mmms(3,:) = mean(MatData);
mmms(2,:) = min(MatData);
mmms(1,:) = max(MatData); 

plot(mmms')
legend({'Max' 'Mean' 'Min' 'Strombom'}, 'Location', 'northwest')
xlabel('Scenario')
ylabel('Mission Success')

