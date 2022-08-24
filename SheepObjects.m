function SheepMatrixUpdate = SheepObjects(SheepMatrix,NumSheepNeighbours, ...
    ShepherdMatrix,RadiusSheep,RadiusShepherd,BoundarySize, ...
    CollisionRangeIndex,Goal,GoalRadius,SheepNotInGoalIndex,SheepNotInGoalNumber, parameters, SimulationTime)

%% INPUTS
% SheepMatrix        = Sheep population matrix
% NumSheepNeighbours = Number of sheep neighbours
% ShepherdMatrix     = Shepherd population matrix
% RadiusSheep        = Radius of the sheep
% RadiusShepherd     = Radius of the shepherd
% SheepStep          = Sheep movement factor per time step

%% OUTPUT 
% SheepMatrixUpdate=Updated sheep population matrix SheepMatrix

%% Parameters
NumSheep                           = size(SheepMatrix,1); % Number of sheep
SheepMatrixUpdate                  = zeros(NumSheep,8);   % For simultaneous update
NoiseLevel                         = 0.3;  % e: relative strength of angular noise
GrazingMovementProbability         = 0.05; % p: 
MinX = BoundarySize(1);
MaxX = BoundarySize(2);
MinY = BoundarySize(3);
MaxY = BoundarySize(4);

