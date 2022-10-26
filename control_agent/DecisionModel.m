function output = DecisionModel(parameters, datacube, ProbMat, NewObs, TwoClass, TwoClassProb, CurrentTacticPair, ProbThreshold)
    % Author: Adam J Hepworth
    % LastModified: 2022-10-26
    % Explanaton: Intelligent control agent decision module 
    
    %% (1) Data and scenario statistics
    ScenarioFlag = false; % false = specific scenario; true for two-class

    ProbMat = [ProbMat; NewObs(3:end)']; 
    
    if ~exist('ProbThreshold', 'var')
        ProbThreshold = 0.69;
    end

    %% (2) Assess specific scenario 
    mu = mean(ProbMat,1); % remove He and Ho columns 
    sigma = var(ProbMat,1); 

    mean_var = find(max(mu - sigma) == (mu - sigma)); 

    ref_scenario = find(max(mu) == mu); 
    p = nan(size(ProbMat,2),1);
    h = nan(size(ProbMat,2),1);
    for test_scenario = 1:size(ProbMat,2)
        if test_scenario ~= ref_scenario
            [p(test_scenario), h(test_scenario)]= ranksum(ProbMat(:,ref_scenario),ProbMat(:,test_scenario));
        end
    end
    %[p h] 

    if nansum(h) < length(h)-1
        ScenarioFlag = true; 
        fprintf('Assessed Scenario not statistically significant.\n')
    else 
        subCube = squeeze(datacube(:, :, parameters.intent, ref_scenario, :)); 
        fprintf('Assessed statistically significant Scenario is S%i\n',ref_scenario)
    end

    %% (3) Assess Heterogeneous or Homogeneous if unable 
    if ScenarioFlag
        ScenarioTwoClass = string(TwoClass); 
        if TwoClassProb(2) > ProbThreshold
            fprintf('Assessed Scenario type is Homogeneous\n')
            subCube = squeeze(datacube(:, :, parameters.intent, 3, :)); 
        elseif TwoClassProb(1) > ProbThreshold
            subCube = squeeze(datacube(:, :, parameters.intent, 2, :)); 
            fprintf('Assessed Scenario type is Heterogeneous\n')
        else
            subCube = squeeze(datacube(:, :, parameters.intent, 1, :)); 
            fprintf('Insufficient data to determine if Heterogeneous or Homogeneous (Pr > %.2f)\n',ProbThreshold)
            fprintf('Assessed Scenario type is Default\n')
        end 
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
    output.row = row; 
    output.col = col; 
    
    output.scenario = ref_scenario; 
    output.stats = [p h];
    output.viableTP = viableTP; 
    output.ProbMat = ProbMat; 
    
end