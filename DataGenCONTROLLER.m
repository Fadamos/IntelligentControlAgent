% Author: Adam J Hepworth
% LastModified: 2022-10-28
% Explanaton: simulation control script, enabling scenario, behaviour and
% tactic selection for batch processing. 

% parameters.Adam = true; --> This is now set in DataGenMASTER

%% THIS IS CURRENTLY IN NORMAL MODE

    % system wide test param
    parameters.SET_CLOCK = false;  

    parameters.u=ser = "Adam";
    % Sim params 
    parameters.Verbose = true; % visuals (true) or data only (false)
    parameters.Verbose2 = false; % clock parameterisation consolt reporting
    parameters.VerboseBugger = false; % sys print for increased data debugging
    parameters.visual = "classic"; % 'classic' if using original visuals
    % turn off warnings if not impacting code execution
    warning('off','all')
    warning
    % select either military or classic shepherding visual scenario
    parameters.military = 1; % 0 = classic shepherding; 1+ = military 
    % Context-aware intelligent agent setup
    parameters.NumberOfSheep = 20;
    parameters.NumberOfSteps = (630 + 20 * parameters.NumberOfSheep) * 5;
    % Control agent 
    parameters.CollisionRange = 'L1';
    parameters.SheepDogVehicleSpeedLimit = 'Dog1.5'; %1.5; % If calling this script externally, remove this Scenario selector 
    parameters.DogCollectingTacticIndex = 'F2H'; % strombom 
    parameters.DogDrivingTacticIndex = 'DAH'; % strombom 
    % Markers 
    parameters.OnlineClassifications = 1; % if you want to classify in each time step
    parameters.TacticPairSelection = 1; % 1 = select new tactic pair behaviour and 0 = do not select
    parameters.FullSet = true; 
    parameters.InternalMarkerCalculations = 1; % 1 = observer or 0 = standard simulation
    parameters.InternalMarkerCalculationsVisual = 0; % 1 = additional visuals 4x4 plot; 0 = just the sim visual
    parameters.IntelligentControlAgent = 1; % 1 = intelligent markers agent or 0 = standard simulation 
    parameters.AttentionThreshold = 0.5; % 0.5 = default, else change this. Represents cumsum 
    % Translator 
    parameters.TranslationController = 0; % translation controller (1=true, 0=false)
    parameters.ShowTimeLength = 20; % length of time the explanation is shown on the screen
    parameters.BehaviourLibrary = 0; % 1 = needs to be calcualted else 0 to load a pre-existing data cube

parameters.TimePrinter = 0; % print time out or not

%% Clocks 
% Behaviour re-assessment clock 
parameters.SigmaLength = 1; % 1 = strombom; > 1 = novel 

% Behaviour execution point re-assessment clock
parameters.SigmaPositioningPoint = 1;  % 1 = strombom; > 1 = novel 

% Context-Aware Markers
parameters.WindowSize = 60; % number of observations for each marker window --> 100 = optimal 
parameters.Overlap = 0.75; % = Proportion of overlap between each marker

parameters.TacticDriveReference = {'DAH' 'DHH' 'DOAT' 'DQH' 'DTQH'};
parameters.TacticCollectReference = {'C2D' 'C2H' 'F2D' 'F2G' 'F2H'};


%% Information Marker Calculations
if parameters.IntelligentControlAgent
    % Ensurses that if we use the intelligent decision agent that markers
    % are automatically enabled 
    parameters.InternalMarkerCalculations = 1; 
end
if parameters.InternalMarkerCalculations
    % needs 1 - overlap as it actually calculates the 'remaining' window i.e.the reverse! 
     parameters.Windows = WindowSegments(1:parameters.NumberOfSteps,parameters.WindowSize,(1-parameters.Overlap),0,1); % flag for calculating a new marker set <-- do not chagne
end

%% TranslationController
if parameters.TranslationController
    parameters.CollisionRange = SheepSeparationLibrary(parameters.SheepSheepSeparationIndex);
    parameters.SheepDogVehicleSpeedLimit = DogSpeedLibrary(parameters.DogSpeedDifferentialIndex);
end 

%% Evnrionment Setup
parameters.MinX = 0;
parameters.MaxX = 250;
parameters.MinY = 0;
parameters.MaxY = 250;
parameters.Area = (parameters.MaxX - parameters.MinX)*(parameters.MaxY - parameters.MinY);
parameters.Boundary = [parameters.MinX,parameters.MaxX,parameters.MinY,parameters.MaxY];
parameters.SheepInitialCentreOfMass = [0.5*parameters.MaxX, 0.5*parameters.MaxY];

