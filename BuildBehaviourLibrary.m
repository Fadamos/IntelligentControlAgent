function output = BuildBehaviourLibrary(df)
    % Author: Adam J Hepworth
    % LastModified: 2022-09-26
    % Explanaton: Build the data library for the control agent to reference performance of a TP in particular settings 
    
    % INPUT         = 8,250 trial experimental data
    %
    % FUNCTION      = consolidate data to the output format with each value being 1/0 
    %
    % OUTPUT        = 5D array 
    %                   D1 --> Column   = Drive     [1,...,5 ] $\sigma_1$
    %                   D2 --> Row      = Collect   [1,...,5 ] $\sigma_2$
    %                   D3 --> Depth-1  = Metric    [1,...,6 ] $M$
    %                   D4 --> Depth-2  = Scenario  [1,...,14] $S$
    %                   D5 --> Depth-3  = Stat Test [1,...,3 ] t-test, KS-test, Rank-Sum Test

    
    
end