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

dat.s0 = s0; 
dat.s1 = s1; 
dat.s2 = s2; 
dat.s3 = s3; 
dat.s4 = s4; 
dat.s5 = s5; 
dat.s6 = s6; 
dat.s7 = s7; 
dat.s8 = s8; 
dat.s9 = s9;
dat.s10 = s10; 
dat.s11 = s11;
dat.s_He = s_He; 
dat.s_Ho = s_Ho; 

MatData = []; 
MatData1 = []; 

MetricsFieldname = fieldnames(s0.Metrics);
for metric = 1:numel(MetricsFieldname)
    for TP = 1:25
        MatData(TP, 1, metric)  = s0.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 2, metric)  = s_He.Metrics.(MetricsFieldname{metric}).mean(TP);
        MatData(TP, 3, metric)  = s_Ho.Metrics.(MetricsFieldname{metric}).mean(TP);
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
    %subplot(2,3,1)
        ylim([0 1])
        boxplot(MatData(:,:,1)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M1','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Success','interpreter','latex', 'FontSize', 16)
    figure(2)
    %subplot(2,3,2)
        ylim([0 1])
        boxplot(MatData(:,:,2)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M2', 'interpreter','latex','FontSize', 16)
        ylabel('Mission Decision Stability','interpreter','latex', 'FontSize', 16)
    figure(3)
    %subplot(2,3,3)
        ylim([0 20])
        boxplot(MatData(:,:,3)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M3', 'interpreter','latex','FontSize', 16)
        ylabel('Swarm Decision Stability','interpreter','latex', 'FontSize', 16)
    figure(4)
    %subplot(2,3,4)
        ylim([0 0.4])
        boxplot(MatData(:,:,4)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs', 'interpreter','latex','FontSize', 16)
        title('Metric M4','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Swarm Stability','interpreter','latex', 'FontSize', 16)
    figure(5)
    %subplot(2,3,5)
        ylim([0 9])
        boxplot(MatData(:,:,5)', 'Labels', {'TP1' 'TP2' 'TP3' 'TP4' 'TP5' 'TP6' 'TP7' 'TP8' 'TP9' 'TP10' 'T1P1' 'TP12' 'TP13' 'TP14' 'TP15' 'TP16' 'TP17' 'TP18' 'TP19' 'TP20' 'TP21' 'TP22' 'TP23' 'TP24' 'TP25'})
        xlabel('Tactic Pairs','interpreter','latex', 'FontSize', 16)
        title('Metric M5','interpreter','latex', 'FontSize', 16)
        ylabel('Mission Completion Rate','interpreter','latex', 'FontSize', 16)
    figure(6)
    %subplot(2,3,6)
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


%%%%%%%%%%%%%%%%%%%
%%%             %%%
%% PARETO CURVES %% 
%%%             %%%     
%%%%%%%%%%%%%%%%%%%

% (1) MDS (X) vs MS (Y) -- https://au.mathworks.com/matlabcentral/answers/558556-binary-logistic-regression-curve

y = reshape(s5.Metrics.MissionSuccess.mean, 1, []);
x = reshape(s5.Metrics.MissionDecisionStability.mean, 1, []);
[x,idx] = sort(x, 'descend'); 
y = y(idx); 

MDS = []; 
MDScd = []; 
RawData = s5.Metrics.MissionDecisionStability.RawData; 
fn = fieldnames(RawData);
for iter = 1:numel(fn)
    tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Avg Num Sep pi")./RawData.(fn{iter}).("Decision Chg")];
    %tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Avg Num Sep pi")];
    %tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Decision Chg")];
    MDS = [MDS; tmp]; 
    clear tmp 
    tmp = [RawData.(fn{iter}).("Drive Tactic") RawData.(fn{iter}).("Collect Tactic")];
    MDScd = [MDScd; tmp];
end

CollectSET = unique(MDScd(:,2));
DriveSET = unique(MDScd(:,1)); 

figure(1)
pltt = 1; 
for COLLECT = 1:length(CollectSET)
    for DRIVE = 1:length(DriveSET)
        idx = find(MDScd(:,1) == DriveSET(DRIVE) & MDScd(:,2) == CollectSET(COLLECT));
                
        mdl = fitglm(MDS(idx,2), MDS(idx,1), 'Distribution', 'binomial', 'Link', 'logit');
        xnew = linspace(0,max(MDS(:,2)),1000)';
        pred = predict(mdl, xnew);
        
        score_log = mdl.Fitted.Probability; % Pr estimates
        try 
            [Xlog,Ylog,Tlog,AUClog] = perfcurve(MDS(idx,1), score_log, 1);
        catch
            AUClog = -1;  
        end 

        subplot(5,5,pltt)
        scatter(MDS(idx,2), MDS(idx,1))
        hold on 
        plot(xnew,pred)
        str = sprintf('Drive = %s Collect = %s and Adj. AUC = %f',DriveSET(DRIVE),CollectSET(COLLECT), AUClog);
        title(str)

        pltt = pltt + 1; 
    end
end

% (2) MCR/MSp (X) vs MS (Y)

MDS = []; 
MDScd = []; 
RawData = s5.Metrics.MissionSuccess.RawData; 
fn = fieldnames(RawData);
for iter = 1:numel(fn)
    %tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Mssn Comp Rate")./RawData.(fn{iter}).("Mssn Speed")];
    %tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Mssn Comp Rate")];
    tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Mssn Speed")];
    MDS = [MDS; tmp]; 
    clear tmp 
    tmp = [RawData.(fn{iter}).("Drive Tactic") RawData.(fn{iter}).("Collect Tactic")];
    MDScd = [MDScd; tmp];
end

CollectSET = unique(MDScd(:,2));
DriveSET = unique(MDScd(:,1)); 

figure(1)
pltt = 1; 
for COLLECT = 1:length(CollectSET)
    for DRIVE = 1:length(DriveSET)
        idx = find(MDScd(:,1) == DriveSET(DRIVE) & MDScd(:,2) == CollectSET(COLLECT));
                
        mdl = fitglm(MDS(idx,2), MDS(idx,1), 'Distribution', 'binomial', 'Link', 'logit');
        xnew = linspace(0,sqrt(max(MDS(:,2))),1000)';
        pred = predict(mdl, xnew);
        
        score_log = mdl.Fitted.Probability; % Pr estimates
        try 
            [Xlog,Ylog,Tlog,AUClog] = perfcurve(MDS(idx,1), score_log, 1);
        catch
            AUClog = -1;  
        end 

        subplot(5,5,pltt)
        scatter(MDS(idx,2), MDS(idx,1))
        hold on 
        plot(xnew,pred)
        str = sprintf('Drive = %s Collect = %s and Adj. AUC = %f',DriveSET(DRIVE),CollectSET(COLLECT), AUClog);
        title(str)

        pltt = pltt + 1; 
    end
end

% (3) stepwiselm (X) vs MS (Y) - not useful but an interesting experiment nonetheless! 

MDS = []; 
MDScd = []; 
RawData = s5.Metrics.MissionSuccess.RawData; 
fn = fieldnames(RawData);
for iter = 1:numel(fn)
    %tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Mssn Comp Rate")./RawData.(fn{iter}).("Mssn Speed")];
    %tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Mssn Comp Rate")];
    %tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Mssn Speed")];
    tmp = [RawData.(fn{iter}).("Mssn Success") RawData.(fn{iter}).("Mssn Speed") RawData.(fn{iter}).("Mssn Comp Rate") RawData.(fn{iter}).("Mssn Comp Rate")./RawData.(fn{iter}).("Mssn Speed")];
    MDS = [MDS; tmp]; 
    clear tmp 
    tmp = [RawData.(fn{iter}).("Drive Tactic") RawData.(fn{iter}).("Collect Tactic")];
    MDScd = [MDScd; tmp];
end

CollectSET = unique(MDScd(:,2));
DriveSET = unique(MDScd(:,1)); 

figure(1)
pltt = 1; 
for COLLECT = 1:length(CollectSET)
    for DRIVE = 1:length(DriveSET)
        idx = find(MDScd(:,1) == DriveSET(DRIVE) & MDScd(:,2) == CollectSET(COLLECT));
                
        mdl = stepwiselm(MDS(idx,2:end), MDS(idx,1), 'PEnter', 0.05);
        x1new = linspace(0,sqrt(max(MDS(:,2))),1000)';
        x2new = linspace(0,sqrt(max(MDS(:,3))),1000)';
        x3new = linspace(0,sqrt(max(MDS(:,4))),1000)';
        pred = predict(mdl, [x1new x2new x3new]);
        
        score_log = mdl.Fitted; % Pr estimates
        try 
            [Xlog,Ylog,Tlog,AUClog] = perfcurve(MDS(idx,1), score_log, 1);
        catch
            AUClog = -1;  
        end 

        subplot(5,5,pltt)
        scatter(MDS(idx,2:end), MDS(idx,1))
        hold on 
        plot(xnew,pred)
        str = sprintf('Drive = %s Collect = %s and Adj. AUC = %f',DriveSET(DRIVE),CollectSET(COLLECT), AUClog);
        title(str)

        pltt = pltt + 1; 
    end
end


%% RANK-SUM TEST 
RankSumTestMatrix = nan(25,6,14);
RankSumTestMatrix(:,:,1) = s0.RankVector; 
RankSumTestMatrix(:,:,2) = s_He.RankVector; 
RankSumTestMatrix(:,:,3) = s1.RankVector; 
RankSumTestMatrix(:,:,4) = s2.RankVector; 
RankSumTestMatrix(:,:,5) = s3.RankVector; 
RankSumTestMatrix(:,:,6) = s4.RankVector; 
RankSumTestMatrix(:,:,7) = s_Ho.RankVector; 
RankSumTestMatrix(:,:,8) = s5.RankVector; 
RankSumTestMatrix(:,:,9) = s6.RankVector; 
RankSumTestMatrix(:,:,10) = s7.RankVector; 
RankSumTestMatrix(:,:,11) = s8.RankVector; 
RankSumTestMatrix(:,:,12) = s9.RankVector; 
RankSumTestMatrix(:,:,13) = s10.RankVector; 
RankSumTestMatrix(:,:,14) = s11.RankVector; 


% 1- compare each TP for each metric across given scenarios 
% ScenarioMatrix = RankSumTestMatrix(:,:,[3 4 5 6]); % Heterogeneous
% ScenarioMatrix = RankSumTestMatrix(:,:,[8 9 10 11 12 13 14]); % Homogeneous 
ScenarioMatrix = RankSumTestMatrix(:,:,[3 4 5 6 8 9 10 11 12 13 14]); % All scenarios 
for k = 1:size(ScenarioMatrix,2) % metric 
    for i = 1:size(ScenarioMatrix,1) % from TP 
        for j = 1:size(ScenarioMatrix,1) % to TP 
            if i ~= j 
                [p(i,j,k), h(i,j,k)] = ranksum(squeeze(ScenarioMatrix(i,k,:)), squeeze(ScenarioMatrix(j,k,:)));
            end
        end
    end
end

% the problem with rank-sum tests is that they do not indicate if a TP is 
% good or bad over these scenarios, only if it is different to other TPs. 
% This can confirm across multiple metrics our understanding; however

%% RANK-SUM PART 2 - Hussein Code 

% requires df --> sX at the top of the page and then execute this 

RankSumMatrix(:,:,:,1) = s0.RankSums.rnk;
RankSumMatrix(:,:,:,2) = s_He.RankSums.rnk;
RankSumMatrix(:,:,:,3) = s1.RankSums.rnk;
RankSumMatrix(:,:,:,4) = s2.RankSums.rnk;
RankSumMatrix(:,:,:,5) = s3.RankSums.rnk;
RankSumMatrix(:,:,:,6) = s4.RankSums.rnk;
RankSumMatrix(:,:,:,7) = s_Ho.RankSums.rnk;
RankSumMatrix(:,:,:,8) = s5.RankSums.rnk;
RankSumMatrix(:,:,:,9) = s6.RankSums.rnk;
RankSumMatrix(:,:,:,10) = s7.RankSums.rnk;
RankSumMatrix(:,:,:,11) = s8.RankSums.rnk;
RankSumMatrix(:,:,:,12) = s9.RankSums.rnk;
RankSumMatrix(:,:,:,13) = s10.RankSums.rnk;
RankSumMatrix(:,:,:,14) = s11.RankSums.rnk;


%% SCENARIO 1 - COMPARE ALL TPs ACROSS ALL SCENARIOS AND ALL METRICS 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,:,[3 4 5 6 8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.ALL.p = p; 
RankSumData.ALL.h = h; 

%% SCENARIO 2 - COMPARE ALL TPs ACROSS HOMOGENEOUS SCENARIOS AND ALL METRICS 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,:,[8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.Ho.p = p; 
RankSumData.Ho.h = h; 

%% SCENARIO 3 - COMPARE ALL TPs ACROSS HETEROGENEOUS SCENARIOS AND ALL METRICS 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,:,[3 4 5 6])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.He.p = p; 
RankSumData.He.h = h; 

%% SCENARIO 4 - COMPARE ALL TPs ACROSS ALL SCENARIOS AND M1 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,1,[3 4 5 6 8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.M1.p = p; 
RankSumData.M1.h = h; 

%% SCENARIO 5 - COMPARE ALL TPs ACROSS ALL SCENARIOS AND M2 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,2,[3 4 5 6 8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.M2.p = p; 
RankSumData.M2.h = h; 

%% SCENARIO 6 - COMPARE ALL TPs ACROSS ALL SCENARIOS AND M3 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,3,[3 4 5 6 8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.M3.p = p; 
RankSumData.M3.h = h; 

%% SCENARIO 7 - COMPARE ALL TPs ACROSS ALL SCENARIOS AND M4
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,4,[3 4 5 6 8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.M4.p = p; 
RankSumData.M4.h = h; 

%% SCENARIO 8 - COMPARE ALL TPs ACROSS ALL SCENARIOS AND M5 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,5,[3 4 5 6 8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.M5.p = p; 
RankSumData.M5.h = h; 

%% SCENARIO 9 - COMPARE ALL TPs ACROSS ALL SCENARIOS AND M6 
clear sumary h p COLLECT DRIVE METRIC SCENARIO TransMat SOURCE TARGET

% Transform 5x5 TP matrix to 25x25 matrix 
TransMat = []; 

for COLLECT = 1:5 
    for DRIVE = 1:5
            TransMat = [TransMat, reshape(squeeze(RankSumMatrix(COLLECT,DRIVE,6,[3 4 5 6 8 9 10 11 12 13 14])), [], 1)];
    end
end

TransMat

for SOURCE = 1:size(TransMat,2)
    for TARGET = 1:size(TransMat,2)
        if SOURCE ~= TARGET
            [p(SOURCE,TARGET), h(SOURCE,TARGET)] = ranksum(TransMat(:,SOURCE), TransMat(:,TARGET));
        end
    end
end
p
h

RankSumData.M6.p = p; 
RankSumData.M6.h = h; 

%% PLOT TIME 

figure(1)
subplot(3,3,1)
spy(triu(RankSumData.ALL.h))
title('All metrics and all scenarios')
subplot(3,3,2)
spy(triu(RankSumData.He.h))
title('All metrics and Heterogeneous Scenarios')
subplot(3,3,3)
spy(triu(RankSumData.Ho.h))
title('All metrics and Homogeneous Scenarios')
subplot(3,3,4)
spy(triu(RankSumData.M1.h))
title('M1 All Scenarios')
subplot(3,3,5)
spy(triu(RankSumData.M2.h))
title('M2 All Scenarios')
subplot(3,3,6)
spy(triu(RankSumData.M3.h))
title('M3 All Scenarios')
subplot(3,3,7)
spy(triu(RankSumData.M4.h))
title('M4 All Scenarios')
subplot(3,3,8)
spy(triu(RankSumData.M5.h))
title('M5 All Scenarios')
subplot(3,3,9)
spy(triu(RankSumData.M6.h))
title('M6 All Scenarios')


% NOW >>> COMPARE THE SIMILARITY BETWEEN EACH TRIU() MATRIX AND REPORT FOR EACH METRIC/SCENARIO TYPE 




%% Colour Plots for ttest results

load('/Users/ajh/GitHub/IntelligentControlAgent/SimData/dat.mat')

scenariosFn = fieldnames(dat);
metricsFn = fieldnames(dat.s0.Metrics);

for METRIC = 1:numel(metricsFn)
    for SCENARIO = 2:12
        ResMat(:,SCENARIO-1,METRIC) = reshape(dat.(scenariosFn{SCENARIO}).Metrics.(metricsFn{METRIC}).HypothTest.ttest2, [], 1);
    end
end

size(ResMat)

A = double(~ResMat); % invert numbers 

%% PLOT MASTER BHOT 
%set(groot,'defaulttextinterpreter','latex');  
%set(groot, 'defaultAxesTickLabelInterpreter','latex');  
%set(groot, 'defaultLegendInterpreter','latex'); 

map = [254/255 254/255 254/255
       1/255 1/255 1/255];

figure(1)  % subplot(3,2,1)
h = heatmap(A(:,:,1), 'CellLabelColor','none', 'Colormap', map);
h.XLabel = {'Scenario'};
h.YLabel = {'Tactic Pair'};
h.Title = {'Metric M1'};
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.FontSize = 14;
% x = gca; 
% ax.XData = ["s_1" "s_2" "s_3" "s_4" "s_5" "s_6" "s_7" "s_8" "s_9" "s_{10}" "s_{11}"];
% ax.YData = ["TP_1" "TP_2" "TP_3" "TP_4" "TP_5" "TP_6" "TP_7" "TP_8" "TP_9" "TP_{10}" "TP_{11}" "TP_{12}" "TP_{13}" "TP_{14}" "TP_{15}" "TP_{16}" "TP_{17}" "TP_{18}" "TP_{19}" "TP_{20}" "TP_{21}" "TP_{22}" "TP_{23}" "TP_{24}" "TP_{25}"];
% 
% h.NodeChildren(3).XAxis.Label.Interpreter = 'latex';
% h.NodeChildren(3).YAxis.Label.Interpreter = 'latex';
% h.NodeChildren(3).Title.Interpreter = 'latex';

figure(2) %subplot(3,2,2)
h = heatmap(A(:,:,2), 'CellLabelColor','none', 'Colormap', map);
h.XLabel = {'Scenario'};
h.YLabel = {'Tactic Pair'};
h.Title = {'Metric M2'};
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.FontSize = 14;

figure(3) % subplot(3,2,3)
h = heatmap(A(:,:,3), 'CellLabelColor','none', 'Colormap', map);
h.XLabel = {'Scenario'};
h.YLabel = {'Tactic Pair'};
h.Title = {'Metric M3'};
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.FontSize = 14;

figure(4) % subplot(3,2,4)
h = heatmap(A(:,:,4), 'CellLabelColor','none', 'Colormap', map);
h.XLabel = {'Scenario'};
h.YLabel = {'Tactic Pair'};
h.Title = {'Metric M4'};
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.FontSize = 14;

figure(5) % subplot(3,2,5)
h = heatmap(A(:,:,5), 'CellLabelColor','none', 'Colormap', map);
h.XLabel = {'Scenario'};
h.YLabel = {'Tactic Pair'};
h.Title = {'Metric M5'};
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.FontSize = 14;

figure(6) % subplot(3,2,6)
h = heatmap(A(:,:,6), 'CellLabelColor','none', 'Colormap', map);
h.XLabel = {'Scenario'};
h.YLabel = {'Tactic Pair'};
h.Title = {'Metric M6'};
h.GridVisible = 'off';
h.ColorbarVisible = 'off';
h.FontSize = 14;