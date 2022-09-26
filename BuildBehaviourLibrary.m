function datacube = BuildBehaviourLibrary(df, printFlag)
    % Author: Adam J Hepworth
    % LastModified: 2022-09-26
    % Explanaton: Build the data library for the control agent to reference performance of a TP in particular settings 
    
    % INPUT         = 8,250 trial experimental data
    %
    % FUNCTION      = consolidate data to the output format with each value being 1/0 
    %
    % OUTPUT        = 6D array 
    %                   D1 --> Column   = Drive     [1,...,5 ] $\sigma_1$
    %                   D2 --> Row      = Collect   [1,...,5 ] $\sigma_2$
    %                   D3 --> Page-1   = Metric    [1,...,6 ] MS, MDS, DSS, MSS, MCR, MSp 
    %                   D4 --> Page-2   = Scenario  [1,...,14] 0 (all), He, Ho, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    %                   D5 --> Page-3   = Stat Test [1,...,3 ] t-test, KS-test, Rank-Sum Test, mean, std
    %                 
    % 
    
    if ~exist('printFlag', 'var')
        printFlag = 0; % Y/N print subordinate data from calling IntelligentDECISION; 0 = no; 1 = thesis; 2 = journal
    end

    initData.s0      = IntelligentDECISION(df, 1, "S0", 0.05, printFlag);
    initData.s_He    = IntelligentDECISION(df, 1, "S_He", 0.05, printFlag);
    initData.s_Ho    = IntelligentDECISION(df, 1, "S_Ho", 0.05, printFlag);
    initData.s1      = IntelligentDECISION(df, 1, "S1", 0.05, printFlag);
    initData.s2      = IntelligentDECISION(df, 1, "S2", 0.05, printFlag);
    initData.s3      = IntelligentDECISION(df, 1, "S3", 0.05, printFlag);
    initData.s4      = IntelligentDECISION(df, 1, "S4", 0.05, printFlag);
    initData.s5      = IntelligentDECISION(df, 1, "S5", 0.05, printFlag);
    initData.s6      = IntelligentDECISION(df, 1, "S6", 0.05, printFlag);
    initData.s7      = IntelligentDECISION(df, 1, "S7", 0.05, printFlag);
    initData.s8      = IntelligentDECISION(df, 1, "S8", 0.05, printFlag);
    initData.s9      = IntelligentDECISION(df, 1, "S9", 0.05, printFlag);
    initData.s10     = IntelligentDECISION(df, 1, "S10", 0.05, printFlag);
    initData.s11     = IntelligentDECISION(df, 1, "S11", 0.05, printFlag);

    datacube = nan(5,5,6,14,5); 

    fnScenario = fieldnames(initData); 
    fnMetric = fieldnames(initData.s0.Metrics); 

    for COLLECT = 1:5
        for DRIVE = 1:5
            for METRIC = 1:6
                for SCENARIO = 1:14
                    datacube(COLLECT,DRIVE,METRIC,SCENARIO,1) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).HypothTest.ttest2(COLLECT,DRIVE); 
                    datacube(COLLECT,DRIVE,METRIC,SCENARIO,2) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).HypothTest.kstest2(COLLECT,DRIVE);
                    %datacube(COLLECT,DRIVE,METRIC,SCENARIO,3) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).HypothTest.kruskalwallis(COLLECT,DRIVE);
                    datacube(COLLECT,DRIVE,METRIC,SCENARIO,4) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).mean(COLLECT,DRIVE);
                    datacube(COLLECT,DRIVE,METRIC,SCENARIO,5) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).std(COLLECT,DRIVE);    
                end
            end
        end
    end

    save('/Users/ajh/GitHub/IntelligentControlAgent/datacube.mat','datacube')
    
end

