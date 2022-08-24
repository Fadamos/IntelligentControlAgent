function output = MasterCall(parameters)

%% MasterCall Description
% This script is the master controller for the functions that are
% modifications of the algorithm presented in the following paper:
% "D. Strömbom, R. Mann, A. Wilson, S. Hailes, A. Morton,
% D. Sumpter and A. King. Solving the shepherding problem: heuristics for
% herding autonomous, interacting agents. In: Journal of the Royal Society
% Interface, 2014."
% The algorithm has been modified in two ways: First, we have added
% movements across the x-axis and y-axis when the shepherd is not behind
% the sheep. This speeded up dramatically the ability of the shepherd to
% get behind the sheep and in cases, resulted in faster convergence.
% The second aspect is that we have not used some of the parameters in the
% original paper. For example, the number of nearest neighbours the
% shepherd operates on. This is a limitation in our implementation but it
% can be included very easily.

%% INPUTS
% NumberOfSheep         = Number of sheep objects
% NumSheepNeighbours    = Number of neighbours for each sheep
% NumberOfShepherds     = Number of shepherds
% SheepRadius           = Radius of sheep's influence
% ShepherdRadius        = Radius of shepherd's influence
% BoundarySize          = Side length of initial paddock (square)

%% Strombom's Parameters
%%%%% Sheep Parameters
% L     Side length of initial square field = 150m
% N     Total number of sheep = 1 to 201
% n     Number of nearest neighbours for sheep = 1 to 200
% r_s   Shepherd detection distance = 65m
% r_a   Sheep to sheep interaction distance = 2m
% p_a   Relative strength of repulsion from other agents = 2
% c     Relative strength of attraction to the n nearest neighours = 1.05
% p_s   Relative strength of repulsion from the shepherd = 1
% h     Relative strength of proceeding in the previous direction = 0.5
% e     Relative strength of angular noise = 0.3
% delta Sheep displacement per time step = 1 m ts ^ -1
% p     Probability of moving per time step while grazing = 0.05
%%%%% Shepherd Parameters
% delta_s   Shepherd displacement per time step = 1.5 m ts ^ -1
% P_d   Driving position = r_a*sqrt(N)    m behind the flock
% P_c   Collecting position = r_a   m behind the furthest sheep
% e     Relative strength of angular noise = 0.3
%%%%% For Local Shepherd *Not Implemented
% n_s   Number of nearest agents the local shepherd operates on = 20
% B     Blind angle behind the shepherd = Pi / 2

%% Initialise Simulation Parameters
Verbose                                 = parameters.Verbose;
VerboseBugger                           = parameters.VerboseBugger;

%% Default Parameters
% BoundarySize       = 150;
% NumberOfSheep      = 50;
% NumSheepNeighbours = 0.6 * NumberOfSheep;  % Chose this due to In the global case n = N ? 1 and down to n = 0.53N, the algorithm is always successful. For N > 30, there is a transition region below the line n = 0.53N and above n ? 3log(N) where the probability of success drops from 1 to rare. In the region under the curve min(0.53N, 3log(N)) success is very rare.
% RadiusSheep        = 2;   % r_a [m]
% NumberOfShepherds  = 1;   % 2, 4, 5, 10, 20 
% RadiusShepherd     = 65;  % r_s [m]
% NumberOfInitialClusters   = 1;
% ShepherdStep       = 1.5; % 1.5; % delta_s [m/s]
% SheepStep          = 1;   % delta [m/s]
% StopWhenSheepGlobalCentreOfMassDistanceToTargetIs = 10;

%% 
% parameters.CollisionRange = 'L2'; % L1-L4 for the sheep-sheep separation levels
% parameters.SheepDogVehicleSpeedLimit = 'Dog1.25'; % 
% parameters.DogCollectingTacticIndex = 'F2H';
% parameters.DogDrivingTacticIndex = 'DAH';

% Ranges                                  = parameters.Ranges;
% RadiusSheep                             = Ranges(4);
% NumSheepNeighbours                      = Ranges(2);
% RadiusShepherd                          = Ranges(3);
% NumberOfTimeSteps                       = parameters.NumberOfSteps;
% Goal                                    = parameters.Goal;
% GoalRadius                              = parameters.GoalRadius;
% BoundarySize                            = parameters.Boundary;
% NumberOfSheep                           = parameters.NumberOfSheep;
% SheepStep                               = parameters.SheepStepSize;
% SheepInitialRadius                      = parameters.SheepInitialRadius;
% NumberOfInitialClusters                 = parameters.SheepInitialClusters;
NumberOfShepherds                       = parameters.NumberOfShepherds; % need this here to build results matrix below
% ShepherdStep                            = parameters.SheepDogVehicleSpeedLimit;
% SheepDogBehaviorType                    = parameters.SheepDogBehaviorType;
% TargetSelectionMethod                   = parameters.TargetSelectionMethod;
% MaximumSafetyDistance                   = parameters.MaximumSafetyDistance;
% DrivingCollectingPointsSafetyDistance   = parameters.DrivingCollectingPointsSafetyDistance;
% SheepDogInitialOffsetFromSheepLocation  = parameters.SheepDogInitialOffsetFromSheepLocation;
% PauseLength                             = parameters.PauseLength; 
% ScenarioIndex                           = parameters.ScenarioIndex;
% Scenario                                = parameters.Scenario;
% CollectingTacticIndex                   = parameters.DogCollectingTacticIndex;
% DrivingTacticIndex                      = parameters.DogDrivingTacticIndex;
% CollisionRangeIndex                     = parameters.CollisionRange;
% ReplicateNumber                         = 1; %parameters.Replicate;

