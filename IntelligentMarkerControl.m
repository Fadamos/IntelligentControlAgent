function output = IntelligentMarkerControl(Verbose, SensedData, parameters, SimulationTime, C1, C2, C2_He, C2_Ho, C2_He2, C2_Ho2, datacube, NumberOfSheep, FullSet, EvalCost, EvalGain, SwarmAgentAttnPoints, InteractionAgentProp, SwarmClassificationData, DrivingTacticIndex, CollectingTacticIndex)
    % Author: Adam J Hepworth
    % LastModified: 2022-09-26
    % Explanaton: Intelligent control agent
    
    if ~exist('intent', 'var')
        parameters.intent = 1; % mission success  
    end
    if ~exist('behaviourLibrary', 'var')
        parameters.behaviourLibrary = -1; % this needs to be the default TP eventually 
    end
    
    %% AGENT 1: External Observer Agent
    % <SCRIPT HERE>
    idx = find(SimulationTime==parameters.Windows(:,2)); 
    DecisionWindow = parameters.Windows(idx,:);
    Mrk = ExternalObserver(SensedData, parameters, DecisionWindow, FullSet); 
    
    % C1: Cost per marker set and C2: Cumulative cost across total simulation 
    EvalCost = [EvalCost; SimulationTime Mrk.M1.ComputeTime nan];
    EvalCost(end,end) = sum(EvalCost(:,2));
    
    % Save the markers! 
    nameAfterDot = ['Iter',num2str(SimulationTime)];
    MarkerSet.(nameAfterDot) = Mrk; 
    
    SwarmAgentAttnPoints = [SwarmAgentAttnPoints; Mrk.M4.AttentionPoints];
    InteractionAgentProp = [InteractionAgentProp; Mrk.M2.InteractionFraction];
    
    %% Task for Adam: Add sub-title with identified swarm type and current tactics selected (dynamic)
    % M2, M4 Marker Analysis Visualisation
    if parameters.InternalMarkerCalculationsVisual
        % figure
        figure(1)
        % swarm attention points 
        subplot(2,2,2)
        stackedplot(SwarmAgentAttnPoints) % need to go from the start of the vector! 
        % swarm number of attention points 
        subplot(2,2,3) 
        plot(sum(SwarmAgentAttnPoints,2))
        % swarm interaction summary values 
        subplot(2,2,4)
        if size(InteractionAgentProp,1) > 1
            contourf(InteractionAgentProp') 
        end
    end
    
    % M1: classification: agent (capabilities and traits) and swarm (configuration) 
    if parameters.OnlineClassifications
        fprintf('\n')
        [yfit, yfitSCORE] = C1.predictFcn(Mrk.M1.ClassDataArray);
        for i = 1:length(yfit)
            if parameters.VerboseBugger
                fprintf('Identified Agent No. %i: %s\n', i, yfit{i})
            end
            ClassPredYagent(i) = (string(yfit(i)) == parameters.SwarmAgentTypeDistribution(i));
        end
        fprintf('\nClassified Agent Distribution:\n')
        summary(categorical(string(cell2mat(yfit))))
        
        
        %% Classifier: Swarm Characteristics
        [yfit2class, yfit2classSCORE] = C2.predictFcn(Mrk.M3.L2norm);
        %if string(yfit2class) == "Heterogeneous" 
            [yfitHe, yfitHeSCORE]  = C2_He.predictFcn(Mrk.M3.L2norm); 
            %yfitHo = "NaN";
            %yfitHoSCORE = 0; 
        %elseif string(yfit2class) == "Homogeneous" 
            [yfitHo, yfitHoSCORE] = C2_Ho.predictFcn(Mrk.M3.L2norm); 
            %yfitHe = "NaN";
            %yfitHeSCORE = 0; 
        %end
        [yfitHe2, yfitHe2SCORE] = C2_He2.predictFcn(Mrk.M3.L2norm); 
        [yfitHo2, yfitHo2SCORE] = C2_Ho2.predictFcn(Mrk.M3.L2norm);  
        
        fprintf('Identified Swarm Type (Tree Classifier    C2        {Homogeneous Heterogeneous})                      = %s Pr(%.2f) \n', string(yfit2class), max(yfit2classSCORE))
        fprintf('Identified Swarm Type (Tree Classifier    C2_He     {S1, S2, S3, S4})                                 = %s Pr(%.2f) \n', string(yfitHe), max(yfitHeSCORE))
        fprintf('Identified Swarm Type (Tree Classifier    C2_Ho     {S5, S6, S7, S8, S9, S10, S11})                   = %s Pr(%.2f) \n', string(yfitHo), max(yfitHoSCORE))
        fprintf('Identified Swarm Type (FF ANN Classifier  C2_He2    {S1, S2, S3, S4, Homogeneous})                    = %s Pr(%.2f) \n', string(yfitHe2), max(yfitHe2SCORE))
        fprintf('Identified Swarm Type (Tree Classifier    C2_Ho2    {S5, S6, S7, S8, S9, S10, S11, Heterogeneous})    = %s Pr(%.2f) \n', string(yfitHo2), max(yfitHo2SCORE))
        fprintf('\n* * * * * Ground Truth Swarm Type: %s\n', parameters.ScenarioIndex)

        %% Record performance data here and save it 
        SwarmClassificationData = [SwarmClassificationData; parameters.ScenarioIndex string(yfit2class) string(yfitHe) string(yfitHo) string(yfitHe2) string(yfitHo2)];
        
        ClassPredict.C1.yfit = yfit; 
        ClassPredict.C1.score = yfitSCORE; 
        ClassPredict.C2.yfit = yfit2class; 
        ClassPredict.C2.score = yfit2classSCORE; 
        ClassPredict.C2He.yfit = yfitHe; 
        ClassPredict.C2He.score = yfitHeSCORE; 
        ClassPredict.C2Ho.yfit = yfitHo;
        ClassPredict.C2Ho.score = yfitHoSCORE;
        ClassPredict.C2He2.yfit = yfitHe2;
        ClassPredict.C2He2.score = yfitHe2SCORE;
        ClassPredict.C2Ho2.yfit = yfitHo2;
        ClassPredict.C2Ho2.score = yfitHo2SCORE;
    
                              % He - Ho - S1 - S2 - S3 - S4 - S5 - S6 - S7 - S8 - S9 - S10 - S11 
        ClassPredict.score = [mean([ClassPredict.C2.score(1) ClassPredict.C2Ho2.score(1)]) % He 
            mean([ClassPredict.C2.score(2) ClassPredict.C2He2.score(1)])                   % Ho
            mean([ClassPredict.C2He.score(1) ClassPredict.C2He2.score(2)])                 % S1
            mean([ClassPredict.C2He.score(2) ClassPredict.C2He2.score(3)])                 % S2                                        
            mean([ClassPredict.C2He.score(3) ClassPredict.C2He2.score(4)])                 % S3                                        
            mean([ClassPredict.C2He.score(4) ClassPredict.C2He2.score(5)])                 % S4                                        
            mean([ClassPredict.C2Ho.score(3) ClassPredict.C2Ho2.score(4)])                 % S5                                        
            mean([ClassPredict.C2Ho.score(4) ClassPredict.C2Ho2.score(5)])                 % S6                                         
            mean([ClassPredict.C2Ho.score(5) ClassPredict.C2Ho2.score(6)])                 % S7                                         
            mean([ClassPredict.C2Ho.score(6) ClassPredict.C2Ho2.score(7)])                 % S8                                         
            mean([ClassPredict.C2Ho.score(7) ClassPredict.C2Ho2.score(8)])                 % S9                                         
            mean([ClassPredict.C2Ho.score(1) ClassPredict.C2Ho2.score(2)])                 % S10                                         
            mean([ClassPredict.C2Ho.score(2) ClassPredict.C2Ho2.score(3)])];               % S11                                        

        % G1: Classification accuracy - agents and G2: Classification accuracy - swarm
        EvalGain = [EvalGain; SimulationTime sum(ClassPredYagent) ((sum(ClassPredYagent)/NumberOfSheep)*100)];
        % Save individual classification performances for later
        MarkerClassPerfAgent.(nameAfterDot) = ClassPredYagent; 
    end

    %% Current Tactic Pair 
    CurrentTacticPair = [convertCharsToStrings(DrivingTacticIndex) convertCharsToStrings(CollectingTacticIndex)]; 
    fprintf('\nCurrent Tactic Pair: {%s %s}.\n',CurrentTacticPair(1),CurrentTacticPair(2))

    %% Determine Next Behaviour Action 

    % Get the right dataset first - subset for metric and classified scenario
    % very simple - select between best TP for Ho or He case only 


    %% Context-Awareness Engine (part of agent 1)
    % 1 - select right metric/scenario sub-set
    % subcube takes the form [5 5 5] = [drive collect result]
    scenario = string(yfit2class); 
    if strcmp("Homogeneous", scenario)
        fprintf('Assessed Scenario is Homogeneous\n')
        subCube = squeeze(datacube(:, :, parameters.intent, 3, :)); 
    elseif strcmp("Heterogeneous", scenario)
        subCube = squeeze(datacube(:, :, parameters.intent, 2, :)); 
        fprintf('Assessed Scenario is Heterogeneous\n')
    else
        subCube = squeeze(datacube(:, :, parameters.intent, 1, :)); 
        fprintf('Assessed Scenario is Default\n')
    end 
    
    %% Behaviour Parameterisation Engine
    % 2 - take test result (1 - "0" for best fit) <-- simply t-test only in this case 
    viableTP = (1 - subCube(:,:,1)) .* subCube(:,:,4);
    [row,col] = find(viableTP == max(max(viableTP)));
    
    % 3 - rank the means H --> L and select the H 
    
    % 4 - save these for selection

    % This is where the ANN classifier goes to determine the TP as an output

    if parameters.TacticPairSelection
        DrivingTacticIndex = char(parameters.TacticDriveReference(col)); % re-parameterise the agent for new collect and drive actions 
        CollectingTacticIndex = char(parameters.TacticCollectReference(row));
        NextTacticPair = [convertCharsToStrings(DrivingTacticIndex) convertCharsToStrings(CollectingTacticIndex)]; 
        if NextTacticPair == CurrentTacticPair 
            fprintf('Continuing with Tactic Pair: {%s %s}.\n', NextTacticPair(1), NextTacticPair(2))
        else 
            fprintf('New Tactic Pair: {%s %s}.\n',NextTacticPair(1),NextTacticPair(2))
        end
    end
    
    %% Output 
    % marker calculation 
    output.MarkerSet = MarkerSet; 
    output.EvalCost = EvalCost; 
    output.SwarmAgentAttnPoints = SwarmAgentAttnPoints; 
    output.InteractionAgentProp = InteractionAgentProp; 
    output.ClassPredict = ClassPredict; 
    
    % onlineclassifications
    if parameters.OnlineClassifications
    output.EvalGain = EvalGain; 
    output.MarkerClassPerfAgent = MarkerClassPerfAgent; 
    output.SwarmClassificationData = SwarmClassificationData; 
    end
    
    % behaviour selection
    if parameters.TacticPairSelection
        output.TacticDrive = DrivingTacticIndex; 
        output.TacticCollect = CollectingTacticIndex; 
    end

end


%% Tasks 

% This is the flow chart as a very simple agent in the first instance

% C1: Agent Classification (Type = 7 class)

% C2: Swarm Classification (Type = binary)

% if Heterogeneous == C2_He 

% if Homogeneous == C2_Ho 

% if number of swarm classification sequences > threshold || swarm 2-class type > XXX threshold

% Query library for optimal set of behaviours 

% Are suitable for intent? 

% Select optimal (based on optimal mean TP now, not just from the available) 

% if predicted sequence of TP > threshold2 (i.e. invariant of selection) 
% change TP 
