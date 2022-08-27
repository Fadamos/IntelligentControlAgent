function output = ObjectiveLibraryDECISION(df)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-26
    % Explanaton: Intelligent control agent   

    for SCENARIO = 1:length(unique(df.Scenario))
        % subset scenario data 
        ScenarioINDEX = find(df.Scenario == unique(df.Scenario(SCENARIO)));
        ScenarioDF = df(ScenarioINDEX,:);
            for COLLECT = 1:length(unique(ScenarioDF.("Collect Tactic")))
                for DRIVE = 1:length(unique(ScenarioDF.("Drive Tactic")))
                    TacticINDEX = find(ScenarioDF.("Collect Tactic") == unique(ScenarioDF.("Collect Tactic")(COLLECT)) & ScenarioDF.("Drive Tactic") == unique(ScenarioDF.("Drive Tactic")(DRIVE)));
                    TacticDF = ScenarioDF(TacticINDEX,:);
                    % mission success
                    output(COLLECT, DRIVE, 1, SCENARIO) = mean(TacticDF.("Mssn Success")); 
                    % decision changes
                    output(COLLECT, DRIVE, 2, SCENARIO) = mean(TacticDF.("Decision Chg"));
                    % mission length 
                    output(COLLECT, DRIVE, 3, SCENARIO) = mean(TacticDF.("Mssn Length"));
                    % mission speed
                    output(COLLECT, DRIVE, 4, SCENARIO) = mean(TacticDF.("Mssn Speed"));
                    % mission completion rate 
                    output(COLLECT, DRIVE, 5, SCENARIO) = mean(TacticDF.("Mssn Comp Rate"));
                    % swarm total distance 
                    output(COLLECT, DRIVE, 6, SCENARIO) = mean(TacticDF.("Swarm Total Dist"));
                    % swarm average distance per time step 
                    output(COLLECT, DRIVE, 7, SCENARIO) = mean(TacticDF.("Swarm Avg Dist"));
                    % control agent total distance 
                    output(COLLECT, DRIVE, 8, SCENARIO) = mean(TacticDF.("Cntrl Total Dist"));
                    % control agent average distance per time step 
                    output(COLLECT, DRIVE, 9, SCENARIO) = mean(TacticDF.("Cntrl Avg Dist"));
                    % average number of separated swarm agents 
                    output(COLLECT, DRIVE, 11, SCENARIO) = mean(TacticDF.("Avg Num Sep pi"));
                end
            end
    end

end
