function output = DecisionModel(parameters, datacube, ProbMat, ClassPredict, TwoClass, TwoClassProb, CurrentTacticPair,  scenario_agent, scenario_library, ProbThreshold)
    % Author: Adam J Hepworth
    % LastModified: 2022-10-26
    % Explanaton: Intelligent control agent decision module 
    
    %% (0) Init 
    if ~exist('ProbThreshold', 'var')
        ProbThreshold = 0.69;
    end    

    %% (1) Agent classification logic --> agent to swarm 
    
    % difference 
    agent_out = sum(abs(scenario_library - scenario_agent)');  
   
    for type = 1:size(scenario_library,1)
        % 1- L2 norm of difference between observed swarm and known scenario 
        % 2- observed is the sum of probabilities from the classifier for each agent 
        % 3- the output norm gives us a 'euclidenan distance' that the observation is from each scenario (our observation is ref) 
        agent_out(type) = norm(abs(scenario_agent - scenario_library(type,:)), 2); 
    end
    % 1- inverse distance weighting technique
    % 2- motivated by weighted average as it applies an inverse transform to each of the distancnes (from L2 norm) 
    %    to give a likelihood measure where the larger the distance from the reference (observed scenario), 
    %    the smaller the inverse (i.e. smaller likelihood)
    % 3- https://stackoverflow.com/questions/23459707/how-to-convert-distance-into-probability
    % 4- https://en.wikipedia.org/wiki/Inverse_distance_weighting
    AgentPred = (1./agent_out)./(sum(1./agent_out)); 
    
                                      % He - Ho - S1 - S2 - S3 - S4 - S5 - S6 - S7 - S8 - S9 - S10 - S11 
    NewObs = [ClassPredict.C2.score(1)                                                          % He 
              ClassPredict.C2.score(2)                                                          % Ho
              mean([ClassPredict.C2He.score(1) ClassPredict.C2He2.score(2) AgentPred(1)])       % S1
              mean([ClassPredict.C2He.score(2) ClassPredict.C2He2.score(3) AgentPred(2)])       % S2                                        
              mean([ClassPredict.C2He.score(3) ClassPredict.C2He2.score(4) AgentPred(3)])       % S3                                        
              mean([ClassPredict.C2He.score(4) ClassPredict.C2He2.score(5) AgentPred(4)])       % S4                                        
              mean([ClassPredict.C2Ho.score(3) ClassPredict.C2Ho2.score(4) AgentPred(5)])       % S5                                        
              mean([ClassPredict.C2Ho.score(4) ClassPredict.C2Ho2.score(5) AgentPred(6)])       % S6                                         
              mean([ClassPredict.C2Ho.score(5) ClassPredict.C2Ho2.score(6) AgentPred(7)])       % S7                                         
              mean([ClassPredict.C2Ho.score(6) ClassPredict.C2Ho2.score(7) AgentPred(8)])       % S8                                         
              mean([ClassPredict.C2Ho.score(7) ClassPredict.C2Ho2.score(8) AgentPred(9)])       % S9                                         
              mean([ClassPredict.C2Ho.score(1) ClassPredict.C2Ho2.score(2) AgentPred(10)])      % S10                                         
              mean([ClassPredict.C2Ho.score(2) ClassPredict.C2Ho2.score(3) AgentPred(11)])];    % S11     

    ProbMat = [ProbMat; NewObs']; 

    ProbMatScenario = ProbMat(:,3:end); 
    ProbMatType = ProbMat(:,1:2); 

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

    % mean minus variance is our reference scenario (highest mean likelihood with least variability)
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
    % selected TP from decision model enginge
    output.row = row(1); 
    output.col = col(1); 
    % supporting data
    output.scenario = ref_scenario; 
    output.stats = [p h];
    output.viableTP = viableTP; 
    output.ProbMat = ProbMat; 
    output.score = NewObs; 
    output.ProbMatType = ProbMatType;
    output.ProbMatScenario = ProbMatScenario; 
    output.mu = mu; 
    output.sigma = sigma; 
    output.ProbThreshold = ProbThreshold; 
    output.agent_out = agent_out; 
    output.MeanVar = mu - sigma;    
end
%