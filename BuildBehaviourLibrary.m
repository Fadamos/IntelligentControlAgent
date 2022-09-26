function output = BuildBehaviourLibrary(df)
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
    %                   D3 --> Depth-1  = Metric    [1,...,6 ] $M$
    %                   D4 --> Depth-2  = Scenario  [1,...,14] $S$
    %                   D5 --> Depth-3  = Stat Test [1,...,3 ] t-test, KS-test, Rank-Sum Test
    %                   D6 --> Depth-4  = Value     [1,...,2 ] Mean, Std
    %                 
    % 
    initData.s0      = IntelligentDECISION(df, 1, "S0", 0.05, 1);
    initData.s_He    = IntelligentDECISION(df, 1, "S_He", 0.05, 1);
    initData.s_Ho    = IntelligentDECISION(df, 1, "S_Ho", 0.05, 1);
    initData.s1      = IntelligentDECISION(df, 1, "S1", 0.05, 1);
    initData.s2      = IntelligentDECISION(df, 1, "S2", 0.05, 1);
    initData.s3      = IntelligentDECISION(df, 1, "S3", 0.05, 1);
    initData.s4      = IntelligentDECISION(df, 1, "S4", 0.05, 1);
    initData.s5      = IntelligentDECISION(df, 1, "S5", 0.05, 1);
    initData.s6      = IntelligentDECISION(df, 1, "S6", 0.05, 1);
    initData.s7      = IntelligentDECISION(df, 1, "S7", 0.05, 1);
    initData.s8      = IntelligentDECISION(df, 1, "S8", 0.05, 1);
    initData.s9      = IntelligentDECISION(df, 1, "S9", 0.05, 1);
    initData.s10     = IntelligentDECISION(df, 1, "S10", 0.05, 1);
    initData.s11     = IntelligentDECISION(df, 1, "S11", 0.05, 1);

    datacube = nan(5,5,6,14,3,2); 

    
    fnScenario = fieldnames(initData); 
    fnMetric = fieldnames(initData.s0.Metrics); 

    for METRIC = 1:6
        for SCENARIO = 1:14
            datacube(:,:,METRIC,SCENARIO,1,:) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).HypothTest.ttest2; 
            datacube(:,:,METRIC,SCENARIO,2,:) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).HypothTest.kstest2;
            datacube(:,:,METRIC,SCENARIO,:,1) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).mean;
            datacube(:,:,METRIC,SCENARIO,:,2) = initData.(fnScenario{SCENARIO}).Metrics.(fnMetric{METRIC}).std;
        end
    end

    datacube()

    
end

