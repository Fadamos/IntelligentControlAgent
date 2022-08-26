function output = ExternalObserver(df, parameters, DecisionWindow, FullSet, Verbose)
    % Author: Adam J Hepworth
    % LastModified: 2022-08-10
    % Explanaton: External observer, kappa

    if ~exist('Verbose', 'var')
        Verbose=false; 
    end
    if ~exist('FullSet', 'var')
        FullSet=false; 
    end 

    % create matlab table 
    DataTable = table(df.t', df.GoalX', df.GoalY', df.NumberOfSheep', [df.SheepDogX', df.SheepDogY'], df.SheepX, df.SheepY);
    DataTable = renamevars(DataTable, ["Var1","Var2","Var3","Var4","Var5","Var6","Var7"],["t","GoalX","GoalY","NumSheep","SheepDogXY","SheepX","SheepY"]);
    
    if Verbose
        fprintf('Table size = [%i, %i]\n', size(DataTable,1), size(DataTable,2))
    end
    
    % save pre-processed files
    df.DataTable = DataTable; 
        
    df.InputData = df; % save all input data
    
    parameters.MarkerSetup.MaxNumAgents = max(df.DataTable.NumSheep);
    if FullSet
        parameters.MarkerSetup.NumMarkers = 42;
    else
        parameters.MarkerSetup.NumMarkers = 23;
    end
    % Generate Marker State Data 
    MarkerState = nan(parameters.MarkerSetup.NumMarkers,parameters.MarkerSetup.MaxNumAgents); % pre-allocate memory  
    
    if Verbose 
        figure(1); clf; 
        title('MarkerState')
        contourf(MarkerState)
        ylabel('Markers')
        xlabel('Swarm Agents') 
        set(gca,'FontSize',14);
        hold on; 
    end
    
    %% Marker State Calculations
    if Verbose 
        fprintf('MarkerState = [%i, %i]\n', size(MarkerState,1), size(MarkerState,2));    
        fprintf('- * - * - * - * - * - * - * - * - * - *\n')
        fprintf('Observation Range = [%i, %i]\n', DecisionWindow(1), DecisionWindow(2)) 
    end
    tic;
    MarkerState = CalculateMarkers(df.DataTable(DecisionWindow(1):DecisionWindow(2),:),FullSet);
    t = toc;
    if Verbose 
        LoopPlot = normalize(MarkerState,2,'range');
        contourf(LoopPlot) % normalise all values in 0,1 for the plot
        pause(0.01)
    end
    if Verbose
        fprintf('Compute time = %f seconds\n', t)
        fprintf('complete.\n')
        fprintf('- * - * - * - * - * - * - * - * - * - *\n')
    end
    df.ComputeTime(DecisionWindow) = t; 
    
    
    %% M1 - agent stationary 
    % Classification Pre-Processing
    X = MarkerState'; 
    Tbl = array2table(X); 
    
    %% M3 - swarm - stationary 

    %% M2 - agent non-stationary and M4 - swarm - non-stationary
    if parameters.AttentionThreshold
        M2 = NonStationaryTraits(MarkerState, parameters.AttentionThreshold); 
    else 
        M2 = NonStationaryTraits(MarkerState); 
    end
    
    output.MarkerState = MarkerState;
    output.M1.ClassData = Tbl; 
    output.M1.ComputeTime = t; 
    output.M1.ObsRange = [DecisionWindow(1) DecisionWindow(2)];
    output.M2.InteractionAgent = M2.InteractionAgent;
    output.M2.InteractionFraction = M2.InteractionFraction; 
    %output.M3. = ;
    output.M4.AttentionAgentIdx = M2.AttentionAgentIdx;
    output.M4.AttentionPoints = M2.AttentionPoints;
end 
