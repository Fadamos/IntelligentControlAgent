function output = SheepMasterWHOLEGroups(parameters, C1, C2, C2_He, C2_Ho, C2_He2, C2_Ho2, datacube, CLOCK_2_regmdl, CLOCK_3_regmdl)

% Author: Adam J Hepworth, Daniel P Baxter 
% LastModified: 2022-10-24
% Explanaton: simulation control script, enabling scenario, behaviour and
% tactic selection. These can be static for the length of the simulation or
% dynamic.

%% Restructured & updated sheep algorithm.
% Sheep-dog system. Some sheep are grazing in a field, a dog wants to round
% then up att drive them to a pen at (0,0). The sheep follow an
% attraction-repulsion model (attracted and repelled (due to size) from each
% other and the repelled from the dog). The dog follow a simple algorithm:
% If the group of sheep is cohesive enough it positions itself to drive the
% flock, else position itself to drive the furthest sheep toward the global
% center of mass of the flock of sheep.

%% INPUTS
% Parameters        = the parameters set in RecognitionController

%% OUTPUTS
% Output.Data       = the data structs required for analysis

if ~exist('C1', 'var')
     C1=false; 
end
if ~exist('C2', 'var')
     C2=false; 
end
if ~exist('C2_He', 'var')
     C2_He=false; 
end
if ~exist('C2_Ho', 'var')
     C2_Ho=false; 
end
if ~exist('C2_He2', 'var')
     C2_He2=false; 
end
if ~exist('C2_Ho2', 'var')
     C2_Ho2=false; 
end
if ~exist('CLOCK_2_regmdl', 'var')
     CLOCK_2_regmdl=false; 
end
if ~exist('CLOCK_3_regmdl', 'var')
     CLOCK_3_regmdl=false; 
end

%% Initialise Simulation Parameters
Verbose                                 = parameters.Verbose;
parameters.BreakWhile                   = false; % break from simulation loop

Ranges                                  = parameters.Ranges;
RadiusSheep                             = Ranges(4);
NumSheepNeighbours                      = Ranges(2);
RadiusShepherd                          = Ranges(3);
NumberOfTimeSteps                       = parameters.NumberOfSteps;
Goal                                    = parameters.Goal;
GoalRadius                              = parameters.GoalRadius;
BoundarySize                            = parameters.Boundary;
NumberOfSheep                           = parameters.NumberOfSheep;
CohesionRange                           = Ranges(1);
SheepInitialRadius                      = parameters.SheepInitialRadius;
SheepInitialGCMx                        = parameters.SheepInitialGCMx;
SheepInitialGCMy                        = parameters.SheepInitialGCMy;
NumberOfInitialClusters                 = parameters.SheepInitialClusters;
NumberOfShepherds                       = parameters.NumberOfShepherds; % need this here to build results matrix below
ShepherdStep                            = parameters.SheepDogVehicleSpeedLimit;
MaximumSafetyDistance                   = parameters.MaximumSafetyDistance;
DrivingCollectingPointsSafetyDistance   = parameters.DrivingCollectingPointsSafetyDistance;
SheepDogInitialOffsetFromSheepLocation  = parameters.SheepDogInitialOffsetFromSheepLocation;
PauseLength                             = parameters.PauseLength; 
ScenarioIndex                           = parameters.ScenarioIndex;
Scenario                                = parameters.Scenario;
SimulationRuns                          = parameters.Replicate;
%ActionCommitmentTime                    = parameters.ActionCommitTime;
TargetForDOAT                           = parameters.TargetForDOAT; % collection of agent IDs 
FlagDOAT                                = 0; % boolean flag for agent at goal or not
FullSet                                 = parameters.FullSet; % Complete marker set or not 
TranslationController                   = parameters.TranslationController; % condition for explanation print on visuals
EvalCost                                = []; % Information Markers Value of Information  - Cost
EvalGain                                = []; % Information Markers Value of Information  - Gain 
SwarmAgentAttnPoints                    = []; % plotting attention points for agents
InteractionAgentProp                    = []; % plotting for agent interaction values 
SwarmClassificationData                 = []; % swarm classification data
BehaviourProportions                    = []; % running total of behaviour proportions 
ClockTimesDist                          = [parameters.SigmaLength parameters.SigmaPositioningPoint];

%% Get the selection of complexity parameters
DogSpeedDifferentialIndex               = parameters.SheepDogVehicleSpeedLimit;
CollectingTacticIndex                   = parameters.DogCollectingTacticIndex;
DrivingTacticIndex                      = parameters.DogDrivingTacticIndex;
CollisionRangeIndex                     = parameters.CollisionRange;

TacticPairRecord                        = {DrivingTacticIndex CollectingTacticIndex}; % record the tactic pair for each time step

Flags                                   = []; 
FlagSigma                               = 0; 
FlagSigmaLength                         = 0; 
FlagSigma1                              = 0; 
FlagSigma2                              = 0; 
FlagSigma1pos                           = 0; 
FlagSigma2pos                           = 0; 

% Decision Model 
ProbMat                                 = []; % probability matrix for scenario classifications
PredClassScore                          = []; 
ScenarioClassFreq                       = zeros(1,11); % count of each scenario type identified
SwarmAttnPoints                         = zeros(1,NumberOfSheep); % swarm attention point counter
MeanVarDist                             = []; % Mean-Var scores
ScenarioProbMat                         = [];

%% Assign the environment boundaries
MinX = BoundarySize(1);
MaxX = BoundarySize(2);
MinY = BoundarySize(3);
MaxY = BoundarySize(4);

%% Plot Images Setup
if parameters.military == 1
% military scenario - F35/Ghost Bat
    if parameters.visual == "classic"
        [DogImg,DogM] = imread('core_sim/f35.png');
        DogImg = imresize(DogImg,1);
        DogImgSize = [7.64,11]; 
    elseif parameters.visual == "flipped"
        [DogImg,~,DogM] = imread('core_sim/f35.png');
        DogImg = imresize(DogImg,[7.64, 11], 'lanczos3');
        DogM = imresize(DogM,[7.64, 11], 'lanczos3');
    end
    
    [SheepImg,SheepM] = imread('core_sim/ghostbat.png');
    SheepImg = imresize(SheepImg,1);
    SheepImgSize = [4.8,5.96]; 
