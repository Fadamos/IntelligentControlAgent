function output = DecisionModel(parameters, datacube, ProbMat, NewObs, TwoClass, TwoClassProb, CurrentTacticPair,  scenario_agent, scenario_library, ProbThreshold)
    % Author: Adam J Hepworth
    % LastModified: 2022-10-26
    % Explanaton: Intelligent control agent decision module 
    
    %% (1) Data and scenario statistics
    ScenarioFlag = false; % false = specific scenario; true for two-class

    ProbMat = [ProbMat; NewObs']; 

    ProbMatScenario = ProbMat(:,3:end); 
    ProbMatType = ProbMat(:,1:2); 
    
    if ~exist('ProbThreshold', 'var')
        ProbThreshold = 0.69;
    end

    %% (1) Agent classification logic 

    agent_out = sum(abs(scenario_library - scenario_agent)');  %% THIS NEEDS TO BE FIXED TO INCLUDE THIS DATA IN THE SCENARIO TYPE! 

    %% (2) Assess Heterogeneous or Homogeneous 
    ScenarioTwoClass = string(TwoClass); 
    ProbMatType = find(max(sum(ProbMatType > 0.69)) == sum(ProbMatType > 0.69));
    if ProbMatType == 2
        fprintf('Assessed Scenario type is Homogeneous\n')
        subCube = squeeze(datacube(:, :, parameters.intent, 3, :)); 
    elseif ProbMatType == 1
        subCube = squeeze(datacube(:, :, parameters.intent, 2, :)); 
        fprintf('Assessed Scenario type is Heterogeneous\n')
    else
        subCube = squeeze(datacube(:, :, parameters.intent, 1, :)); 
        fprintf('Insufficient data to determine if Heterogeneous or Homogeneous (Pr > %.2f)\n',ProbThreshold)
        fprintf('Assessed Scenario type is Default\n')
    end 

    %% (3) Assess specific scenario 
    if ProbMatType == 2
        ProbMatScenario = ProbMatScenario(:,5:end);
    elseif ProbMatType == 1
        ProbMatScenario = ProbMatScenario(:,1:4);
    end 
    
    mu = mean(ProbMatScenario,1); 
    sigma = var(ProbMatScenario,1);

    ref_scenario = find(max(mu - sigma) == (mu - sigma)); 

    p = nan(size(ProbMatScenario,2),1);
    h = nan(size(ProbMatScenario,2),1);
    for test_scenario = 1:size(ProbMatScenario,2)
        if test_scenario ~= ref_scenario
            [p(test_scenario), h(test_scenario)]= ranksum(ProbMatScenario(:,ref_scenario),ProbMatScenario(:,test_scenario));
        end
    end 

    if ProbMatType == 2 % output must account for 
        ref_scenario = ref_scenario + 4; 
    end
    if nansum(h) < length(h)-1
        fprintf('Assessed Scenario S%i not statistically significant (num scenarios = %i).\n',ref_scenario,(length(h)-nansum(h)))
    else
        subCube = squeeze(datacube(:, :, parameters.intent, ref_scenario, :)); 
        fprintf('Assessed Scenario is S%i\n',ref_scenario)
    end


    % datacube = [collect drive metric scenario hypoth-test]
    % 6D array 
    %           D1 --> Column   = Drive     [1,...,5 ] $\sigma_1$
    %           D2 --> Row      = Collect   [1,...,5 ] $\sigma_2$
    %           D3 --> Page-1   = Metric    [1,...,6 ] MS, MDS, DSS, MSS, MCR, MSp 
    %           D4 --> Page-2   = Scenario  [1,...,14] 0 (all), He, Ho, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    %           D5 --> Page-3   = Stat Test [1,...,3 ] t-test, KS-test, Rank-Sum Test, mean, std

    %% (4) Determine if we need to change TP (i.e. is the current feasible for the scenario)
    % Note: subCube takes the form [5 5 5] = [drive collect result]

    viableTP = (1 - subCube(:,:,1)) .* subCube(:,:,4); % return only the viable TPs via t-test, presenting only mean performance matrix
    
    % test if the current TP is considered viable or not 
    if viableTP(find(CurrentTacticPair(1) == parameters.TacticDriveReference), find(CurrentTacticPair(2) == parameters.TacticCollectReference)) ~= 0
        % if viable, then set the next TP to the current TP 
        row = find(CurrentTacticPair(1) == parameters.TacticDriveReference); 
        col = find(CurrentTacticPair(2) == parameters.TacticCollectReference); 
    else % set the next TP to the TP that maximises the likelihood of metric performance
        [row, col] = find(viableTP == max(max(viableTP))); % select the TP with the highest performance (noting that they are all stat signif differentiable)
    end
    
    %% (5) Output selected scenario and data 
    output.row = row(1); 
    output.col = col(1); 
    
    output.scenario = ref_scenario; 
    output.stats = [p h];
    output.viableTP = viableTP; 
    output.ProbMat = ProbMat; 
    
end
