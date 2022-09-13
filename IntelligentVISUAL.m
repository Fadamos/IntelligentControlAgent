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

for TP = 1:25
    MatData(TP, 1) = s0.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 2) = s_He.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 3) = s_Ho.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 4) = s1.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 5) = s2.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 6) = s3.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 7) = s4.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 8) = s5.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 9) = s6.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 10) = s7.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 11) = s8.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 12) = s9.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 13) = s10.Metrics.MissionSuccess.mean(TP);
    MatData(TP, 14) = s11.Metrics.MissionSuccess.mean(TP);
end

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