elseif parameters.military == 2
    % military scenario - Apache/M1A1
    [DogImg,DogM] = imread('core_sim/apache.png');
    DogImg = imresize(DogImg,1);
    DogImgSize = [11.68,15.9]; 
    
    [SheepImg,SheepM] = imread('core_sim/m1a1.png');
    SheepImg = imresize(SheepImg,1);
    SheepImgSize = [4.01,10.61]; 
else 
    % classic shepherding 
    [DogImg,DogM] = imread('core_sim/Dog.png');
    DogImg = imresize(DogImg,1);
    DogImgSize = [10,10]; 
    
    [SheepImg,SheepM] = imread('core_sim/sheep.png');
    SheepImg = imresize(SheepImg,1);
    SheepImgSize = [7,7]; 
    
    [paddock,paddockM] = imread('paddock.JPG'); 
    if paramters.visual == "classic"
        paddock = imresize(paddock,1); 
        paddockSized = image([MinX MaxX],[MinY MaxY],paddock); 
    elseif parameters.visuual == "flipped"
        paddock1 = imresize(paddock,1);
        paddockSized = image([MinX MaxX],[MinY MaxY],paddock); 
        % Flip the y-aixs to maintain origin at [0 0]
        paddock = flipud(paddock1);
    end
end 

%% Initialise Sheep in the top right quarter of the paddock
load('TestingSeedsX.mat')
load('TestingSeedsY.mat')
load('TestingSeedsDirection.mat')

%% Initialise Scenario 
if ~parameters.IsolatedSim 
    fprintf('Simulation batch run %i of %i\n', parameters.BatchCurrentRun, parameters.BatchTotalRuns)
end 
fprintf('Init simulation with Scenario = %s; Replicate = %i of %i\n', ScenarioIndex,SimulationRuns,parameters.replicates)
fprintf('Collect = %s; Drive = %s\n', CollectingTacticIndex, DrivingTacticIndex)
fprintf('CLOCK_1 = %i; CLOCK_2 = %i; CLOCK_3 = %i\n', parameters.WindowSize, parameters.SigmaLength, parameters.SigmaPositioningPoint)
if parameters.InternalMarkerCalculations
    fprintf('Marker Obs Size = %i; Marker Overlap = %.2f\n',parameters.WindowSize,parameters.Overlap)
end
fprintf('.....Proportion of Agent A1 = %.2f; A2 = %.2f; A3 = %.2f; A4 = %.2f; A5 = %.2f; A6 = %.2f; A7 = %.2f\n', Scenario(1), Scenario(2), Scenario(3), Scenario(4), Scenario(5) ,Scenario(6) ,Scenario(7))


%% Create initial population of sheep
SheepMatrix = zeros(NumberOfSheep,8);
% columns: 1 - x pos, 2 - y pos, 3 - direction, 4 - seen a shepherd ,
% 5 - index, 6 - is sheep in goal, 7 - cluster number, 8 - individual action

%% Create initial population of shepherds
ShepherdMatrix = zeros(NumberOfShepherds,6);
%columns: 1 - x pos, 2 - y pos, 3 - direction, 4 - target sheep ID,
% 5 - index, 6 - individual action,

%% Initialise variables used for results calculations
SimulationTime              = 1;                         % Simulation run time
AllSheepWithinGoal          = 0;                         % Sheep within distance to target; 0-no, 1-yes
SheepLCMHeading             = 0; % "unknown";            % initialise to 0 so it can calc post t>1 

%% State-space flag to print translation on the GUI
explanationFlag = false;
showTime = 0;


%% If the translation controller is set for an explanation - add path for python
if TranslationController == 1
    P = py.sys.path;
    if count(P,'C:\Users\danie\PycharmProjects\Onto4MAT-DB-dev') == 0
        insert(P,int32(0),'C:\Users\danie\PycharmProjects\Onto4MAT-DB-dev');
    end
    if count(P,'C:\Users\danie\PycharmProjects\venv\Onto4MAT-DB-dev') == 0
        insert(P,int32(0),'C:\Users\danie\PycharmProjects\venv\Onto4MAT-DB-dev');
    end
end


%% Create the circular radius around the center GCM for the outter cluster LCMs
CenterPositionForGCMOfClusters  = [MaxX/1.5 MaxY/1.5];
RadiusForLCMClusters            = ((MaxX + MaxY) /2) /2;
LCMClusterLocations             = zeros(2,NumberOfInitialClusters);
LCMClusterAngles                = linspace(0,2*pi,NumberOfInitialClusters+1);
for n = 1 : NumberOfInitialClusters
    LCMClusterLocations(:,n) = [cos(LCMClusterAngles(1,n)) * RadiusForLCMClusters + CenterPositionForGCMOfClusters(1,1); ...
        sin(LCMClusterAngles(1,n)) * RadiusForLCMClusters + CenterPositionForGCMOfClusters(1,2)];
end

%% Initiate the group dispersed over the whole paddock
for i = 1 : NumberOfSheep
    SheepMatrix(i,1) = SheepInitialGCMx + TestingSeedsX(SimulationRuns,i) * SheepInitialRadius;%MaxX; % LHS denominator changes density (greater number more dense) RHS denominator changes position on paddock
    SheepMatrix(i,2) = SheepInitialGCMy + TestingSeedsY(SimulationRuns,i) * SheepInitialRadius;%MaxY; % LHS denominator changes density (greater number more dense) RHS denominator changes position on paddock
    SheepMatrix(i,3) = TestingSeedsDirection(SimulationRuns,i) * 2*pi-pi; % TestingSeedsDirection(z)*2*pi-pi;  % rand*2*pi-pi; % Initiates directional angle [-pi,pi].
    SheepMatrix(i,4) = 0; % Seen shepherd or not
    SheepMatrix(i,5) = i; % Index of the sheep ID
    SheepMatrix(i,6) = 0; % 1 if sheep is within the goal, 0 if not
    SheepMatrix(i,7) = 0; % not apart of a cluster
    SheepMatrix(i,8) = 0; % Individual Action
end

