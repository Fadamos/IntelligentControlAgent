function output = IntelligentMarkerControl(Verbose, SensedData, parameters, SimulationTime, C1, C2, C2_He, C2_Ho, C2_He2, C2_Ho2, Ranges, RadiusSheep, NumSheepNeighbours, RadiusShepherd, NumberOfTimeSteps, Goal, GoalRadius, BoundarySize, NumberOfSheep, CohesionRange, SheepInitialRadius, SheepInitialGCMx, SheepInitialGCMy, NumberOfInitialClusters, NumberOfShepherds, ShepherdStep, MaximumSafetyDistance, DrivingCollectingPointsSafetyDistance, SheepDogInitialOffsetFromSheepLocation, PauseLength, ScenarioIndex, Scenario, SimulationRuns, ActionCommitmentTime, TargetForDOAT, FlagDOAT, FullSet, TranslationController, EvalCost, EvalGain, SwarmAgentAttnPoints, InteractionAgentProp, SwarmClassificationData, DogSpeedDifferentialIndex, CollectingTacticIndex, DrivingTacticIndex, CollisionRangeIndex)
    % Author: Adam J Hepworth
    % LastModified: 2022-09-26
    % Explanaton: Intelligent control agent
    
    if ~exist('intent', 'var')
        paramters.intent = 1; % mission success  
    end
    if ~exist('behaviourLibrary', 'var')
        parameters.behaviourLibrary = -1; % this needs to be the default TP eventually 
    end
    
    %% External Observer Agent
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
    if Verbose
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
        yfit = C1.predictFcn(Mrk.M1.ClassDataArray);
        for i = 1:length(yfit)
            if parameters.VerboseBugger
                fprintf('Identified Agent No. %i: %s\n', i, yfit{i})
            end
            ClassPredYagent(i) = (string(yfit(i)) == parameters.SwarmAgentTypeDistribution(i));
        end
        fprintf('Classified Agent Distribution:\n')
        summary(categorical(string(cell2mat(yfit))))
        
        
        %% Classifier: Swarm Characteristics
        yfit2class = C2.predictFcn(Mrk.M3.L2norm);
        if string(yfit2class) == "Heterogeneous" 
            yfitHe = C2_He.predictFcn(Mrk.M3.L2norm); 
            yfitHo = "NaN";
        elseif string(yfit2class) == "Homogeneous" 
            yfitHo = C2_Ho.predictFcn(Mrk.M3.L2norm); 
            yfitHe = "NaN";
        end
        yfitHe2 = C2_He2.predictFcn(Mrk.M3.L2norm); 
        yfitHo2 = C2_Ho2.predictFcn(Mrk.M3.L2norm);  
        
        fprintf('Identified Swarm Type (Classifier C2): %s\n', string(yfit2class))
        fprintf('Identified Swarm Type (Classifier C2_He): %s\n', string(yfitHe))
        fprintf('Identified Swarm Type (Classifier C2_Ho): %s\n', string(yfitHo))
        fprintf('Identified Swarm Type (Classifier C2_He2): %s\n', string(yfitHe2))
        fprintf('Identified Swarm Type (Classifier C2_Ho2): %s\n', string(yfitHo2))
        fprintf('Ground Truth Swarm Type: %s\n\n\n\n\n', parameters.ScenarioIndex)
        
        %% Record performance data here and save it 
        SwarmClassificationData = [SwarmClassificationData; parameters.ScenarioIndex string(yfit2class) string(yfitHe) string(yfitHo) string(yfitHe2) string(yfitHo2)];
        
        % G1: Classification accuracy - agents and G2: Classification accuracy - swarm
        EvalGain = [EvalGain; SimulationTime sum(ClassPredYagent) ((sum(ClassPredYagent)/NumberOfSheep)*100)];
        % Save individual classification performances for later
        MarkerClassPerfAgent.(nameAfterDot) = ClassPredYagent; 
    end
    
    %% Output 
    % marker calculation 
    output.MarkerSet = MarkerSet; 
    output.EvalCost = EvalCost; 
    output.SwarmAgentAttnPoints = SwarmAgentAttnPoints; 
    output.InteractionAgentProp = InteractionAgentProp; 
    
    % onlineclassifications
    if parameters.OnlineClassifications
    output.EvalGain = EvalGain; 
    output.MarkerClassPerfAgent = MarkerClassPerfAgent; 
    output.SwarmClassificationData = SwarmClassificationData; 
    end
    
    % behaviour selection
    if parameters.TacticPairSelection
        output.TacticPair = TP; 
    end

end


%% Tasks 

% 1- 4D behaviour array to select the behaviour (don't parameterise yet - just print it out) 







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
