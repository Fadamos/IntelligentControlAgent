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
        fprintf('\n')
        yfit = C1.predictFcn(Mrk.M1.ClassDataArray);
        for i = 1:length(yfit)
            if parameters.VerboseBugger
                fprintf('Identified Agent No. %i: %s\n', i, yfit{i})
            end
            ClassPredYagent(i) = (string(yfit(i)) == parameters.SwarmAgentTypeDistribution(i));
        end
        fprintf('\nClassified Agent Distribution:\n')
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
        fprintf('* * * * * Ground Truth Swarm Type: %s\n', parameters.ScenarioIndex)
        
        %% Record performance data here and save it 
        SwarmClassificationData = [SwarmClassificationData; parameters.ScenarioIndex string(yfit2class) string(yfitHe) string(yfitHo) string(yfitHe2) string(yfitHo2)];
        
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


    %% Context-Awareness Engine 
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
    
    %% Behaviour Selection Engine
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
        if ((NextTacticPair(1) == CurrentTacticPair(1)) && (NextTacticPair(1) == CurrentTacticPair(2))) % THIS IS NOT TESTING CORRECTLY, BUT CODE EXECUTES FINE
            fprintf('Continuing with Tactic Pair: {%s %s}.\n',NextTacticPair(1),NextTacticPair(2))
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