%% Initialise the initial position of the shepherds
% Initial shepherd coordinates into an oplique line between the target and
% the sheep GCM
for h = 1 : NumberOfShepherds
    ShepherdMatrix(h,1) = 0; % x position
    ShepherdMatrix(h,2) = MaxY/NumberOfShepherds*h; % y position
    ShepherdMatrix(h,3) = rand*3*pi-pi; % Initiates directional angle [-pi,pi]. **Generates rand directional angle
    ShepherdMatrix(h,4) = 0; % currently un-used
    ShepherdMatrix(h,5) = h; % index of the Shepherd ID
end

%% DOAT Pre-Calculations
% calculate target before entering simulation loop here 
SheepNotInGoalIndex = find(SheepMatrix(:,6)==0); 
SheepNotInGoalNumber = size(SheepNotInGoalIndex);
SheepNotInGoalGCM(SimulationTime,:) = [mean(SheepMatrix(SheepNotInGoalIndex(:),1)) mean(SheepMatrix(SheepNotInGoalIndex(:),2))];
SheepIndexInBiggestCluster = SheepNotInGoalIndex; 
NumberOfSheepInCluster = size(SheepIndexInBiggestCluster(:,1));
BiggestClusterLCM(SimulationTime,:) = [mean(SheepMatrix(SheepIndexInBiggestCluster(:),1)),mean(SheepMatrix(SheepIndexInBiggestCluster(:),2))];
ShepherdMatrix = ShepherdCollect(SheepMatrix,ShepherdMatrix,Goal, ...
    RadiusSheep,RadiusShepherd,DogSpeedDifferentialIndex,CollectingTacticIndex, ...
    CohesionRange,SimulationTime,DrivingTacticIndex,BoundarySize,SheepIndexInBiggestCluster, ...
    NumberOfSheepInCluster,BiggestClusterLCM(SimulationTime,:),SheepNotInGoalIndex,SheepNotInGoalNumber, ...
    SheepNotInGoalGCM(SimulationTime,:));
% Use this when want to convert shepherd heading from deg to compass 
% ShepherdDirection = CompassHeadings(ShepherdMatrix(3));
ShepherdIndividualBehaviour = 2; % "Collecting";
if ShepherdMatrix(:,6) == 0
    ShepherdsIndividualAction = "Standing";
elseif ShepherdMatrix(:,6) == 1
    ShepherdsIndividualAction = "Running";
end
SwarmState = 2; % "Dispersed";
TargetForDOAT = ShepherdMatrix(4); % ID of the agent found in the simulation

%% Heterogeneous Sheep 
% build vector of swarm agent types 
parameters.SwarmAgentTypeDistribution = generateSwarm(parameters.NumberOfSheep,parameters.SheepBehaviorModels,parameters.Scenario);
% select behaviour case for swarm agent i
parameters.SheepBehaviourCase = char(parameters.SwarmAgentTypeDistribution(i));

if parameters.TimePrinter
    fprintf('\n\nSimulation Time = \n')
