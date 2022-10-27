function output = IntelligentMarkerControl(Verbose, SensedData, parameters, SimulationTime, C1, C2, C2_He, C2_Ho, C2_He2, C2_Ho2, datacube, NumberOfSheep, FullSet, EvalCost, EvalGain, SwarmAgentAttnPoints, InteractionAgentProp, SwarmClassificationData, DrivingTacticIndex, CollectingTacticIndex, CLOCK_2_regmdl, CLOCK_3_regmdl, ProbMat, PredClassScore)
    % Author: Adam J Hepworth
    % LastModified: 2022-10-24
    % Explanaton: Intelligent control agent

    if parameters.SET_CLOCK
        output.TacticDrive = parameters.DogDrivingTacticIndex; 
        output.TacticCollect = parameters.DogCollectingTacticIndex; 
        return
    end
    
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
        
        scenario_agent = sum(yfitSCORE)/length(yfit);

        %% Classifier: Swarm Characteristics
        [yfit2class, yfit2classSCORE] = C2.predictFcn(Mrk.M3.L2norm);
        [yfitHe, yfitHeSCORE]  = C2_He.predictFcn(Mrk.M3.L2norm); 
        [yfitHo, yfitHoSCORE] = C2_Ho.predictFcn(Mrk.M3.L2norm); 
        [yfitHe2, yfitHe2SCORE] = C2_He2.predictFcn(Mrk.M3.L2norm); 
        [yfitHo2, yfitHo2SCORE] = C2_Ho2.predictFcn(Mrk.M3.L2norm);  
        
         if parameters.VerboseBugger
            fprintf('Identified Swarm Type (Tree Classifier    C2        {Homogeneous Heterogeneous})                      = %s Pr(%.2f) \n', string(yfit2class), max(yfit2classSCORE))
            fprintf('Identified Swarm Type (Tree Classifier    C2_He     {S1, S2, S3, S4})                                 = %s Pr(%.2f) \n', string(yfitHe), max(yfitHeSCORE))
            fprintf('Identified Swarm Type (Tree Classifier    C2_Ho     {S5, S6, S7, S8, S9, S10, S11})                   = %s Pr(%.2f) \n', string(yfitHo), max(yfitHoSCORE))
            fprintf('Identified Swarm Type (FF ANN Classifier  C2_He2    {S1, S2, S3, S4, Homogeneous})                    = %s Pr(%.2f) \n', string(yfitHe2), max(yfitHe2SCORE))
            fprintf('Identified Swarm Type (Tree Classifier    C2_Ho2    {S5, S6, S7, S8, S9, S10, S11, Heterogeneous})    = %s Pr(%.2f) \n', string(yfitHo2), max(yfitHo2SCORE))
            fprintf('\n* * * * * Ground Truth Swarm Type: %s\n', parameters.ScenarioIndex)
        end 
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

        % G1: Classification accuracy - agents and G2: Classification accuracy - swarm
        EvalGain = [EvalGain; SimulationTime sum(ClassPredYagent) ((sum(ClassPredYagent)/NumberOfSheep)*100)];
        % Save individual classification performances for later
        MarkerClassPerfAgent.(nameAfterDot) = ClassPredYagent; 

        %[~,ScenarioIdx] = max(ClassPredict.score(3:end)); 
    end

    %% Current Tactic Pair 
    CurrentTacticPair = [convertCharsToStrings(DrivingTacticIndex) convertCharsToStrings(CollectingTacticIndex)]; 
    fprintf('\nCurrent Tactic Pair: {%s %s}.\n',CurrentTacticPair(1),CurrentTacticPair(2))

    % Scenario 
    scenario_library = ScenarioLibrary(parameters, 'FULL_LIB');
    AgentDecision = DecisionModel(parameters, datacube, ProbMat, ClassPredict, yfit2class, yfit2classSCORE, CurrentTacticPair, scenario_agent, scenario_library); 
    PredClassScore = [PredClassScore; AgentDecision.score'];

    row = AgentDecision.row;
    col = AgentDecision.col;
    
    %% Behaviour Parameterisation Engine
    if parameters.TacticPairSelection
        DrivingTacticIndex = char(parameters.TacticDriveReference(col)); % re-parameterise the agent for new collect and drive actions 
        CollectingTacticIndex = char(parameters.TacticCollectReference(row));
        NextTacticPair = [convertCharsToStrings(DrivingTacticIndex) convertCharsToStrings(CollectingTacticIndex)]; 
        if NextTacticPair == CurrentTacticPair 
            fprintf('Continuing with Tactic Pair: {%s %s}.\n',NextTacticPair(1),NextTacticPair(2))
        else 
            fprintf('New Tactic Pair: {%s %s}.\n',NextTacticPair(1),NextTacticPair(2))
        end
    end

    %% Determine Clock Frequency
    
    CLOCK_2_xnew = table(append("S",num2str(AgentDecision.scenario)), NextTacticPair(1), NextTacticPair(2)); 
    CLOCK_2 = predict(CLOCK_2_regmdl, CLOCK_2_xnew);
    CLOCK_2 = round(CLOCK_2);

    CLOCK_3_xnew = table(append("S",num2str(AgentDecision.scenario)), NextTacticPair(1), NextTacticPair(2));
    CLOCK_3 = predict(CLOCK_3_regmdl, CLOCK_3_xnew);
    CLOCK_3 = round(CLOCK_3);

    fprintf('Clock frequencies: Clock 2 = %.2f and Clock 3 = %.2f\n',CLOCK_2,CLOCK_3)    
    
    %% Output 
    % marker calculation 
    output.MarkerSet = MarkerSet; 
    output.EvalCost = EvalCost; 
    output.SwarmAgentAttnPoints = SwarmAgentAttnPoints; 
    output.InteractionAgentProp = InteractionAgentProp; 
    output.ClassPredict = ClassPredict; 
    output.Clock2 = CLOCK_2;
    output.Clock3 = CLOCK_3; 
    output.ProbMat = AgentDecision.ProbMat; 
    
    % onlineclassifications
    if parameters.OnlineClassifications
        output.EvalGain = EvalGain; 
        output.MarkerClassPerfAgent = MarkerClassPerfAgent; 
        output.SwarmClassificationData = SwarmClassificationData; 
        output.DecisionModel = AgentDecision; 
        output.PredClassScore = PredClassScore; 
        output.row = row; 
        output.col = col; 
        output.NextTacticPair = NextTacticPair; 
    end
    
    % behaviour selection
    if parameters.TacticPairSelection
        output.TacticDrive = DrivingTacticIndex; 
        output.TacticCollect = CollectingTacticIndex; 
    end

end
%