%% Experimentally calculated parameters
% 1000 NumberOfTimeSteps = Number of time steps --> Suggested to be (20N+630)
% NumberOfTimeSteps = 630 + 20 * NumberOfSheep;

%% Strombom's Algorithm
% Sheep Rules
% if sheep distance to shepherd > r_s  Do not move
%   else
%       if distance between two sheep < r_a Repell in the direction
%       \hat(R)^a
%       else
%           if sheep distance to shepherd < r_s
%               Sheep is attracted to the Local Centre of Mass of its n
%               nearest neighbours in the direction \hat(c)
%               AND
%               Repelled away from dog in the direction \hat(R)^s
% Sheep position update rule
%  H = p_a * \hat(R)^a + c * \hat(C) + p_s * \hat(R)^s + d * \hat(H) + e
%  \hat(H) is the previous direction
%  e is the noise
% Shepherd Rules
% if shepherd distance to any sheep < 3 r_a Shepherd does not move
%   else
%       if all sheep are within distance f(N) from their Global Centre of
%       Mass, the shepherd aims towards position p_d directly behind sheep
%       relative position to target
%       else
%           Shepherd aims for collecting position p_c behind the furthest
%           away agent

%% Initialise Sheep in the top right quarter of the paddock
load('TestingSeedsX.mat')
load('TestingSeedsY.mat')
load('TestingSeedsDirection.mat')

%% Initialise all the matrices required 
TestResults1 = zeros(30,18); % Set up the matrix to store the results
% [MeanDist,NSeps,PropColl,PropDriv,TCol,TDrv,TotalTime]

%% "...WHOLE1Shep100Sheep..." defines the simulation type, as in:
%  'WHOLE' = sheep spawn over the whole paddock (have versions to spawn differently)
%  '1Shep' = 1 shepherd
%  '100Sheep' = 100 sheep
%
%  It's easy enough to find replace all with another descriptor

TestWHOLEClusterFormSep1Shep=zeros(30,18);
TestNumSeparationsMatrixWHOLE1Shep100Sheep=zeros(30,2630);% Set up the matrix to record the number of separations per time step for each simulation
TimeCollectingWHOLE1Shep100Sheep=zeros(NumberOfShepherds,30);
TimeDrivingWHOLE1Shep100Sheep=zeros(NumberOfShepherds,30);
ProportionCollectingWHOLE1Shep100Sheep=zeros(NumberOfShepherds,30); % Matrix to store the proportion of time spent collecting
ProportionDrivingWHOLE1Shep100Sheep=zeros(NumberOfShepherds,30);    % Matrix to store the proportion of time spent driving
ShepherdXPosMeanWHOLE1Shep100Sheep=zeros(1,1);
ShepherdXPosSdtDevWHOLE1Shep100Sheep=zeros(1,1);
ShepherdXPosSkewnessWHOLE1Shep100Sheep=zeros(1,1);
ShepherdXPosKurtosisWHOLE1Shep100Sheep=zeros(1,1);
ShepherdYPosMeanWHOLE1Shep100Sheep=zeros(1,1);
ShepherdYPosSdtDevWHOLE1Shep100Sheep=zeros(1,1);
ShepherdYPosSkewnessWHOLE1Shep100Sheep=zeros(1,1);
ShepherdYPosKurtosisWHOLE1Shep100Sheep=zeros(1,1);