end
while AllSheepWithinGoal == 0 && SimulationTime < NumberOfTimeSteps

    if parameters.TimePrinter
        %% Console time counter! 
        if SimulationTime > 1 
            for BackSpace = 0:log10(SimulationTime-1)
                fprintf('\b'); % delete previous count 
            end
        end
        fprintf('%d',SimulationTime)
    end

        if SimulationTime > 1
            TacticPairRecord(end+1,:) = {DrivingTacticIndex CollectingTacticIndex}; % record the tactic pair for each time step
        end

        %% Calculate the number of sheep NOT in the goal area
        SheepNotInGoalIndex = find(SheepMatrix(:,6)==0); 
        SheepNotInGoalNumber = size(SheepNotInGoalIndex);
        SheepNotInGoalGCM(SimulationTime,:) = [mean(SheepMatrix(SheepNotInGoalIndex(:),1)) mean(SheepMatrix(SheepNotInGoalIndex(:),2))];
                
        %% Calculate the minimum percentage of sheep to drive - determined by Driving Tactic
        DrivingTacticCalcs = DrivingTactic(DrivingTacticIndex);
        MinPercentageToDrive = DrivingTacticCalcs(1);
        DrivingTacticNumber = DrivingTacticCalcs(2);
    
        %% Drive at least the minimum percentage of sheep 
        % calculate the minimum sheep required to form cluster
        MinimumClusterSize = ceil(MinPercentageToDrive * SheepNotInGoalNumber(1));
        % find the IDs of the sheep in the biggest cluster within the environment 
        
        if DrivingTacticIndex == "DOAT" && ~FlagDOAT % DOAT case 
            % Set the cluster to the 
            SheepIndexInBiggestCluster = TargetForDOAT;
            FlagDOAT = false; % we want to ensure the flag is set to zero here after an agent is released
        elseif DrivingTacticIndex == "DOAT" && FlagDOAT % DOAT case to set a new agent after one agent is at the goal 
            NumberOfSheepInCluster = size(SheepIndexInBiggestCluster(:,1));
            BiggestClusterLCM(SimulationTime,:) = [mean(SheepMatrix(SheepIndexInBiggestCluster(:),1)),mean(SheepMatrix(SheepIndexInBiggestCluster(:),2))];
            ShepherdMatrix = ShepherdCollect(SheepMatrix,ShepherdMatrix,Goal, ...
                RadiusSheep,RadiusShepherd,DogSpeedDifferentialIndex,CollectingTacticIndex, ...
                CohesionRange,SimulationTime,DrivingTacticIndex,BoundarySize,SheepIndexInBiggestCluster, ...
                NumberOfSheepInCluster,BiggestClusterLCM(SimulationTime,:),SheepNotInGoalIndex,SheepNotInGoalNumber, ...
                SheepNotInGoalGCM(SimulationTime,:));
            % Use this when want to convert shepherd heading from deg to compass 
            % ShepherdDirection = CompassHeadings(ShepherdMatrix(3));
            ShepherdIndividualBehaviour = 2; % "Collecting";
            if ShepherdMatrix(:,6) == 0
                ShepherdsIndividualAction = "Standing";
            elseif ShepherdMatrix(:,6) == 1
                ShepherdsIndividualAction = "Running";
            end
            SwarmState = 2; % "Dispersed";
            TargetForDOAT = ShepherdMatrix(4); % ID of the agent found in the simulation
            FlagDOAT = false; 
        elseif SheepNotInGoalNumber < 2 % boundary case for end of simulation
            % Error Handling: if NumAgents < 2 then k-means will not execute
            SheepIndexInBiggestCluster = SheepNotInGoalIndex; 
        else
            % Base Case: k-means cluster calculation
            SheepIndexInBiggestCluster = FindBiggestCluster(SheepMatrix,SheepNotInGoalIndex,SheepNotInGoalNumber(1),CohesionRange);
        end
        % calculate the size of the biggest cluster (the number of sheep in it)
        NumberOfSheepInCluster = size(SheepIndexInBiggestCluster(:,1));
        % calculate the number of sheep separated from the biggest cluster 
        NumberOfSheepSeparated = SheepNotInGoalNumber - NumberOfSheepInCluster;

        %% Select the action
            BiggestClusterLCM(SimulationTime,:) = [mean(SheepMatrix(SheepIndexInBiggestCluster(:),1)),mean(SheepMatrix(SheepIndexInBiggestCluster(:),2))];
            if FlagSigma % continue behaviour or calculate a new one 
                if FlagSigma1 > SimulationTime % if drive
                    if FlagSigma1pos > SimulationTime % continue with current P_\beta
                        ShepherdMatrix = ShepherdDrive(DriveSheepMatrix,ShepherdMatrix,Goal,...
                            DriveRadiusSheep,DriveRadiusShepherd,DogSpeedDifferentialIndex,DriveCollectingTacticIndex,...
                            DriveCohesionRange,SimulationTime,DriveDrivingTacticIndex,BoundarySize,DriveSheepIndexInBiggestCluster,...
                            DriveNumberOfSheepInCluster,DriveBiggestClusterLCM);
                    else % new P_\beta
                        ShepherdMatrix = ShepherdDrive(SheepMatrix,ShepherdMatrix,Goal, ...
                            RadiusSheep,RadiusShepherd,DogSpeedDifferentialIndex,CollectingTacticIndex, ...
                            CohesionRange,SimulationTime,DrivingTacticIndex,BoundarySize,SheepIndexInBiggestCluster, ...
                            NumberOfSheepInCluster,BiggestClusterLCM(SimulationTime,:));
                        FlagSigma1pos = SimulationTime + parameters.SigmaPositioningPoint; 
                    end
                        % Use this when want to convert shepherd heading from deg to compass 
                        % ShepherdDirection = CompassHeadings(ShepherdMatrix(3));
                        ShepherdIndividualBehaviour = 1; % "Driving";
                        FlagSigma = true; 
                        if ShepherdMatrix(:,6) == 0
                            ShepherdsIndividualAction = "Standing";
                        elseif ShepherdMatrix(:,6) == 1
                            ShepherdsIndividualAction = "Running";
                        end
                        SwarmState = 1; % "Clustered";
                elseif FlagSigma2 > SimulationTime % if collect 
                    if FlagSigma2pos > SimulationTime % continue with current P_\beta
                        ShepherdMatrix = ShepherdCollect(CollectSheepMatrix,ShepherdMatrix,Goal,...
                            CollectRadiusSheep,CollectRadiusShepherd,DogSpeedDifferentialIndex,CollectCollectingTacticIndex,...
                            CollectCohesionRange,SimulationTime,CollectDrivingTacticIndex,BoundarySize,CollectSheepIndexInBiggestCluster,...
                            CollectNumberOfSheepInCluster,CollectBiggestClusterLCM,CollectSheepNotInGoalIndex,CollectSheepNotInGoalNumber,...
                            CollectSheepNotInGoalGCM);
                    else % new P_\beta
                        % Determine which sheep to collect as per Collect Tactic and collect that sheep
                        ShepherdMatrix = ShepherdCollect(SheepMatrix,ShepherdMatrix,Goal, ...
                        RadiusSheep,RadiusShepherd,DogSpeedDifferentialIndex,CollectingTacticIndex, ...
                        CohesionRange,SimulationTime,DrivingTacticIndex,BoundarySize,SheepIndexInBiggestCluster, ...
                        NumberOfSheepInCluster,BiggestClusterLCM(SimulationTime,:),SheepNotInGoalIndex,SheepNotInGoalNumber, ...
                        SheepNotInGoalGCM(SimulationTime,:));
                        FlagSigma2pos = SimulationTime + parameters.SigmaPositioningPoint; 
                    end
                    % Use this when want to convert shepherd heading from deg to compass 
                    % ShepherdDirection = CompassHeadings(ShepherdMatrix(3));
                    ShepherdIndividualBehaviour = 2; % "Collecting";
                    FlagSigma = true; 
                    if ShepherdMatrix(:,6) == 0
                        ShepherdsIndividualAction = "Standing";
                    elseif ShepherdMatrix(:,6) == 1
                        ShepherdsIndividualAction = "Running";
                    end
                    SwarmState = 2; % "Dispersed";
                else 
                    FlagSigma = false; 
                end
            else % base case --> determine Collect or Drive here
                if NumberOfSheepInCluster(1) >= MinimumClusterSize % DRIVE
                    % Drive as per Drive Tactic
                    ShepherdMatrix = ShepherdDrive(SheepMatrix,ShepherdMatrix,Goal, ...
                        RadiusSheep,RadiusShepherd,DogSpeedDifferentialIndex,CollectingTacticIndex, ...
                        CohesionRange,SimulationTime,DrivingTacticIndex,BoundarySize,SheepIndexInBiggestCluster, ...
                        NumberOfSheepInCluster,BiggestClusterLCM(SimulationTime,:));
                    FlagSigma1SheepMat = SheepMatrix; % save the current positions and use these over the period determined 
                        DriveSheepMatrix = SheepMatrix;
                        DriveShepherdMatrix = ShepherdMatrix;
                        DriveGoal = Goal;
                        DriveRadiusSheep = RadiusSheep;
                        DriveRadiusShepherd = RadiusShepherd;
                        DriveDogSpeedDifferentialIndex = DogSpeedDifferentialIndex;
                        DriveCollectingTacticIndex = CollectingTacticIndex;
                        DriveCohesionRange = CohesionRange;
                        DriveSimulationTime = SimulationTime;
                        DriveDrivingTacticIndex = DrivingTacticIndex;
                        DriveBoundarySize = BoundarySize;
                        DriveSheepIndexInBiggestCluster = SheepIndexInBiggestCluster;
                        DriveNumberOfSheepInCluster = NumberOfSheepInCluster;
                        DriveBiggestClusterLCM = BiggestClusterLCM(SimulationTime,:);
                    ShepherdIndividualBehaviour = 1; % "Driving";
                    FlagSigma1 = SimulationTime + parameters.SigmaLength;
                    FlagSigma1pos = SimulationTime + parameters.SigmaPositioningPoint; 
                    FlagSigma = 1; 
                    if ShepherdMatrix(:,6) == 0
                        ShepherdsIndividualAction = "Standing";
                    elseif ShepherdMatrix(:,6) == 1
                        ShepherdsIndividualAction = "Running";
                    end
                    SwarmState = 1; % "Clustered";
                else % COLLECT
                    % Determine which sheep to collect as per Collect Tactic and collect that sheep
                    ShepherdMatrix = ShepherdCollect(SheepMatrix,ShepherdMatrix,Goal, ...
                        RadiusSheep,RadiusShepherd,DogSpeedDifferentialIndex,CollectingTacticIndex, ...
                        CohesionRange,SimulationTime,DrivingTacticIndex,BoundarySize,SheepIndexInBiggestCluster, ...
                        NumberOfSheepInCluster,BiggestClusterLCM(SimulationTime,:),SheepNotInGoalIndex,SheepNotInGoalNumber, ...
                        SheepNotInGoalGCM(SimulationTime,:));
                    FlagSigma2SheepMat = SheepMatrix; % save the current positions and use these over the period determined 
                        CollectSheepMatrix  = SheepMatrix;
                        CollectShepherdMatrix  = ShepherdMatrix;
                        CollectGoal  = Goal;
                        CollectRadiusSheep  = RadiusSheep;
                        CollectRadiusShepherd  = RadiusShepherd;
                        CollectDogSpeedDifferentialIndex  = DogSpeedDifferentialIndex;
                        CollectCollectingTacticIndex  = CollectingTacticIndex;
                        CollectCohesionRange  = CohesionRange;
                        CollectSimulationTime  = SimulationTime;
                        CollectDrivingTacticIndex  = DrivingTacticIndex;
                        CollectBoundarySize  = BoundarySize;
                        CollectSheepIndexInBiggestCluster  = SheepIndexInBiggestCluster;
                        CollectNumberOfSheepInCluster  = NumberOfSheepInCluster;
                        CollectBiggestClusterLCM = BiggestClusterLCM(SimulationTime,:);
                        CollectSheepNotInGoalIndex  = SheepNotInGoalIndex;
                        CollectSheepNotInGoalNumber  = SheepNotInGoalNumber;
                        CollectSheepNotInGoalGCM = SheepNotInGoalGCM(SimulationTime,:);               
                    ShepherdIndividualBehaviour = 2; % "Collecting";
                    FlagSigma2 = SimulationTime + parameters.SigmaLength;
                    FlagSigma2pos= SimulationTime + parameters.SigmaPositioningPoint; 
                    FlagSigma = 1; 
                    if ShepherdMatrix(:,6) == 0
                        ShepherdsIndividualAction = "Standing";
                    elseif ShepherdMatrix(:,6) == 1
                        ShepherdsIndividualAction = "Running";
                    end
                    SwarmState = 2; % "Dispersed";
                end
            end
            if parameters.Verbose2
                fprintf('t = %i with behaviour = %i ||| Continue behaviour? = %i ||| Drive until = %i -- Collect until = %i ||| Continue with drive pos until = %i -- Continue with collect pos until = %i |||\n',SimulationTime,ShepherdIndividualBehaviour,FlagSigma,FlagSigma1,FlagSigma2,FlagSigma1pos,FlagSigma2pos)
            end
            nameAfterDot = ['t',num2str(SimulationTime)]; 
            Flags = [Flags; SimulationTime, ShepherdIndividualBehaviour, FlagSigma, FlagSigma1, FlagSigma2, FlagSigma1pos, FlagSigma2pos];


            %% Calculate sheeps new positions
            % New heading of the sheep
            SheepMatrix = SheepObjects(SheepMatrix,NumSheepNeighbours,ShepherdMatrix, ...
                RadiusSheep,RadiusShepherd,BoundarySize,CollisionRangeIndex, ...
                Goal,GoalRadius,SheepNotInGoalIndex,SheepNotInGoalNumber,parameters,SimulationTime);
       
            % Calculate the number of sheep NOT in the goal area
            SheepNotInGoalIndex = find(SheepMatrix(:,6)==0); 
            SheepNotInGoalNumber = size(SheepNotInGoalIndex);

            % calculate the sheep not in goal LCM direction
            if SimulationTime > 1
                SheepLCMHeading = HeadingOfSheepLCM(BiggestClusterLCM,SimulationTime);
            end

            % test to see if the agent is in the goal 
            if DrivingTacticIndex == "DOAT" && ~FlagDOAT
                if ~ismember(TargetForDOAT, SheepNotInGoalIndex)
                    FlagDOAT = true; 
                end
            end
            
            %% Main Simulation Plot
            if Verbose
              if parameters.ImageVisual
                     x_low = ShepherdMatrix(:,1) - DogImgSize(1)/2; %//Left edge of marker
                     x_high = ShepherdMatrix(:,1) + DogImgSize(1)/2;%//Right edge of marker
                     y_low = ShepherdMatrix(:,2) - DogImgSize(2)/2; %//Bottom edge of marker
                     y_high = ShepherdMatrix(:,2) + DogImgSize(2)/2;%//Top edge of marker
                    % figure
                    figure(1)
                    if parameters.InternalMarkerCalculationsVisual      
                        subplot(2,2,1)
                    end
                    if ~parameters.military
                        % paddock background 
                        imagesc([MinX MaxX], [MinY MaxY],paddock)
                        if parameters.visual == "flipped"
                            set(gca,'YDir','normal'); % flips the y-axis back to [0 0] origin
                        end
                           
                        hold on
                    end 
                    for SheepIter = 1:NumberOfSheep
                        x_sheep_low = SheepMatrix(SheepIter,1) - SheepImgSize(1)/2; %//Left edge of marker
                        x_sheep_high = SheepMatrix(SheepIter,1) + SheepImgSize(1)/2;%//Right edge of marker
                        y_sheep_low = SheepMatrix(SheepIter,2) - SheepImgSize(2)/2; %//Bottom edge of marker
                        y_sheep_high = SheepMatrix(SheepIter,2) + SheepImgSize(2)/2;%//Top edge of marker
                        %fprintf('%i: XL=%f XH=%f YL=%f YH=%f\n',SimulationTime,x_sheep_low,x_sheep_high,y_sheep_low,y_sheep_high)
                        try 
                            imagesc([x_sheep_low x_sheep_high], [y_sheep_low y_sheep_high],SheepImg);
                        catch 
                            fprintf('Unable to render Agent %i at t=%i\n', SheepIter, SimulationTime            )
                            fprintf('Error using image. Nan is not supported.\n')
                        end 
                        if parameters.visual == "flipped"
                            set(gca,'YDir','normal'); % flips the y-axis back to [0 0] origin
                        end
                        hold on
                    end
                    hold on
                    if parameters.visual == "classic"
                        imagesc([x_low x_high], [y_low y_high],DogImg)
                    elseif parameters.visual == "flipped"
                        % Hussein's code to direct the nose of the picture to the direstion
                        Theta = asin(abs(ShepherdMatrix(1) / (0.01 + norm([ShepherdMatrix(1),ShepherdMatrix(2)])))) * 180 / pi;
                        if ShepherdMatrix(1) > 0
                            if ShepherdMatrix(2) < 0
                                Theta = - Theta;
                            end
                        else
                            if ShepherdMatrix(2) > 0
                                Theta = 180 - Theta;
                            else
                                Theta = 180 + Theta;
                            end
                        end
                        angle = Theta - 180;        
                        img_i = imrotate(DogImg, angle);
                        alpha_i = imrotate(DogM, angle);
                        ImageHandler=image(ShepherdMatrix(1), ShepherdMatrix(2), img_i);
                        ImageHandler.AlphaData = alpha_i;
                        % End of Hussein's code to direct the nose
                    end
    
                    if parameters.visual == "flipped"
                        set(gca,'YDir','normal'); % flips the y-axis back to [0 0] origin
                    end
                    % red star marker - GCM 
                    plot(SheepNotInGoalGCM(SimulationTime,1),SheepNotInGoalGCM(SimulationTime,2),'r*','markersize',10);
                    % blue diamond marker - LCM of largest cluster
                    plot(BiggestClusterLCM(SimulationTime,1),BiggestClusterLCM(SimulationTime,2),'bd','markersize',10) 
                    Theta = 0:pi/50:2*pi;
                    xunit = GoalRadius * cos(Theta) + Goal(1);
                    yunit = GoalRadius * sin(Theta) + Goal(2);
                    plot(Goal(1,1),Goal(1,2),'g*','markersize',10);
                    plot(xunit, yunit,'g');
                    %     image('XData', ShepherdMatrix(:,1),'YData', ShepherdMatrix(:,2),'CData', C) need to resize and flip
                    
                    % if the explanation flag is set, print the explanation to screen
                    if TranslationController == 1
                        if explanationFlag == true
                            % show the explanation for the specified amount of time
                            if showTime <= parameters.ShowTimeLength
                                txt = char(logic_stmt);
                                text(0,MinY,txt)
                            end
                        end
                    end
                    hold off
                        
                    axis([0 MaxX 0 MaxY]); 
                    title([ ...
                        'Drive = ', DrivingTacticIndex,...
                        ', Collect = ', CollectingTacticIndex,...
                        ', t = ', num2str(SimulationTime)])
                    xlabel('X position')
                    ylabel('Y position')
                    grid minor
                    axis manual
                    axis([MinX MaxX MinY MaxY]); 
                    if parameters.visual == "classic"
                        M(SimulationTime) = getframe; % Makes a movie clip from the plot
                    end 
              else 
                    PropCollect = round(100*(((1+sum(Flags(:,2) == 2)))/((((1+sum(Flags(:,2) == 2)))+(((1+sum(Flags(:,2) == 1)))))))); 
                    PropDrive = round(100*(((1+sum(Flags(:,2) == 1)))/((((1+sum(Flags(:,2) == 2))) + (((1+sum(Flags(:,2) == 1))))))));
                    if ShepherdIndividualBehaviour == 1
                        DriveOrCollect = '$\sigma_1$'; 
                    else
                        DriveOrCollect = '$\sigma_2$';
                    end
                    f = figure(1);
                    f.Position = [100 100 1100 1100];
                    scatter(SheepMatrix(:,1), SheepMatrix(:,2), 'filled', 'MarkerEdgeColor',[0 .5 .5], 'MarkerFaceColor', [0 .7 .7], 'LineWidth', 1.5)
                    hold on 
                    scatter(ShepherdMatrix(:,1), ShepherdMatrix(:,2), 100, 'filled', 'MarkerEdgeColor',[201/255 223/255 236/255], 'MarkerFaceColor', [242/255 92/255 0/255], 'LineWidth', 1.5)
                    % red star marker - GCM 
                    plot(SheepNotInGoalGCM(SimulationTime,1),SheepNotInGoalGCM(SimulationTime,2),'r*','markersize',10)
                    % blue diamond marker - LCM of largest cluster
                    plot(BiggestClusterLCM(SimulationTime,1),BiggestClusterLCM(SimulationTime,2),'bd','markersize',10) 
                    % drive/collect position
                    plot(ShepherdMatrix(:,7), ShepherdMatrix(:,8), 'pentagram', 'markersize', 15)
                    Theta = 0:pi/50:2*pi;
                    xunit = GoalRadius * cos(Theta) + Goal(1);
                    yunit = GoalRadius * sin(Theta) + Goal(2);
                    plot(Goal(1,1),Goal(1,2),'g*','markersize',10,'MarkerFaceColor',[201/255 223/255 236/255]);
                    plot(xunit, yunit,'g');
                    hold off 
                    axis([0 MaxX 0 MaxY]); 
                    title(['t= ', num2str(SimulationTime),...
                           ' | $\sigma_1, \sigma_2$= \{', DrivingTacticIndex, ', ', CollectingTacticIndex, '\}',...
                           ' | $\sigma^t$= ', DriveOrCollect,...
                           ' | $\sigma_1^{\Delta t}$= ', num2str(PropDrive), '\%',...
                           ' | $\sigma_2^{\Delta t}$= ', num2str(PropCollect), '\%',...
                           ' | $C_2$= ',num2str(parameters.SigmaLength),...
                           ' | $C_3$= ',num2str(parameters.SigmaPositioningPoint)],...
                           'Interpreter','latex','FontSize',16)
                    legend({'$\Pi$','$\beta$','GCM','Largest Cluster LCM','$P^t_{\beta\sigma}$'},'Location','southoutside','Orientation','horizontal','Interpreter','latex','FontSize',16)
                    pause(0.1)
                    
              end 
              BehaviourProportions = [BehaviourProportions; PropDrive PropCollect];

            end
            % Hold the explanation on the GUI for XX time
            showTime = showTime + 1;
    
    if SheepNotInGoalNumber(1) == 0
        AllSheepWithinGoal = 1; % Call to terminate sim
    end 
  
    % test if any agent positions are NaN 
    if (any(isnan(SheepMatrix(:,1))) && any(isnan(SheepMatrix(:,2))))
        for Agent = 1:length(SheepMatrix(:,1))
            % if an agent has a NaN position value, set their position to
            % the goal location 
            if (isnan(SheepMatrix(Agent,1)) || isnan(SheepMatrix(Agent,2)))
                g1 = rand; 
                g2 = rand; 
                SheepMatrix(Agent,1) = parameters.Goal(1)+((-1*(g1>0.5))*(parameters.GoalRadius*g1*0.5)+((g1<0.5)*parameters.GoalRadius*g1*0.5)); 
                SheepMatrix(Agent,2) = parameters.Goal(2)+((-1*(g2>0.5))*(parameters.GoalRadius*g2*0.5)+((g2<0.5)*parameters.GoalRadius*g2*0.5));
            end
        end
        %parameters.BreakWhile = true; 
    end

    % test if the shepehrd is NaN
    if (any(isnan(ShepherdMatrix(1))) && any(isnan(ShepherdMatrix(2))))
        %parameters.BreakWhile = true; 
    end
    % Determine the collecting tactic number
    try 
        CollectingTacticOutput = CollectingTactic(CollectingTacticIndex,SheepMatrix,SheepNotInGoalIndex, ...
                SheepNotInGoalGCM,SheepNotInGoalNumber,RadiusSheep,NumberOfSheep,Goal,ShepherdMatrix,NumberOfShepherds, ...
                SheepIndexInBiggestCluster,NumberOfSheepInCluster,BiggestClusterLCM);
                CollectingTacticNumber = CollectingTacticOutput(4);
    catch
        fprintf('\nTry-catch executed at t=%i for CollectingTactic=%s and DrivingTactic=%s.\n',SimulationTime,CollectingTacticIndex,DrivingTacticIndex)
        parameters.BreakWhile = true; 
    end

    %% Update 31/3/22 - Data output generation for Swarm Markers, Recognition and Prediction
    SensedData.t(SimulationTime) = SimulationTime; 
    SensedData.NumberOfSheep(SimulationTime) = NumberOfSheep; 
    SensedData.GoalX(SimulationTime) = Goal(1); 
    SensedData.GoalY(SimulationTime) = Goal(2); 
    SensedData.SheepDogX(SimulationTime) = ShepherdMatrix(:,1);
    SensedData.SheepDogY(SimulationTime) = ShepherdMatrix(:,2);
    SensedData.SheepX(SimulationTime,:) = SheepMatrix(:,1)';
    SensedData.SheepY(SimulationTime,:) = SheepMatrix(:,2)';
    SensedData.SheepNotInGoal(SimulationTime) = SheepNotInGoalNumber(1,1); 
    SensedData.SeparatedSheep(SimulationTime) = NumberOfSheepSeparated(1,1);
    SensedData.AllSheepWithinGoal = AllSheepWithinGoal;

    %% Update 9/6/22 - Data output generation for Neural Machine Translation
    TranslationDataSheepDog.SeenThreat(SimulationTime) = 0; % 0=No 1=Yes change to variable in future versions 
    TranslationDataSheepDog.ThreatDistance(SimulationTime) = rand(1)*100; % this will be a function at some stage
    TranslationDataSheepDog.ThreatDirection(SimulationTime) = -180 + 360.*rand(1); % this will be a function at some stage
    TranslationDataSheepDog.SheepDogX(SimulationTime) = ShepherdMatrix(1);
    TranslationDataSheepDog.SheepDogY(SimulationTime) = ShepherdMatrix(2);
    TranslationDataSheepDog.SheepDogHeading(SimulationTime) = ShepherdMatrix(3);
    TranslationDataSheepDog.Intent(SimulationTime) = 1; % 1=Herd 2=Patrol 3=Contain change to variable for future multiple intents 
    TranslationDataSheepDog.GoalX(SimulationTime) = Goal(1); % this could differ to the shepherds goal in the future if the dog breaks down the task into sub tasks
    TranslationDataSheepDog.GoalY(SimulationTime) = Goal(2); % this could differ to the shepherds goal in the future if the dog breaks down the task into sub tasks
    TranslationDataSheepDog.SheepDogBehaviour(SimulationTime) = ShepherdIndividualBehaviour; 
    TranslationDataSheepDog.DrivingTactic(SimulationTime) = DrivingTacticNumber; 
    TranslationDataSheepDog.CollectingTactic(SimulationTime) = CollectingTacticNumber; 
    TranslationDataSheepDog.SheepDogAction(SimulationTime) = ShepherdMatrix(:,6); 
    TranslationDataSheepDog.SwarmState(SimulationTime) = SwarmState;
    TranslationDataSheepDog.SheepEscaping(SimulationTime) = 0; % 0=N 1=Y, will be used when patrolling introduced
    TranslationDataSheepDog.SheepEscapingDirection(SimulationTime) = 0; % this will be in degrees
    TranslationDataSheepDog.NumberOfSheepSeparated(SimulationTime) = NumberOfSheepSeparated(1);
    TranslationDataSheepDog.TargetSheepID(SimulationTime) = ShepherdMatrix(4);
    TranslationDataSheepDog.Obstacle(SimulationTime) = 0; %"No"; % change to variable in future versions 
    TranslationDataSheepDog.SheepLCMHeading(SimulationTime) = SheepLCMHeading;
    TranslationDataSheepDog.SheepIndividualAction(SimulationTime,:) = SheepMatrix(:,8);

    % save the data struct at each time step for translation
    output.SensedData = SensedData;
    output.TranslationData = TranslationDataSheepDog;
    output.parameters = parameters; 
    % set some conditions to flag for an explanation
    if TranslationController == 1
        if SimulationTime == 50
            save('output.mat', 'output')
            logic_stmt = py.devDB.logic_tensor(); % you need to add the pyton location to Matlab file path
            fprintf('\n----- The current state logic is %s\n ', logic_stmt) % fprintf(char(logic_stmt))
            explanationFlag = true;
            showTime = 1;
        end
        
        if SimulationTime == 150
            save('output.mat', 'output')
            logic_stmt = py.devDB.logic_tensor();
            fprintf('\n----- The current state logic is %s\n ', logic_stmt)
            explanationFlag = true;
            showTime = 1;
        end
    
        if SimulationTime == 225
            save('output.mat', 'output')
            logic_stmt = py.devDB.logic_tensor();
            fprintf('\n----- The current state logic is %s\n ', logic_stmt)
            explanationFlag = true;
            showTime = 1;
        end
    end
         
    %% CONTEXT-AWARE INTELLIGENT DECISION SUPPORT SYSTEM 
    if parameters.InternalMarkerCalculations
        if sum(SimulationTime==parameters.Windows(:,2))>0
            
            % ### ### ### ### ### 
            nameAfterDot = ['t',num2str(SimulationTime)]; 
            IntelligentAgent.(nameAfterDot) = IntelligentMarkerControl(Verbose, SensedData, parameters, SimulationTime, C1, C2, C2_He, C2_Ho, C2_He2, C2_Ho2, datacube, NumberOfSheep, FullSet, EvalCost, EvalGain, SwarmAgentAttnPoints, InteractionAgentProp, SwarmClassificationData, DrivingTacticIndex, CollectingTacticIndex, CLOCK_2_regmdl, CLOCK_3_regmdl, ProbMat, PredClassScore); 
            IntelligentAgent.(nameAfterDot).FLAGS = [SimulationTime, ShepherdIndividualBehaviour, FlagSigma, FlagSigma1, FlagSigma2, FlagSigma1pos, FlagSigma2pos];
            
            % Stats stats stats
            ProbMat = IntelligentAgent.(nameAfterDot).ProbMat; % save the probability matrix
            ScenarioClassFreq(IntelligentAgent.(nameAfterDot).DecisionModel.scenario) = ScenarioClassFreq(IntelligentAgent.(nameAfterDot).DecisionModel.scenario) + 1;
            SwarmAttnPoints = SwarmAttnPoints + IntelligentAgent.(nameAfterDot).SwarmAgentAttnPoints; 

            % Behaviour re-assessment clock 
            parameters.SigmaLength = IntelligentAgent.(nameAfterDot).Clock2; 

            % Behaviour execution point re-assessment clock
            parameters.SigmaPositioningPoint = IntelligentAgent.(nameAfterDot).Clock3;

            ClockTimesDist = [ClockTimesDist; parameters.SigmaLength parameters.SigmaPositioningPoint];

            if parameters.TacticPairSelection
                DrivingTacticIndex = IntelligentAgent.(nameAfterDot).TacticDrive;
                CollectingTacticIndex = IntelligentAgent.(nameAfterDot).TacticCollect;
            end
            if ~parameters.SET_CLOCK && parameters.Verbose2
                fprintf('\nUsing %s and %s behaviours. \n\n\n\n\n', convertCharsToStrings(DrivingTacticIndex), convertCharsToStrings(CollectingTacticIndex))
            end
        end
    end

    %% Stats & Data Plotting 
    if parameters.Verbose
        f2 = figure(2); 
        f2.Position = [1300 100 1100  1100];
                  
        subplot(3,2,1)
            plot(BehaviourProportions, 'LineWidth', 3)
            ylim([0 100])
            title('Cumulative Behaviour Proportions')
            legend({'Drive','Collect'}, 'Location', 'northwest')
                  
        subplot(3,2,2)
            hist(SensedData.SeparatedSheep)
            title('Separated Sheep Histogram')
                  
        subplot(3,2,3)
             boxchart(ProbMat(:,3:end))
             title('Scenario Probability Distribution')

         subplot(3,2,4)
             bar(ScenarioClassFreq)
             title('Scenario Identified')

        subplot(3,2,5)
            hist(ClockTimesDist(:,1))
            title('Clock 2 Time Histogram')

        subplot(3,2,6)
            hist(ClockTimesDist(:,2))
            title('Clock 3 Time Histogram')
 
