function output = IntelligentDECISION(df, Intent, Scenario, Tactic)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-26
    % Explanaton: Intelligent control agent   

    for SCENARIO = 1:Scenario
        for INTENT = 1:Intent 
            for COLLECT = 1:Collect 
                for DRIVE 1:Drive
                    subDF = df(:,SELECT DATA HERE);
                    score(COLLECT, DRIVE, INTENT, SCENARIO) = mean(subDF); 
                end
            end
        end
    end

end