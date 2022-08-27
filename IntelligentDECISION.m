function output = IntelligentDECISION(df, Scenario, Intent)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-27
    % Explanaton: Intelligent control agent library for a particular scenario and intent 

    CollectSET = unique(df.("Collect Tactic"));
    DriveSET = unique(df.("Drive Tactic"));
    
    subsetIndex = find(df.Scenario == Scenario);
    subsetDF = df(subsetIndex,[Intent 13:15]);
    
    for COLLECT = 1:length(unique(subsetDF.("Collect Tactic")))
        for DRIVE = 1:length(unique(subsetDF.("Drive Tactic")))
            TacticINDEX = find(subsetDF.("Collect Tactic") == CollectSET(COLLECT) & subsetDF.("Drive Tactic") == DriveSET(DRIVE));
            TacticDF = ScenarioDF(TacticINDEX,:);
            TacticMatrix(COLLECT, DRIVE) = mean(TacticDF{:,1}); 
        end
    end

    if Intent = 1
        % obtain linear indices
        % sort values 
        % return index with value in sorted order 
    elseif Intent = 2
    elseif Intent = 3
    elseif Intent = 4    
    elseif Intent = 5
    elseif Intent = 6
    elseif Intent = 7
    elseif Intent = 8
    elseif Intent = 9
    elseif Intent = 11
    end

    output.TacticMatrix = TacticMatrix; 

end 