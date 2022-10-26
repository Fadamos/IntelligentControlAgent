function output = IntelligentDECISION(library, Intent, Scenario, SignifThreshold, Verbose)
    % Author: Adam J Hepworth
    % LastModified: 2022-09-23
    % Explanaton: Intelligent control agent data library 

    % collect = C2D  C2H  F2D  F2G  F2H
    % drive   = DAH  DHH  DOAT DQH  DTQH

    if ~exist('Scenario', 'var')
        Scenario = "S0"; % if scenario is not given, default to best tactic-pair across all scenarios
    end
    if ~exist('SignifThreshold', 'var')
        SignifThreshold = 0.05; % statistical significance threshold for testing
    end
    if ~exist('Verbose', 'var')
        Verbose = 0; % 1 = thesis; 2 = journal
    end
    
    if Scenario == "S0"
        subsetDF = library(:,[Intent 13:15]); 
    elseif Scenario == "S_He"
        subsetIndex = find(library.Scenario == "S1" | library.Scenario == "S2" | library.Scenario == "S3" | library.Scenario == "S4");
        subsetDF = library(subsetIndex,[Intent 13:15]);
    elseif Scenario == "S_Ho"
        subsetIndex = find(library.Scenario == "S5" | library.Scenario == "S6" | library.Scenario == "S6" | library.Scenario == "S7" | library.Scenario == "S8" | library.Scenario == "S9" | library.Scenario == "S10" | library.Scenario == "S11");
        subsetDF = library(subsetIndex,[Intent 13:15]);
    else
        subsetIndex = find(library.Scenario == Scenario);
        subsetDF = library(subsetIndex,[Intent 13:15]);
    end

    CollectSET = unique(library.("Collect Tactic"));
    DriveSET = unique(library.("Drive Tactic"));
    
    for COLLECT = 1:length(unique(subsetDF.("Collect Tactic")))
        for DRIVE = 1:length(unique(subsetDF.("Drive Tactic")))
            TacticINDEX = find(subsetDF.("Collect Tactic") == CollectSET(COLLECT) & subsetDF.("Drive Tactic") == DriveSET(DRIVE));
            TacticDF = subsetDF(TacticINDEX,:);
            TacticMatrixMEAN(COLLECT, DRIVE) = mean(TacticDF{:,1}); 
            TacticMatrixSTD(COLLECT, DRIVE) = std(TacticDF{:,1}); 
            TacticMatrixIQR(COLLECT, DRIVE) = iqr(TacticDF{:,1});
            TacticMatrixRNG(COLLECT, DRIVE) = range(TacticDF{:,1});
            TacticMatrixSE(COLLECT, DRIVE) = std(TacticDF{:,1})/sqrt(length(TacticINDEX));
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            RawData.(strName) = TacticDF; 
        end
    end

    %% Calculate sorted data indices
    switch Intent 
        case {1 4 5 7 9 11} % intent = maximise; sort = 'descend'
            SortedValues = reshape(sort(TacticMatrixMEAN(:), 'descend'), [size(TacticMatrixMEAN,1)*size(TacticMatrixMEAN,2), 1]); % sort values 
            SortedUnique = sort(unique(SortedValues), 'descend'); % linear indices
        case {2 3 6 8} % intent = minimise; sort = 'ascend'
            SortedValues = reshape(sort(TacticMatrixMEAN(:), 'ascend'), [size(TacticMatrixMEAN,1)*size(TacticMatrixMEAN,2), 1]);
            SortedUnique = sort(unique(SortedValues), 'ascend'); 
    end 

    SortedIndices = []; 
    for UniqueElm = 1:length(SortedUnique)
        SortedIndices = [SortedIndices; find(TacticMatrixMEAN == SortedUnique(UniqueElm))];
    end
    % return index with value in sorted order
    [r, c] = ind2sub([size(TacticMatrixMEAN,1) size(TacticMatrixMEAN,2)],SortedIndices);
    
    TacticSet.SortedValues = SortedValues; % values in sorted order for the intent
    TacticSet.SortedUnique = SortedUnique; % unique values in sorted order for the intent
    TacticSet.SortedLinIdx = SortedIndices; % sorted tacitc-pair linear indices 
    TacticSet.SortedPairIdx = [r c]; % COLLECT and DRIVE indices for tactic-pairs
    
    output.TacticSet    = TacticSet;
    output.Summary.mean = TacticMatrixMEAN; 
    output.Summary.std  = TacticMatrixSTD; 
    output.Summary.iqr  = TacticMatrixIQR; 
    output.Summary.rng  = TacticMatrixRNG; 
    output.Summary.se   = TacticMatrixSE; 
    output.RawData      = RawData;

    %% Calculate the statistical significant data 
    baselineIdx = TacticSet.SortedPairIdx(1,:); 
    baselineRef = ['c',num2str(baselineIdx(1)),'d',num2str(baselineIdx(2))];
    baselineData = RawData.(baselineRef); % full table of data
    
    fieldname = fieldnames(RawData); 
    for iter = 1:numel(fieldname) % https://au.mathworks.com/help/stats/available-hypothesis-tests.html
        testData = RawData.(fieldname{iter}); % https://au.mathworks.com/help/stats/hypothesis-tests-1.html?s_tid=CRUX_lftnav
         [hT, pT, ciT] = ttest2(table2array(baselineData(:,1)), table2array(testData(:,1)), 'Alpha', SignifThreshold);
         StatsTtest(iter) = hT; 
         StatsTp(iter) = pT; 
         StatsTci(iter,:) = ciT; 
         [hKS, pKS] = kstest2(table2array(baselineData(:,1)), table2array(testData(:,1)), 'Alpha', SignifThreshold); % https://stats.stackexchange.com/questions/208517/kolmogorov-smirnov-test-vs-t-test
         StatsKStest(iter) = hKS; 
         StatsKSp(iter) = pKS; 
    end

    StatsTtest = reshape(StatsTtest, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
    StatsTp = reshape(StatsTp, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
    StatsKStest = reshape(StatsKStest, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
    StatsKSp = reshape(StatsKSp, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
    
    StatsTtest(isnan(StatsTtest)) = 0; % handle NaN values for perfect completions, i.e. value = 1.0

    outStats.ttest2 = StatsTtest'; 
    outStats.tPval = StatsTp'; 
    outStats.tCI = StatsTci'; 
    outStats.kstest2 = StatsKStest'; 
    outStats.ksPval = StatsKSp';

    %% save index of indifferentiable tactic pairs

    [rT,cT] = ind2sub([size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)], find(outStats.ttest2 == 0));
    [rKS,cKS] = ind2sub([size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)], find(outStats.kstest2 == 0));

    outStats.TacticPair.ttest2 = [rT cT];
    outStats.TacticPair.kstest2 = [rKS,cKS];

    %% save all and end 
    
    output.HypothTest = outStats; 

    %% Summary Metrics

    if Scenario == "S0"
        subsetDF = library(:,[1 2 4 5 11 13:15]); 
    elseif Scenario == "S_He"
        subsetIndex = find(library.Scenario == "S1" | library.Scenario == "S2" | library.Scenario == "S3" | library.Scenario == "S4");
        subsetDF = library(subsetIndex,[1 2 4 5 11 13:15]);
    elseif Scenario == "S_Ho"
        subsetIndex = find(library.Scenario == "S5" | library.Scenario == "S6" | library.Scenario == "S6" | library.Scenario == "S7" | library.Scenario == "S8" | library.Scenario == "S9" | library.Scenario == "S10" | library.Scenario == "S11");
        subsetDF = library(subsetIndex,[1 2 4 5 11 13:15]);
    else
        subsetIndex = find(library.Scenario == Scenario);
        subsetDF = library(subsetIndex,[1 2 4 5 11 13:15]);
    end

    CollectSET = unique(library.("Collect Tactic"));
    DriveSET = unique(library.("Drive Tactic"));
    
    for COLLECT = 1:length(unique(subsetDF.("Collect Tactic")))
        for DRIVE = 1:length(unique(subsetDF.("Drive Tactic")))
            TacticINDEX = find(subsetDF.("Collect Tactic") == CollectSET(COLLECT) & subsetDF.("Drive Tactic") == DriveSET(DRIVE));
            DF = subsetDF(TacticINDEX,:);
            DF.("Decision Chg") = DF.("Decision Chg")+1; 
            % Mission Success
            MissionSuccess(COLLECT, DRIVE) = mean(DF.("Mssn Success")); % maximise 
            MissionSuccessSTD(COLLECT, DRIVE) = std(DF.("Mssn Success")); 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            output.Metrics.MissionSuccess.RawData.(strName) = DF; 
            % Mission Decision Stability
            MissionDecisionStability(COLLECT, DRIVE) = nanmean(DF.("Mssn Success")./DF.("Decision Chg")); % maximise 
            MissionDecisionStabilitySTD(COLLECT, DRIVE) = nanstd(DF.("Mssn Success")./DF.("Decision Chg")); 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            output.Metrics.MissionDecisionStability.RawData.(strName) = DF; 
            % Swarm Decision Stability
            SwarmDecisionStability(COLLECT, DRIVE) = nanmean(DF.("Avg Num Sep pi")./DF.("Decision Chg")); % minimise 
            SwarmDecisionStabilitySTD(COLLECT, DRIVE) = nanstd(DF.("Avg Num Sep pi")./DF.("Decision Chg")); 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            output.Metrics.SwarmDecisionStability.RawData.(strName) = DF; 
            % Mission Swarm Stability
            MissionSwarmStability(COLLECT, DRIVE) = nanmean(DF.("Mssn Success")./DF.("Avg Num Sep pi")); % maximise 
            MissionSwarmStabilitySTD(COLLECT, DRIVE) = nanstd(DF.("Mssn Success")./DF.("Avg Num Sep pi")); 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            output.Metrics.MissionSwarmStability.RawData.(strName) = DF; 
            % Mission Completion Rate
            MissionCompletionRate(COLLECT, DRIVE) = nanmean(DF.("Mssn Comp Rate")); % minimise 
            MissionCompletionRateSTD(COLLECT, DRIVE) = nanstd(DF.("Mssn Comp Rate")); 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            output.Metrics.MissionCompletionRate.RawData.(strName) = DF; 
            % Mission Speed Ratio
            MissionSpeedRatio(COLLECT, DRIVE) = nanmean(DF.("Mssn Speed")); % maximise 
            MissionSpeedRatioSTD(COLLECT, DRIVE) = nanstd(DF.("Mssn Speed")); 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            output.Metrics.MissionSpeedRatio.RawData.(strName) = DF; 
        end
    end

    output.Metrics.MissionSuccess.mean           = MissionSuccess; 
    output.Metrics.MissionDecisionStability.mean = MissionDecisionStability; 
    output.Metrics.SwarmDecisionStability.mean   = SwarmDecisionStability; 
    output.Metrics.MissionSwarmStability.mean    = MissionSwarmStability;
    output.Metrics.MissionCompletionRate.mean    = MissionCompletionRate;
    output.Metrics.MissionSpeedRatio.mean        = MissionSpeedRatio; 

    output.Metrics.MissionSuccess.std            = MissionSuccessSTD; 
    output.Metrics.MissionDecisionStability.std  = MissionDecisionStabilitySTD; 
    output.Metrics.SwarmDecisionStability.std    = SwarmDecisionStabilitySTD; 
    output.Metrics.MissionSwarmStability.std     = MissionSwarmStabilitySTD;
    output.Metrics.MissionCompletionRate.std     = MissionCompletionRateSTD;
    output.Metrics.MissionSpeedRatio.std         = MissionSpeedRatioSTD; 
    
    %% Calculate sorted data indices
    % can't use switch case here, so we need another way to calculate the metrics for each -- maybe reset the intent and use the switch cases? 
   
    % intent = maximise; sort = 'descend'
    MSsorted = reshape(sort(MissionSuccess(:), 'descend'), [size(MissionSuccess,1)*size(MissionSuccess,2), 1]); % sort values 
    MSunique = sort(unique(MSsorted), 'descend'); % linear indices
    output.Metrics.MissionSuccess.sorted = MSsorted;
    output.Metrics.MissionSuccess.unique = MSunique;

    MDSsorted = reshape(sort(MissionDecisionStability(:), 'descend'), [size(MissionDecisionStability,1)*size(MissionDecisionStability,2), 1]); % sort values 
    MDSunique = sort(unique(MDSsorted), 'descend'); % linear indices
    output.Metrics.MissionDecisionStability.sorted = MDSsorted;
    output.Metrics.MissionDecisionStability.unique = MDSunique;

    MSSsorted = reshape(sort(MissionSwarmStability(:), 'descend'), [size(MissionSwarmStability,1)*size(MissionSwarmStability,2), 1]); % sort values 
    MSSunique = sort(unique(MSSsorted), 'descend'); % linear indices
    output.Metrics.MissionSwarmStability.sorted = MSSsorted;
    output.Metrics.MissionSwarmStability.unique = MSSunique;

    MSRsorted = reshape(sort(MissionSpeedRatio(:), 'descend'), [size(MissionSpeedRatio,1)*size(MissionSpeedRatio,2), 1]); % sort values 
    MSRunqiue = sort(unique(MSRsorted), 'descend'); % linear indices
    output.Metrics.MissionSpeedRatio.sorted = MSRsorted;
    output.Metrics.MissionSpeedRatio.unique = MSRunqiue;
   
    % intent = minimise; sort = 'ascend'
    SDSsorted = reshape(sort(SwarmDecisionStability(:), 'ascend'), [size(SwarmDecisionStability,1)*size(SwarmDecisionStability,2), 1]);
    SDSunique = sort(unique(SDSsorted), 'ascend'); 
    output.Metrics.SwarmDecisionStability.sorted = SDSsorted;
    output.Metrics.SwarmDecisionStability.unique = SDSunique;

    MCRsorted = reshape(sort(MissionCompletionRate(:), 'ascend'), [size(MissionCompletionRate,1)*size(MissionCompletionRate,2), 1]);
    MCRunique = sort(unique(MCRsorted), 'ascend'); 
    output.Metrics.MissionCompletionRate.sorted = MCRsorted;
    output.Metrics.MissionCompletionRate.unique = MCRunique;

    %% Calculate the statistical significant data
    MetricsFieldname = fieldnames(output.Metrics); 
    for metric = 1:numel(MetricsFieldname)
        SortedIndices = []; 
        SortedMean = output.Metrics.(MetricsFieldname{metric}).mean; 
        SortedUnique = output.Metrics.(MetricsFieldname{metric}).unique; 
        
        for UniqueElm = 1:length(SortedUnique)
            SortedIndices = [SortedIndices; find(SortedMean == SortedUnique(UniqueElm))];
        end 
        
        [r, c] = ind2sub([size(SortedMean,1) size(SortedMean,2)],SortedIndices);
        output.Metrics.(MetricsFieldname{metric}).SortedIndices = SortedIndices; % sorted tacitc-pair linear indices 
        output.Metrics.(MetricsFieldname{metric}).SortedPairIdx = [r c]; % COLLECT and DRIVE indices for tactic-pairs
        SortedPairIdx = output.Metrics.(MetricsFieldname{metric}).SortedPairIdx; 

        baselineIdx  = SortedPairIdx(1,:); 
        baselineRef  = ['c',num2str(baselineIdx(1)),'d',num2str(baselineIdx(2))];
        baselineData = output.Metrics.(MetricsFieldname{metric}).RawData.(baselineRef); 

        RawDataFieldname = fieldnames(output.Metrics.(MetricsFieldname{metric}).RawData); 
        
        %% Statistical Testing Code Here
        for iter = 1:numel(RawDataFieldname)
            testData = output.Metrics.(MetricsFieldname{metric}).RawData.(RawDataFieldname{iter});
            [hT, pT, ciT] = ttest2(table2array(baselineData(:,1)), table2array(testData(:,1)), 'Alpha', SignifThreshold);
            StatsTtest(iter) = hT; 
            StatsTp(iter) = pT; 
            StatsTci(iter,:) = ciT; 
            [hKS, pKS] = kstest2(table2array(baselineData(:,1)), table2array(testData(:,1)), 'Alpha', SignifThreshold); % https://stats.stackexchange.com/questions/208517/kolmogorov-smirnov-test-vs-t-test
            StatsKStest(iter) = hKS; 
            StatsKSp(iter) = pKS; 
        end
        
        StatsTtest = reshape(StatsTtest, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
        StatsTp = reshape(StatsTp, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
        StatsKStest = reshape(StatsKStest, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
        StatsKSp = reshape(StatsKSp, [size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)]);
    
        StatsTtest(isnan(StatsTtest)) = 0; % handle NaN values for perfect completions, i.e. value = 1.0

        output.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2 = StatsTtest'; 
        output.Metrics.(MetricsFieldname{metric}).HypothTest.tPval = StatsTp'; 
        output.Metrics.(MetricsFieldname{metric}).HypothTest.kstest2 = StatsKStest'; 
        output.Metrics.(MetricsFieldname{metric}).HypothTest.tConfInt = StatsTci';
        output.Metrics.(MetricsFieldname{metric}).HypothTest.ksPval = StatsKSp'; 

        % save indexes of tactic pairs that fail to reject the null hypothesis

        [rT,cT] = ind2sub([size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)], find(output.Metrics.(MetricsFieldname{metric}).HypothTest.ttest2 == 0));
        [rKS,cKS] = ind2sub([size(TacticMatrixMEAN,1), size(TacticMatrixMEAN,2)], find(output.Metrics.(MetricsFieldname{metric}).HypothTest.kstest2 == 0));

        output.Metrics.(MetricsFieldname{metric}).ttest2  = [rT cT];
        output.Metrics.(MetricsFieldname{metric}).kstest2 = [rKS,cKS]; 

    end
    
    %% outputs for data
    if Verbose == 1 % for thesis output plotting 
        fprintf('Scenario = %s\n', Scenario)
        fprintf('Mission Success\n')
        output.Metrics.MissionSuccess.mean    
        output.Metrics.MissionSuccess.std
        output.Metrics.MissionSuccess.ttest2
        fprintf('Mission Decision Stability\n')
        output.Metrics.MissionDecisionStability.mean 
        output.Metrics.MissionDecisionStability.std
        output.Metrics.MissionDecisionStability.ttest2
        fprintf('Swarm Decision Stability\n')
        output.Metrics.SwarmDecisionStability.mean 
        output.Metrics.SwarmDecisionStability.std
        output.Metrics.SwarmDecisionStability.ttest2
        fprintf('Mission Swarm Stability\n')
        output.Metrics.MissionSwarmStability.mean    
        output.Metrics.MissionSwarmStability.std
        output.Metrics.MissionSwarmStability.ttest2
        fprintf('Mission Completion Rate\n')
        output.Metrics.MissionCompletionRate.mean    
        output.Metrics.MissionCompletionRate.std
        output.Metrics.MissionCompletionRate.ttest2
        fprintf('Mission Speed Ratio\n')
        output.Metrics.MissionSpeedRatio.mean   
        output.Metrics.MissionSpeedRatio.std
        output.Metrics.MissionSpeedRatio.ttest2
    
    elseif Verbose == 2 % summary plotting for journal paper 
        fprintf('Scenario = %s\n', Scenario)

        fprintf('\nMission Success\n')
        fprintf('Best = %.2f %s %.2f\n', output.Metrics.MissionSuccess.mean(output.Metrics.MissionSuccess.SortedIndices(1)), '$\pm$', output.Metrics.MissionSuccess.std(output.Metrics.MissionSuccess.SortedIndices(1)))
        fprintf('Stat Signif = %d [should be 0]\n', output.Metrics.MissionSuccess.HypothTest.ttest2(output.Metrics.MissionSuccess.SortedPairIdx(1,1), output.Metrics.MissionSuccess.SortedPairIdx(1,2)))
        fprintf('Best TP = %d %d\n', output.Metrics.MissionSuccess.SortedPairIdx(1,2), output.Metrics.MissionSuccess.SortedPairIdx(1,1))
        %fprintf('Worst = %.2f %s %.2f :: Stat Signif = %d \n', output.Metrics.MissionSuccess.mean(output.Metrics.MissionSuccess.SortedIndices(end)), '$\pm$', output.Metrics.MissionSuccess.std(output.Metrics.MissionSuccess.SortedIndices(end)))
        %fprintf('Stat Signif = %d [could be 0 or 1]\n', output.Metrics.MissionSuccess.HypothTest.ttest2(output.Metrics.MissionSuccess.SortedPairIdx(end,1), output.Metrics.MissionSuccess.SortedPairIdx(end,2)))
        %fprintf('Worst TP = %d %d\n', output.Metrics.MissionSuccess.SortedPairIdx(end,2), output.Metrics.MissionSuccess.SortedPairIdx(end,1))
        fprintf('Str = %.2f %s %.2f\n', output.Metrics.MissionSuccess.mean(5), '$\pm$', output.Metrics.MissionSuccess.std(5))
        fprintf('Stat Signif = %d [could be 0 or 1; must be 0 if Worst is 0]\n', output.Metrics.MissionSuccess.HypothTest.ttest2(5,1))
        fprintf('Str TP = 1 5\n')

        fprintf('\nMission Decision Stability\n')
        fprintf('Best = %.2f %s %.2f\n', output.Metrics.MissionDecisionStability.mean(output.Metrics.MissionDecisionStability.SortedIndices(1)), '$\pm$', output.Metrics.MissionDecisionStability.std(output.Metrics.MissionDecisionStability.SortedIndices(1)))
        fprintf('Stat Signif = %d [should be 0]\n',  output.Metrics.MissionDecisionStability.HypothTest.ttest2(output.Metrics.MissionDecisionStability.SortedPairIdx(1,1), output.Metrics.MissionDecisionStability.SortedPairIdx(1,2)))
        fprintf('Best TP = %d %d\n', output.Metrics.MissionDecisionStability.SortedPairIdx(1,2), output.Metrics.MissionDecisionStability.SortedPairIdx(1,1))
        %fprintf('Worst = %.2f %s %.2f :: Stat Signif = %d \n', output.Metrics.MissionDecisionStability.mean(output.Metrics.MissionDecisionStability.SortedIndices(end)), '$\pm$', output.Metrics.MissionDecisionStability.std(output.Metrics.MissionDecisionStability.SortedIndices(end)))
        %fprintf('Stat Signif = %d [could be 0 or 1]\n', output.Metrics.MissionDecisionStability.HypothTest.ttest2(output.Metrics.MissionDecisionStability.SortedPairIdx(end,1), output.Metrics.MissionDecisionStability.SortedPairIdx(end,2)))
        %fprintf('Worst TP = %d %d\n', output.Metrics.MissionDecisionStability.SortedPairIdx(end,2), output.Metrics.MissionDecisionStability.SortedPairIdx(end,1))
        fprintf('Str = %.2f %s %.2f\n', output.Metrics.MissionDecisionStability.mean(5), '$\pm$', output.Metrics.MissionDecisionStability.std(5,1))
        fprintf('Stat Signif = %d [could be 0 or 1; must be 0 if Worst is 0]\n', output.Metrics.MissionDecisionStability.HypothTest.ttest2(5,1))
        fprintf('Str TP = 1 5\n')      
        
        fprintf('\nSwarm Decision Stability\n')
        fprintf('Best = %.2f %s %.2f\n', output.Metrics.SwarmDecisionStability.mean(output.Metrics.SwarmDecisionStability.SortedIndices(1)), '$\pm$', output.Metrics.SwarmDecisionStability.std(output.Metrics.SwarmDecisionStability.SortedIndices(1)))
        fprintf('Stat Signif = %d [should be 0]\n', output.Metrics.SwarmDecisionStability.HypothTest.ttest2(output.Metrics.SwarmDecisionStability.SortedPairIdx(1,1), output.Metrics.SwarmDecisionStability.SortedPairIdx(1,2)))
        fprintf('Best TP = %d %d\n', output.Metrics.SwarmDecisionStability.SortedPairIdx(1,2), output.Metrics.SwarmDecisionStability.SortedPairIdx(1,1))
        %fprintf('Worst = %.2f %s %.2f :: Stat Signif = %d \n', output.Metrics.SwarmDecisionStability.mean(output.Metrics.SwarmDecisionStability.SortedIndices(end)), '$\pm$', output.Metrics.SwarmDecisionStability.std(output.Metrics.SwarmDecisionStability.SortedIndices(end)))
        %fprintf('Stat Signif = %d [could be 0 or 1]\n', output.Metrics.SwarmDecisionStability.HypothTest.ttest2(output.Metrics.SwarmDecisionStability.SortedPairIdx(end,1), output.Metrics.SwarmDecisionStability.SortedPairIdx(end,2)))
        %fprintf('Worst TP = %d %d\n', output.Metrics.SwarmDecisionStability.SortedPairIdx(end,2), output.Metrics.SwarmDecisionStability.SortedPairIdx(end,1))
        fprintf('Str = %.2f %s %.2f\n', output.Metrics.SwarmDecisionStability.mean(5), '$\pm$', output.Metrics.SwarmDecisionStability.std(5,1))
        fprintf('Stat Signif = %d [could be 0 or 1; must be 0 if Worst is 0]\n', output.Metrics.SwarmDecisionStability.HypothTest.ttest2(5,1))
        fprintf('Str TP = 1 5\n')

        fprintf('\nMission Swarm Stability\n')
        fprintf('Best = %.2f %s %.2f\n', output.Metrics.MissionSwarmStability.mean(output.Metrics.MissionSwarmStability.SortedIndices(1)), '$\pm$', output.Metrics.MissionSwarmStability.std(output.Metrics.MissionSwarmStability.SortedIndices(1)))
        fprintf('Stat Signif = %d [should be 0]\n', output.Metrics.MissionSwarmStability.HypothTest.ttest2(output.Metrics.MissionSwarmStability.SortedPairIdx(1,1), output.Metrics.MissionSwarmStability.SortedPairIdx(1,2)))
        fprintf('Best TP = %d %d\n', output.Metrics.MissionSwarmStability.SortedPairIdx(1,2), output.Metrics.MissionSwarmStability.SortedPairIdx(1,1))
        %fprintf('Worst = %.2f %s %.2f :: Stat Signif = %d \n', output.Metrics.MissionSwarmStability.mean(output.Metrics.MissionSwarmStability.SortedIndices(end)), '$\pm$', output.Metrics.MissionSwarmStability.std(output.Metrics.MissionSwarmStability.SortedIndices(end)))
        %fprintf('Stat Signif = %d [could be 0 or 1]\n', output.Metrics.MissionSwarmStability.HypothTest.ttest2(output.Metrics.MissionSwarmStability.SortedPairIdx(end,1), output.Metrics.MissionSwarmStability.SortedPairIdx(end,2)))
        %fprintf('Worst TP = %d %d\n', output.Metrics.MissionSwarmStability.SortedPairIdx(end,2), output.Metrics.MissionSwarmStability.SortedPairIdx(end,1))
        fprintf('Str = %.2f %s %.2f\n', output.Metrics.MissionSwarmStability.mean(5), '$\pm$', output.Metrics.MissionSwarmStability.std(5,1))
        fprintf('Stat Signif = %d [could be 0 or 1; must be 0 if Worst is 0]\n', output.Metrics.MissionSwarmStability.HypothTest.ttest2(5,1))
        fprintf('Str TP = 1 5\n')

        fprintf('\nMission Completion Rate\n')
        fprintf('Best = %.2f %s %.2f\n', output.Metrics.MissionCompletionRate.mean(output.Metrics.MissionCompletionRate.SortedIndices(1)), '$\pm$', output.Metrics.MissionCompletionRate.std(output.Metrics.MissionCompletionRate.SortedIndices(1)))
        fprintf('Stat Signif = %d [should be 0]\n', output.Metrics.MissionCompletionRate.HypothTest.ttest2(output.Metrics.MissionCompletionRate.SortedPairIdx(1,1), output.Metrics.MissionCompletionRate.SortedPairIdx(1,2)))
        fprintf('Best TP = %d %d\n', output.Metrics.MissionCompletionRate.SortedPairIdx(1,2), output.Metrics.MissionCompletionRate.SortedPairIdx(1,1))
        %fprintf('Worst = %.2f %s %.2f :: Stat Signif = %d \n', output.Metrics.MissionCompletionRate.mean(output.Metrics.MissionCompletionRate.SortedIndices(end)), '$\pm$', output.Metrics.MissionCompletionRate.std(output.Metrics.MissionCompletionRate.SortedIndices(end)))
        %fprintf('Stat Signif = %d [could be 0 or 1]\n', output.Metrics.MissionCompletionRate.HypothTest.ttest2(output.Metrics.MissionCompletionRate.SortedPairIdx(end,1), output.Metrics.MissionCompletionRate.SortedPairIdx(end,2)))
        %fprintf('Worst TP = %d %d\n', output.Metrics.MissionCompletionRate.SortedPairIdx(end,2), output.Metrics.MissionCompletionRate.SortedPairIdx(end,1))
        fprintf('Str = %.2f %s %.2f\n', output.Metrics.MissionCompletionRate.mean(5), '$\pm$', output.Metrics.MissionCompletionRate.std(5,1))
        fprintf('Stat Signif = %d [could be 0 or 1; must be 0 if Worst is 0]\n', output.Metrics.MissionCompletionRate.HypothTest.ttest2(5,1))
        fprintf('Str TP = 1 5\n')
        
        fprintf('\nMission Speed Ratio\n')
        fprintf('Best = %.2f %s %.2f\n', output.Metrics.MissionSpeedRatio.mean(output.Metrics.MissionSpeedRatio.SortedIndices(1)), '$\pm$', output.Metrics.MissionSpeedRatio.std(output.Metrics.MissionSpeedRatio.SortedIndices(1)))
        fprintf('Stat Signif = %d [should be 0]\n', output.Metrics.MissionSpeedRatio.HypothTest.ttest2(output.Metrics.MissionSpeedRatio.SortedPairIdx(1,1), output.Metrics.MissionSpeedRatio.SortedPairIdx(1,2)))
        fprintf('Best TP = %d %d\n', output.Metrics.MissionSpeedRatio.SortedPairIdx(1,2), output.Metrics.MissionSpeedRatio.SortedPairIdx(1,1))
        %fprintf('Worst = %.2f %s %.2f :: Stat Signif = %d \n', output.Metrics.MissionSpeedRatio.mean(output.Metrics.MissionSpeedRatio.SortedIndices(end)), '$\pm$', output.Metrics.MissionSpeedRatio.std(output.Metrics.MissionSpeedRatio.SortedIndices(end)))
        %fprintf('Stat Signif = %d [could be 0 or 1]\n', output.Metrics.MissionSpeedRatio.HypothTest.ttest2(output.Metrics.MissionSpeedRatio.SortedPairIdx(end,1), output.Metrics.MissionSpeedRatio.SortedPairIdx(end,2)))
        %fprintf('Worst TP = %d %d\n', output.Metrics.MissionSpeedRatio.SortedPairIdx(end,2), output.Metrics.MissionSpeedRatio.SortedPairIdx(end,1))
        fprintf('Str = %.2f %s %.2f\n', output.Metrics.MissionSpeedRatio.mean(5), '$\pm$', output.Metrics.MissionSpeedRatio.std(5,1))
        fprintf('Stat Signif = %d [could be 0 or 1; must be 0 if Worst is 0]\n', output.Metrics.MissionSpeedRatio.HypothTest.ttest2(5,1))
        fprintf('Str TP = 1 5\n')
    end 

    %% Rank Matrix for RankSum Test 
    RankMatrix = nan(5,5,6);
    
    % MissionSuccess 
    [~, vv] = sort(output.Metrics.MissionSuccess.mean(:),'descend');
    [~, vv] = sort(vv);
    RankMat = reshape(vv, size(output.Metrics.MissionSuccess.mean));
    RankMatrix(:,:,1) = RankMat; 

    % MissionDecisionStability
    [~, vv] = sort(output.Metrics.MissionDecisionStability.mean(:),'descend');
    [~, vv] = sort(vv);
    RankMat = reshape(vv, size(output.Metrics.MissionDecisionStability.mean));
    RankMatrix(:,:,2) = RankMat; 

    % SwarmDecisionStability
    [~, vv] = sort(output.Metrics.SwarmDecisionStability.mean(:),'ascend');
    [~, vv] = sort(vv);
    RankMat = reshape(vv, size(output.Metrics.SwarmDecisionStability.mean));
    RankMatrix(:,:,3) = RankMat; 
    
    % MissionSwarmStability 
    [~, vv] = sort(output.Metrics.MissionSwarmStability.mean(:),'descend');
    [~, vv] = sort(vv);
    RankMat = reshape(vv, size(output.Metrics.MissionSwarmStability.mean));
    RankMatrix(:,:,4) = RankMat; 

    % MissionCompletionRate
    [~, vv] = sort(output.Metrics.MissionCompletionRate.mean(:),'ascend');
    [~, vv] = sort(vv);
    RankMat = reshape(vv, size(output.Metrics.MissionCompletionRate.mean));
    RankMatrix(:,:,5) = RankMat; 
    
    % MissionSpeedRatio
    [~, vv] = sort(output.Metrics.MissionSpeedRatio.mean(:),'descend');
    [~, vv] = sort(vv);
    RankMat = reshape(vv, size(output.Metrics.MissionSpeedRatio.mean));
    RankMatrix(:,:,6) = RankMat; 

    output.RankMatrix = RankMatrix; 

    for metric = 1:6
        RankVec(:,metric) = reshape(output.RankMatrix(:,:,metric), [], 1);
    end

    output.RankVector = RankVec; 

    %% Hussein Rank Test Stuff 
    % When possibility here is to define a threshold. 
    % X is greater than Y does not mean X is better unless the difference is > the threshold. 
    % When multiple TP are not better than a particular TP, they all get the same rank, which is the mid point in their range. 
    % For example, 1, 2, 3, 4, 5, 10 --> assuming a threshold is 4, only 10 is higher than 5, so the ranks will be 3, 3, 3, 3, 3, 6.

    % 1-  conduct t-test and select each dataset 
        MetricsFieldname = fieldnames(output.Metrics); 
        %% Statistical Testing Code Here
        for iter = 1:numel(MetricsFieldname)
            dat = output.Metrics.(MetricsFieldname{iter}).HypothTest.ttest2; 
            RankSums.h(iter,:) = [25-sum(dat(dat==1)) sum(dat(dat==1))];
            RankSums.mid(iter,:) = [ceil(median(1:RankSums.h(iter,1))) ceil(median((RankSums.h(iter,1)+1):(RankSums.h(iter,1)+RankSums.h(iter,2))))];
            RankSums.rnk(:,:,iter) = RankSums.mid(iter,1)*(dat==0) + RankSums.mid(iter,2)*(dat==1); 
        end

        output.RankSums = RankSums; 

end 
%