for i = 1 : NumSheep % Go through every sheep.
    
    % SheepCalculations calculates the following for each sheep i
    % 1. Direction of repulsion from other sheep
    % 2. Direction of repulsion from shepherd
    % 3. Direction of attraction to other sheep
    % 4. Distance to the shepherd
    
    % This is achieved by calculating
    % 1. Each sheeps local neighborhood by determining everything within its radius
    % 2. Each sheeps direction toward the center of mass of its local neighborhood
    % 3. The mean direction of all its neighbours

    %% Heterogeneous Sheep 

    % build vector of swarm agent types 
    parameters.SwarmAgentTypeDistribution = generateSwarm(parameters.NumberOfSheep,parameters.SheepBehaviorModels,parameters.Scenario);
    % select behaviour case for swarm agent i
    parameters.SheepBehaviourCase = char(parameters.SwarmAgentTypeDistribution(i));
        
    % activate SheepBehaviourCase for swarm agent i
    [parameters.Weights,parameters.SheepVehicleSpeedLimit] = SheepBehaviourLibrary(parameters,parameters.SheepBehaviourCase);
    % parameterise swarm agent i
    Weights = parameters.Weights;
    % set weights for use for this specific agent 
    WeightAttractionToLCMOfnNeighbours = Weights(1); % c (W_pi_Lambda)
    WeightRepelFromOtherSheep          = Weights(2); % p_a (W_pi_pi) 
    WeightRepelFromShepherd            = Weights(4); % p_s (W_pi_beta)
    WeightOfInertia                    = Weights(5);  % h: weight of previous step movement 
    SheepStep                          = parameters.SheepVehicleSpeedLimit; % speed for the individual agent 
        
    % console print
    if parameters.VerboseBugger && SimulationTime < 2
        fprintf('Agent %i BehaviourCase %s\n', i, parameters.SheepBehaviourCase)
        fprintf('Agent %i Weights [%f %f %f %f %f]\n', i, Weights(1), Weights(2), Weights(3), Weights(4), Weights(5))
        fprintf('Agent %i Agent Speed %f\n', i, SheepStep)
    end 
    
    %% Continue Agent Calculations
    % Determine whether the sheep is within the goal area
    VectorToGoal = [SheepMatrix(i,1) - Goal(1), SheepMatrix(i,2) - Goal(2)];
    DistanceToGoal = hypot(VectorToGoal(1), VectorToGoal(2));
    if DistanceToGoal <= GoalRadius
        SheepMatrixUpdate(i,6) = 1;
    end

    % if the sheep are within the goal, react to nothing and influence nothing
    if SheepMatrixUpdate(i,6) == 1
        g1 = rand; 
        g2 = rand; 
        SheepMatrixUpdate(i,1) = parameters.Goal(1)+((-1*(g1>0.5))*(parameters.GoalRadius*g1*0.5)+((g1<0.5)*parameters.GoalRadius*g1*0.5));
        SheepMatrixUpdate(i,2) = parameters.Goal(2)+((-1*(g2>0.5))*(parameters.GoalRadius*g2*0.5)+((g2<0.5)*parameters.GoalRadius*g2*0.5));
        SheepMatrixUpdate(i,3) = 0;
        SheepMatrixUpdate(i,4) = 0;
        SheepMatrixUpdate(i,5) = i;
    else
    
        SheepForces = SheepCalculations(i,SheepMatrix,NumSheepNeighbours,ShepherdMatrix,RadiusSheep,RadiusShepherd, ...
            CollisionRangeIndex,DistanceToGoal,Goal,SheepNotInGoalIndex,SheepNotInGoalNumber);
        
        RepulsionFromOtherSheep = SheepForces(1,:); % Direction of repulsion from other sheep
        RepulsionFromShepherd   = SheepForces(2,:); % Direction of repulsion from shepherd
        AttractionToOtherSheep  = SheepForces(3,:); % Direction of attract to other sheep
        DistanceToShepherd      = SheepForces(4,1); % Distance to shepherd
        SeenAShepherd           = SheepForces(4,2); % If the sheep has seen a shepherd or not
        
        if SeenAShepherd == 1 % If the shepherd is close enough to sheep i
            SheepMatrixUpdate(i,4) = 1; % The sheep sees it
        else
            SheepMatrixUpdate(i,4) = 0; % Else has not seen it
        end
        PreviousDirection = [cos(SheepMatrix(i,3)),sin(SheepMatrix(i,3))]; % Direction in the previous time step
        
        %% If reacting to the shepherd
        if SheepMatrixUpdate(i,4) == 1
            % New direction of the sheep
            NewDirection = WeightOfInertia*PreviousDirection ...
                + WeightRepelFromOtherSheep*RepulsionFromOtherSheep ...
                + WeightRepelFromShepherd*RepulsionFromShepherd ...
                + WeightAttractionToLCMOfnNeighbours*AttractionToOtherSheep;
            
            % Normalised direction of the sheep
            NormalisedNewDirection = (1/(sqrt(NewDirection(1,1)^2 + NewDirection(1,2)^2))*NewDirection);
            
            % Update position
            SheepMatrixUpdate(i,1) = SheepMatrix(i,1) + SheepStep*NormalisedNewDirection(1,1); %New x-coordinate
            SheepMatrixUpdate(i,2) = SheepMatrix(i,2) + SheepStep*NormalisedNewDirection(1,2); %New y-coordinate
            
            % New directional angle
            SheepMatrixUpdate(i,3) = atan2(NormalisedNewDirection(1,2),NormalisedNewDirection(1,1));
            
            % Preserve the index of the sheep
            SheepMatrixUpdate(i,5) = SheepMatrix(i,5);

            % Update the sheeps individual action to show running from shepherd
            SheepMatrixUpdate(i,8) = 2;
            
        else % If not reacting to the shepherd, graze and move with probability of 0.05
             % and angular noise of 0.3
            RandForGraze = rand;
            if RandForGraze <= GrazingMovementProbability
                NewDirection = WeightOfInertia*PreviousDirection ...
                + WeightRepelFromOtherSheep*RepulsionFromOtherSheep;
                
                % Normalised new direction heading
                NormalisedNewDirection = (1/(sqrt(NewDirection(1,1)^2 + NewDirection(1,2)^2))*NewDirection);
                
                % Updated position movements: the randsrc function has equal
                % probability of either -1 or 1 so the sheep don't always move
                % to the top right of the env
                SheepMatrixUpdate(i,1) = SheepMatrix(i,1) + randsrc(1,1,[-1,1;0.5,0.5])*SheepStep*NormalisedNewDirection(1,1); %New x-coordinate
                SheepMatrixUpdate(i,2) = SheepMatrix(i,2) + randsrc(1,1,[-1,1;0.5,0.5])*SheepStep*NormalisedNewDirection(1,2); %New y-coordinate
                
                % New direction angle with added angular noise 
                SheepMatrixUpdate(i,3) = NoiseLevel*atan2(NormalisedNewDirection(1,2),NormalisedNewDirection(1,1));
                
                % Preserve the index of the sheep
                SheepMatrixUpdate(i,5) = SheepMatrix(i,5);

                % Show the sheeps individual action is wandering
                SheepMatrixUpdate(i,8) = 1;
                  
            else
            SheepMatrixUpdate(i,:) = SheepMatrix(i,:);

            % Show the sheeps individual action is standing
            SheepMatrixUpdate(i,8) = 0;
            end
        end

        % Fix the boundary condition
        XNew = SheepMatrixUpdate(i,1);
        YNew = SheepMatrixUpdate(i,2);

        if XNew < MinX
            SheepMatrixUpdate(i,1) = MinX;
            SheepMatrixUpdate(i,3) = 0.0 - SheepMatrixUpdate(i,3);
        end
        if XNew > MaxX
            SheepMatrixUpdate(i,1) = MaxX;
            SheepMatrixUpdate(i,3) = 0.0 - SheepMatrixUpdate(i,3);
        end
        if YNew < MinY
            SheepMatrixUpdate(i,2) = MinY;
            SheepMatrixUpdate(i,3) = 0.0 - SheepMatrixUpdate(i,3);
        end
        if YNew > MaxY
            SheepMatrixUpdate(i,2) = MaxY;
            SheepMatrixUpdate(i,3) = 0.0 - SheepMatrixUpdate(i,3);
        end
    end


end

end

     

