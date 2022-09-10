function output = IntelligentDECISION(library, Intent, Scenario, SignifThreshold)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-28
    % Explanaton: Intelligent control agent data library 

    % collect = C2D  C2H  F2D  F2G  F2H
    % drive   = DAH  DHH  DOAT DQH  DTQH

    if ~exist('Scenario', 'var')
        Scenario = "S0"; % if scenario is not given, default to best tactic-pair across all scenarios
    end
    if ~exist('SignifThreshold', 'var')
        SignifThreshold = 0.05; % statistical significance threshold for testing
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
            % Mission Success
            MissionSuccess(COLLECT, DRIVE) = mean(DF.("Mssn Success")); % maximise 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            RawMetrics.MissionSuccess.(strName) = TacticDF; 
            % Mission Decision Stability
            MissionDecisionStability(COLLECT, DRIVE) = mean(DF.("Mssn Success")./DF.("Decision Chg")); % maximise 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            RawMetrics.MissionDecisionStability.(strName) = TacticDF; 
            % Swarm Decision Stability
            SwarmDecisionStability(COLLECT, DRIVE) = mean(DF.("Avg Num Sep pi")./DF.("Decision Chg")); % minimise 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            RawMetrics.SwarmDecisionStability.(strName) = TacticDF; 
            % Mission Swarm Stability
            MissionSwarmStability(COLLECT, DRIVE) = mean(DF.("Mssn Success")./DF.("Avg Num Sep pi")); % maximise 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            RawMetrics.MissionSwarmStability.(strName) = TacticDF; 
            % Mission Completion Rate
            MissionCompletionRate(COLLECT, DRIVE) = mean(DF.("Mssn Comp Rate")); % minimise 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            RawMetrics.MissionCompletionRate.(strName) = TacticDF; 
            % Mission Speed Ratio
            MissionSpeedRatio(COLLECT, DRIVE) = mean(DF.("Mssn Speed")); % maximise 
            strName = ['c',num2str(COLLECT),'d',num2str(DRIVE)]; 
            RawMetrics.MissionSpeedRatio.(strName) = TacticDF; 
        end
    end

    output.Metrics.MissionSuccess.mean           = MissionSuccess; 
    output.Metrics.MissionDecisionStability.mean = MissionDecisionStability; 
    output.Metrics.SwarmDecisionStability.mean   = SwarmDecisionStability; 
    output.Metrics.MissionSwarmStability.mean    = MissionSwarmStability;
    output.Metrics.MissionCompletionRate.mean    = MissionCompletionRate;
    output.Metrics.MissionSpeedRatio.mean        = MissionSpeedRatio; 
    output.RawMetrics                            = RawMetrics; 
    
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
    end

     
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


end 
%