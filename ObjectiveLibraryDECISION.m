function output = ObjectiveLibraryDECISION(df)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-27
    % Explanaton: Intelligent control agent   

    %% data generation

    ScenarioSET = unique(df.Scenario); 
    CollectSET = unique(df.("Collect Tactic"));
    DriveSET = unique(df.("Drive Tactic"));
    for SCENARIO = 1:length(unique(df.Scenario))
        % subset scenario data
        ScenarioINDEX = find(df.Scenario == ScenarioSET(SCENARIO));
        ScenarioDF = df(ScenarioINDEX,:);
        fprintf('Scenario = S%i\n', SCENARIO)
            for COLLECT = 1:length(unique(ScenarioDF.("Collect Tactic")))
                for DRIVE = 1:length(unique(ScenarioDF.("Drive Tactic")))
                    TacticINDEX = find(ScenarioDF.("Collect Tactic") == CollectSET(COLLECT) & ScenarioDF.("Drive Tactic") == DriveSET(DRIVE));
                    TacticDF = ScenarioDF(TacticINDEX,:);
                    %fprintf('Collect = C%i\n', COLLECT)
                    %fprintf('Drive = C%i\n', DRIVE)
                    % mission success
                    TacticMatrix(COLLECT, DRIVE, 1, SCENARIO) = mean(TacticDF.("Mssn Success")); 
                    % decision changes
                    TacticMatrix(COLLECT, DRIVE, 2, SCENARIO) = mean(TacticDF.("Decision Chg"));
                    % mission length 
                    TacticMatrix(COLLECT, DRIVE, 3, SCENARIO) = mean(TacticDF.("Mssn Length"));
                    % mission speed
                    TacticMatrix(COLLECT, DRIVE, 4, SCENARIO) = mean(TacticDF.("Mssn Speed"));
                    % mission completion rate 
                    TacticMatrix(COLLECT, DRIVE, 5, SCENARIO) = mean(TacticDF.("Mssn Comp Rate"));
                    % swarm total distance 
                    TacticMatrix(COLLECT, DRIVE, 6, SCENARIO) = mean(TacticDF.("Swarm Total Dist"));
                    % swarm average distance per time step 
                    TacticMatrix(COLLECT, DRIVE, 7, SCENARIO) = mean(TacticDF.("Swarm Avg Dist"));
                    % control agent total distance 
                    TacticMatrix(COLLECT, DRIVE, 8, SCENARIO) = mean(TacticDF.("Cntrl Total Dist"));
                    % control agent average distance per time step 
                    TacticMatrix(COLLECT, DRIVE, 9, SCENARIO) = mean(TacticDF.("Cntrl Avg Dist"));
                    % average number of separated swarm agents 
                    TacticMatrix(COLLECT, DRIVE, 10, SCENARIO) = mean(TacticDF.("Avg Num Sep pi"));
                end
            end
    end


    %% summary statistics
    
    % 1- 'default' tactic pair for all scenarios for each intent
    for COLLECT = 1:size(TacticMatrix,1)
        for DRIVE = 1:size(TacticMatrix,2)
            for INTENT = 1:size(TacticMatrix,3)
            TacticSummary(COLLECT, DRIVE, INTENT) = sum(TacticMatrix(COLLECT,DRIVE,INTENT,:))/size(TacticMatrix,3);
            end
        end
    end
    
    Tactic.I1.value = max(max(TacticSummary(:,:,1))); 
    Tactic.I1.linIdx = find(TacticSummary(:,:,1) == max(max(TacticSummary(:,:,1))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I1.linIdx]);
    Tactic.I1.Idx = [r c];
    
    Tactic.I2.value = min(min(TacticSummary(:,:,2)));
    Tactic.I2.linIdx = find(TacticSummary(:,:,2) == min(min(TacticSummary(:,:,2))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I2.linIdx]);
    Tactic.I2.Idx = [r c];
    
    Tactic.I3.value = min(min(TacticSummary(:,:,3)));
    Tactic.I3.linIdx = find(TacticSummary(:,:,3) == min(min(TacticSummary(:,:,3))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I3.linIdx]);
    Tactic.I3.Idx = [r c];
    
    Tactic.I4.value = max(max(TacticSummary(:,:,4)));
    Tactic.I4.linIdx = find(TacticSummary(:,:,4) == max(max(TacticSummary(:,:,4))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I4.linIdx]);
    Tactic.I4.Idx = [r c]; 
    
    Tactic.I5.value = max(max(TacticSummary(:,:,5)));
    Tactic.I5.linIdx = find(TacticSummary(:,:,5) == max(max(TacticSummary(:,:,5))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I5.linIdx]);
    Tactic.I5.Idx = [r c];
    
    Tactic.I6.value = min(min(TacticSummary(:,:,6)));
    Tactic.I6.linIdx = find(TacticSummary(:,:,6) == min(min(TacticSummary(:,:,6))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I6.linIdx]);
    Tactic.I6.Idx = [r c];
    
    Tactic.I7.value = max(max(TacticSummary(:,:,7)));
    Tactic.I7.linIdx = find(TacticSummary(:,:,7) == max(max(TacticSummary(:,:,7))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I7.linIdx]);
    Tactic.I7.Idx = [r c];
    
    Tactic.I8.value = min(min(TacticSummary(:,:,8))); 
    Tactic.I8.linIdx = find(TacticSummary(:,:,8) == min(min(TacticSummary(:,:,8))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I8.linIdx]);
    Tactic.I8.Idx = [r c];
    
    Tactic.I9.value = max(max(TacticSummary(:,:,9)));
    Tactic.I9.linIdx = find(TacticSummary(:,:,9) == max(max(TacticSummary(:,:,9))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I9.linIdx]);
    Tactic.I9.Idx = [r c];
    
    Tactic.I10.value = min(min(TacticSummary(:,:,10)));
    Tactic.I10.linIdx = find(TacticSummary(:,:,10) == min(min(TacticSummary(:,:,10))));
    [r,c] = ind2sub([size(TacticMatrix,1) size(TacticMatrix,2)],[Tactic.I10.linIdx]);
    Tactic.I10.Idx = [r c];

    %% save data
    output.Data = df; 
    output.TacticMatrix = TacticMatrix; 
    output.TacticSummary = TacticSummary; 
    output.Tactic = Tactic; 

end