%% Standard Agent Parameters 
parameters.PauseLength = 0.0;
parameters.ActionCommitTime = 1;
parameters.SheepInitialRadius = 150; %100
parameters.SheepInitialGCMx = parameters.MaxX /4;
parameters.SheepInitialGCMy = parameters.MaxY /4;
parameters.SheepInitialClusters = 1;
parameters.NumberOfShepherds = 1;
parameters.SheepDogInitialOffsetFromSheepLocation = 40;
parameters.MaximumSafetyDistance = 1;

% Sheep Behaviours 
parameters.SheepBehaviorModels = ["A1"    "A2"    "A3"    "A4"    "A5"    "A6"    "A7"]; % sheep behaviour identifiers
parameters.SheepStepSize = [1.5 0.75 1.0 1.0 1.0 0.75 1.0]; % s_pi
parameters.CollisionRange = 'L1';

% Sheepdog Behaviour 
parameters.SheepDogVehicleSpeedLimit = 'Dog1.5'; %1.5; % If calling this script externally, remove this Scenario selector 
parameters.DrivingCollectingPointsSafetyDistance = 5;
% parameters.SheepDogVehicleSpeedLimit = 1.5; % s_beta **this is now automated selection

% Common Ranges
% parameters.CollisionRange = 4; %2; % 0.4; %MaxX / 40.0; **this is now automated selection
parameters.CohesionRange = 2 * parameters.NumberOfSheep.^(2/3); % the 2* is consistent with Strombom as they didnt change the collision range: parameters.CollisionRange * parameters.NumberOfSheep.^(2/3); 
parameters.AlignmentRange = 0.6 * parameters.NumberOfSheep; %parameters.MaxX / 10.0;
parameters.InfluenceRange = 65; % parameters.MaxX / 10.0; 
parameters.SheepRadius = 2; % r_a 
parameters.Ranges = [parameters.CohesionRange,parameters.AlignmentRange,parameters.InfluenceRange,parameters.SheepRadius];

% DOAT Handling 
parameters.TargetForDOAT = nan;

% Common Weights
parameters.WeightAlignment = 0.1; % 0.0; 
parameters.WeightOfInertia = 0.5; 

% Goal Weights
parameters.GoalX = 15;
parameters.GoalY = 15;
parameters.GoalRadius = 15; %round(sqrt(parameters.NumberOfSheep),0);
parameters.Goal = [parameters.GoalX,parameters.GoalY];

% Sheep Weights - order is A1, A2, A3, A4, A5, A6, A7
parameters.WeightCohesion       = [0.50 1.50 0.50 0.50 1.05 1.05 1.05]; % W_pi_Lambda
parameters.WeightCollision      = [2.00 2.00 3.00 2.00 3.00 1.50 2.00]; % W_pi_pi 
parameters.InfluenceOfDogWeight = [0.50 0.50 1.00 1.90 1.00 1.00 1.00]; % W_pi_beta

%% Scenario Generation 
% used for custom scenario generation with ScenarioIndex 'S0'
parameters.usr = [0    0    1    0    0    0    0]; % all values must = 1; see ScenarioLibrary for examples

parameters.Scenario = ScenarioLibrary(parameters,parameters.ScenarioIndex);

if parameters.InternalMarkerCalculations
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/C1.mat')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/C2.mat')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/C2_He.mat')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/C2_Ho.mat')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/C2_He2.mat')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/C2_Ho2.mat')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/CLOCK_2_regmdl.mat')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/CLOCK_3_regmdl.mat')
end

if parameters.BehaviourLibrary
    fprintf('Loading behaviour data...\n')
    load('/Users/ajh/GitHub/IntelligentControlAgent/SimData/df.mat')
    fprintf('Building behaviour library...\n')
    datacube = BuildBehaviourLibrary(df);
    fprintf('Complete...\n\n\n')
else
    fprintf('Loading behaviour library...\n')
    load('/Users/ajh/GitHub/IntelligentControlAgent/import/datacube.mat')
    fprintf('Complete...\n\n\n')
end

%% Main Function Call
if parameters.InternalMarkerCalculations
     output = SheepMasterWHOLEGroups(parameters, C1, C2, C2_He, C2_Ho, C2_He2, C2_Ho2, datacube, CLOCK_2_regmdl, CLOCK_3_regmdl);
 else
     output = SheepMasterWHOLEGroups(parameters);
 end