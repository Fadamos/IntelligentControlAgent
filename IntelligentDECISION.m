function output = IntelligentDECISION(df, Intent, Scenario)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-27
    % Explanaton: Intelligent control agent library for a particular scenario and intent 

    if ~exist('Scenario', 'var')
        Scenario = "S0"; 
    end

    CollectSET = unique(df.("Collect Tactic"));
    DriveSET = unique(df.("Drive Tactic"));
    
    if Scenario == "S0"
        subsetDF = df(:,[Intent 13:15]);
    else
        subsetIndex = find(df.Scenario == Scenario);
        subsetDF = df(subsetIndex,[Intent 13:15]);
    end 
    
    for COLLECT = 1:length(unique(subsetDF.("Collect Tactic")))
        for DRIVE = 1:length(unique(subsetDF.("Drive Tactic")))
            TacticINDEX = find(subsetDF.("Collect Tactic") == CollectSET(COLLECT) & subsetDF.("Drive Tactic") == DriveSET(DRIVE));
            TacticDF = subsetDF(TacticINDEX,:);
            TacticMatrix(COLLECT, DRIVE) = mean(TacticDF{:,1}); 
        end
    end
    
    switch Intent 
        case {1 4 5 7 9 11} % sort = descend
            SortedValues = reshape(sort(TacticMatrix(:), 'descend'), [size(TacticMatrix,1)*size(TacticMatrix,2), 1]); % sort values 
            SortedUnique = sort(unique(SortedValues), 'descend'); % linear indices
        case {2 3 6 8} % Intent = decision change --> sort = ascend
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
    TacticSet.SortedIdx = [r c];
    TacticSet.SortedIndices = SortedIndices; 
    
    output.TacticMatrix = TacticMatrix; 
    output.TacticSet = TacticSet; 

end 