%          subplot(3,3,7)
%              bar(SwarmAttnPoints)
%              title('Swarm Attention Points')

    end

    % if NaNs are observed and recorded, now break from the simulation
    if parameters.BreakWhile 
        break
    end
    
    % Next step - the last thing 
    SimulationTime = SimulationTime + 1;

end

% Output message for simulation termination condition
fprintf('\nSimulated ended with ')
if SimulationTime == NumberOfTimeSteps
    fprintf('code 1: maximum allowed runtime reached.\n')
elseif parameters.BreakWhile
    if AllSheepWithinGoal == 1
        fprintf('code 2: parameters.BreakWhile; however, all agents are within the goal location (mission complete).\n')
    else 
        fprintf('code 3: parameters.BreakWhile executed.\n')
    end
elseif AllSheepWithinGoal == 1
    fprintf('code 4: all agents within goal location (mission complete).\n')
else
    fprintf('code 0: review simulation output log.\n')
end
% fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n\n')

% Save all data! 
%output.AgentSummary = 
output.SensedData = SensedData;
output.TranslationData = TranslationDataSheepDog;
output.parameters = parameters; 
output.TacticPairRecord = TacticPairRecord; 
output.Flags = Flags; 
output.BehaviourProportions = BehaviourProportions; 
if parameters.InternalMarkerCalculations
   output.IntelligentAgent = IntelligentAgent; 
   output.ProbMat = ProbMat; 
   output.PredClassScore = PredClassScore; 
   output.SwarmAttnPoints = SwarmAttnPoints; 
   output.MeanVarDist = MeanVarDist; 
   output.ClockTimesDist = ClockTimesDist; 
   output.ScenarioClassFreq = ScenarioClassFreq;    
   output.ScenarioProbMat = ScenarioProbMat; 
end