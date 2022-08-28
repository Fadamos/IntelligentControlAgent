function output = IntelligentDECISION(df, Intent, Scenario)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-28
    % Explanaton: Intelligent control agent data library 

    if ~exist('Scenario', 'var')
        Scenario = "S0"; % if scenario is not given, default to best tactic-pair across all scenarios
    end
    
    if Scenario == "S0"
        subsetDF = df(:,[Intent 13:15]); 
    else
        subsetIndex = find(df.Scenario == Scenario);
        subsetDF = df(subsetIndex,[Intent 13:15]);
    end

    CollectSET = unique(df.("Collect Tactic"));
    DriveSET = unique(df.("Drive Tactic"));
    
    for COLLECT = 1:length(unique(subsetDF.("Collect Tactic")))
        for DRIVE = 1:length(unique(subsetDF.("Drive Tactic")))
            TacticINDEX = find(subsetDF.("Collect Tactic") == CollectSET(COLLECT) & subsetDF.("Drive Tactic") == DriveSET(DRIVE));
            TacticDF = subsetDF(TacticINDEX,:);
            TacticMatrix(COLLECT, DRIVE) = mean(TacticDF{:,1}); 
        end
    end
    
    switch Intent 
        case {1 4 5 7 9 11} % intent = maximise; sort = descend
            SortedValues = reshape(sort(TacticMatrix(:), 'descend'), [size(TacticMatrix,1)*size(TacticMatrix,2), 1]); % sort values 
            SortedUnique = sort(unique(SortedValues), 'descend'); % linear indices
        case {2 3 6 8} % intent = minimise; sort = ascend
            SortedValues = reshape(sort(TacticMatrix(:), 'ascend'), [size(TacticMatrix,1)*size(TacticMatrix,2), 1]);
            SortedUnique = sort(unique(SortedValues), 'ascend'); 
    end 

    SortedIndices = []; 
    for UniqueElm = 1:length(SortedUnique)
        SortedIndices = [SortedIndices; find(TacticMatrix == SortedUnique(UniqueElm))];
    end
    % return index with value in sorted order
    [r, c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],SortedIndices);
    
    TacticSet.SortedValues = SortedValues; % values in sorted order for the intent
    TacticSet.SortedUnique = SortedUnique; % unique values in sorted order for the intent
    TacticSet.SortedIndices = SortedIndices; % sorted tacitc-pair linear indices 
    TacticSet.SortedIdx = [r c]; % COLLECT and DRIVE indices for tactic-pairs
    
    output.TacticMatrix = TacticMatrix; 
    output.TacticSet = TacticSet; 

end 