%% Run simulation loops
for SimulationRuns=1:1
    
    clearvars -except BoundarySize NumberOfSheep NumSheepNeighbours RadiusSheep ...
        RadiusShepherd SheepStep ShepherdStep TestingSeedsX TestingSeedsY ...
        TestingSeedsDirection SimulationRuns TestWHOLEClusterFormSep1Shep NumberOfTimeSteps ...
        StopWhenSheepGlobalCentreOfMassDistanceToTargetIs NumberOfClusters ...
        TestNumSeparationsMatrixWHOLE1Shep100Sheep NumberOfShepherds NumberOfSheep ...
        TimeCollectingWHOLE1Shep100Sheep TimeDrivingWHOLE1Shep100Sheep ...
        ShepherdTimeSpentCollectingWHOLE1Shep100Sheep ...
        ShepherdTimeSpentDrivingWHOLE1Shep100Sheep ProportionCollectingWHOLE1Shep100Sheep ...
        ProportionDrivingWHOLE1Shep100Sheep ShepherdXPosMeanWHOLE1Shep100Sheep ShepherdXPosSdtDevWHOLE1Shep100Sheep ...
        ShepherdXPosSkewnessWHOLE1Shep100Sheep ShepherdXPosKurtosisWHOLE1Shep100Sheep ...
        ShepherdYPosMeanWHOLE1Shep100Sheep ShepherdYPosSdtDevWHOLE1Shep100Sheep ...
        ShepherdYPosSkewnessWHOLE1Shep100Sheep ShepherdYPosKurtosisWHOLE1Shep100Sheep parameters
    
    [SimDisplay,TimeCollectingWHOLE1Shep100Sheep,TimeDrivingWHOLE1Shep100Sheep,ProportionCollectingWHOLE1Shep100Sheep, ...
        ProportionDrivingWHOLE1Shep100Sheep,ShepherdXPosMeanWHOLE1Shep100Sheep,ShepherdXPosSdtDevWHOLE1Shep100Sheep, ...
        ShepherdXPosSkewnessWHOLE1Shep100Sheep,ShepherdXPosKurtosisWHOLE1Shep100Sheep,ShepherdYPosMeanWHOLE1Shep100Sheep,ShepherdYPosSdtDevWHOLE1Shep100Sheep, ...
        ShepherdYPosSkewnessWHOLE1Shep100Sheep,ShepherdYPosKurtosisWHOLE1Shep100Sheep] = SheepMasterWHOLEGroups( ...
        SimulationRuns,TestingSeedsX,TestingSeedsY,TestingSeedsDirection, ...
        TestNumSeparationsMatrixWHOLE1Shep100Sheep, ...
        TimeCollectingWHOLE1Shep100Sheep,TimeDrivingWHOLE1Shep100Sheep,ProportionCollectingWHOLE1Shep100Sheep, ...
        ProportionDrivingWHOLE1Shep100Sheep,ShepherdXPosMeanWHOLE1Shep100Sheep,ShepherdXPosSdtDevWHOLE1Shep100Sheep, ...
        ShepherdXPosSkewnessWHOLE1Shep100Sheep,ShepherdXPosKurtosisWHOLE1Shep100Sheep,ShepherdYPosMeanWHOLE1Shep100Sheep, ...
        ShepherdYPosSdtDevWHOLE1Shep100Sheep,ShepherdYPosSkewnessWHOLE1Shep100Sheep,ShepherdYPosKurtosisWHOLE1Shep100Sheep,parameters);
    
    %% Build test results matrix for alanysis
    TestWHOLEClusterFormSep1Shep(SimulationRuns,1)=SimDisplay(1,1); % Did the GCM reach the target
    TestWHOLEClusterFormSep1Shep(SimulationRuns,2)=SimDisplay(1,2); % Total simulation time
    % Flock dispersion metrices
    TestWHOLEClusterFormSep1Shep(SimulationRuns,3)=SimDisplay(1,3); % Mean distance between the GCM and target
    TestWHOLEClusterFormSep1Shep(SimulationRuns,4)=SimDisplay(1,4); % SD of the distance between the GCM and the target
    TestWHOLEClusterFormSep1Shep(SimulationRuns,5)=SimDisplay(1,5); % Mean distance between the furthest sheep from the GCM to the GCM
    TestWHOLEClusterFormSep1Shep(SimulationRuns,6)=SimDisplay(1,6); % SD of the distance of the furthest sheep from the GCM at each time step
    TestWHOLEClusterFormSep1Shep(SimulationRuns,7)=SimDisplay(1,7); % Mean distance of the furthest sheep from the target to the target
    TestWHOLEClusterFormSep1Shep(SimulationRuns,8)=SimDisplay(1,8);   % SD of the furthest sheep from the target to the target
    TestWHOLEClusterFormSep1Shep(SimulationRuns,9)=SimDisplay(1,9);   % Mean distance of the furthest sheep from the GCM to the target
    TestWHOLEClusterFormSep1Shep(SimulationRuns,10)=SimDisplay(1,10); % SD of the furthest sheep from the GCM to the target
    % Shepherd metrices
    TestWHOLEClusterFormSep1Shep(SimulationRuns,11)=SimDisplay(1,11); % Mean of the furthest sheep from target to closest shepherd to it
    TestWHOLEClusterFormSep1Shep(SimulationRuns,12)=SimDisplay(1,12); % Standard deviation of the furthest sheep from target to closest shepherd to it
    TestWHOLEClusterFormSep1Shep(SimulationRuns,13)=SimDisplay(1,13); % Mean distance between the sheep GCM and the shepherd GCM
    TestWHOLEClusterFormSep1Shep(SimulationRuns,14)=SimDisplay(1,14); % Standard deviation of the distance between the sheep GCM and shepherd GCM
    TestWHOLEClusterFormSep1Shep(SimulationRuns,15)=SimDisplay(1,15); % Mean distance between shapherds
    TestWHOLEClusterFormSep1Shep(SimulationRuns,16)=SimDisplay(1,16); % Standard deviation between shepherds
    TestWHOLEClusterFormSep1Shep(SimulationRuns,17)=SimDisplay(1,17); % Mean distance of the shepherds GCM to target
    TestWHOLEClusterFormSep1Shep(SimulationRuns,18)=SimDisplay(1,18); % Standard deviation distance of the shepherds GCM to target
    
end