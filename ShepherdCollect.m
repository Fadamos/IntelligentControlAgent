function ShepherdCollectiveUpdate = ShepherdCollect(SheepMatrix,ShepherdMatrix,Goal, ...
            RadiusSheep,RadiusShepherd,DogSpeedDifferentialIndex,CollectingTacticIndex, ...
            CohesionRange,SimulationTime,DrivingTacticIndex,BoundarySize,SheepIndexInBiggestCluster, ...
            NumSheepInCluster,BiggestClusterLCM,SheepNotInGoalIndex,SheepNotInGoalNumber,SheepNotInGoalGCM)
% Author: Daniel Baxter
% LastModified: 3-July-2022
% Explanation: This function 

%% INPUTS
% SheepMatrix = Sheep population matrix
% ShepherdPosition = Shepherd position matrix
% Target = Target position [x coord,y coord]
% RadiusSheep = Radius of the sheep

%% OUTPUTS
% NewShepherdDirection = New normalised shepherd directional heading
% NumSeparations = The number of sheep separations during the simulation
% TimeSpentCollecting = The amount of time steps the shepherd spent in collecting mode
% TimeSpentDriving = The amount of time steps the shepherd spent in driving mode

%% Parameters
TimeSpentCollecting  = 0;    % Initialise the time spent collecting
TimeSpentDriving     = 0;    % Initialise the time spent driving
TimeSpentStopped     = 0;    % Initialise the time spent stopped
NumSeparations       = 0;    % Initialise the number of separations
NoiseLevel           = 0.3;  % e: relative strength of angular noise
NumSepsNewPlot       = 0;    % Number of sheep separations per time step
NumSheep             = size(SheepMatrix,1);% Number of sheep
NumShepherds         = size(ShepherdMatrix,1); % Number of shepherds
MinX                 = BoundarySize(1);
MaxX                 = BoundarySize(2);
MinY                 = BoundarySize(3);
MaxY                 = BoundarySize(4);

% ShepherdRepulsionFactor  = 500; % Shepherd to shepherd repulsion factor
% ShepherdAttractionFactor = 0.5; % Shepherd to shepherd attraction factor

ShepherdCollectiveUpdate = zeros(NumShepherds,8); % For simultaneous update of shepherds

    for y = 1:NumShepherds
    
        % get the sheepdogs speed differential
        ShepherdStep = DogSpeedLibrary(DogSpeedDifferentialIndex);
        ShepherdCollectiveUpdate(y,4) = 0; % update to show which sheep ID the shepherd is targetting
        ShepherdCollectiveUpdate(y,6) = 0; % individual action standing (0) running (1)

    %     % These are the shepherd-shepherd calculations when multiplt shepherds are used
    %     ShepherdForces=ShepherdCalculations(y,NumShepherds,RadiusShepherd,ShepherdMatrix);
    %     RepulsionFromOtherShepherds=ShepherdForces(1,:);% Direction of repulsion from other shepherds
    %     AttractionToOtherShepherds=ShepherdForces(2,:); % Direction of attraction to other shepherds
    %     NumberOfShepherdNeighbours=ShepherdForces(3,1); % Number of nearest neighbours
        
        % Find sheep furthest away from the LCM not in goal 
        SheepDistanceFromLCM = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1) - BiggestClusterLCM(1,1)*ones(SheepNotInGoalNumber(1),1)).^2 ...
            + (SheepMatrix(SheepNotInGoalIndex(:),2) - BiggestClusterLCM(1,2)*ones(SheepNotInGoalNumber(1),1)).^2),SheepMatrix(SheepNotInGoalIndex(:),5)];
        SortedSheepDistanceFromLCM = sortrows(SheepDistanceFromLCM,'descend');
    
        % Find sheep closest to the shepherd
        SheepDistanceToShepherd = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1) - ShepherdMatrix(y,1)*ones(SheepNotInGoalNumber(1),1)).^2 ...
            + (SheepMatrix(SheepNotInGoalIndex(:),2) - ShepherdMatrix(y,2)*ones(SheepNotInGoalNumber(1),1)).^2),SheepMatrix(SheepNotInGoalIndex(:),5)];
        SortedSheepDistanceToShepherd = sortrows(SheepDistanceToShepherd);
        IndexOfClosestSheepToShepherd = SortedSheepDistanceToShepherd(1,2); % Index of closest sheep to dog
         
        % Shepherd-sheep calculations
        GoalToLCMVector = BiggestClusterLCM - Goal; % Vector from Goal to LCM
        GoalToShepherdVector = [ShepherdMatrix(y,1) - Goal(1,1) , ShepherdMatrix(y,2) - Goal(1,2)]; % Vector from Target to Shepherd y
        FurthestSheepFromLCMDistance = SortedSheepDistanceFromLCM(1,1); % Distance from the sheep furthest from the GCM to the GCM
        ClosestSheepToShepherdCoords = SheepMatrix(IndexOfClosestSheepToShepherd,1:2); % Coordinates of the sheep closest to the shepherd
        ClosestSheepToShepherdDistance = SortedSheepDistanceToShepherd(1,1); % Distance from the sheep closest to the shepherd
    
        % if the shepherd is too close to a sheep -> stop
        if ClosestSheepToShepherdDistance < 3*RadiusSheep 
            SheepToShepherdVector = [ShepherdMatrix(y,1) - ClosestSheepToShepherdCoords(1,1), ...
                ShepherdMatrix(y,2) - ClosestSheepToShepherdCoords(1,2)]; % Direction from sheep to shepherd
            % Add angular noise to the x and y vector components
            SheepToShepherdVector(1,1) = cos(SheepToShepherdVector(1,1))*NoiseLevel + SheepToShepherdVector(1,1);
            SheepToShepherdVector(1,2) = sin(SheepToShepherdVector(1,2))*NoiseLevel + SheepToShepherdVector(1,2);
            % Shepherd direction is direction straight away from sheep + noise + attraction & repulsion from other shepherds
            ShepherdDirection = SheepToShepherdVector;
            ShepherdCollectiveUpdate(y,6) = 0; % dog is standing still
          
        % if the furthest sheep is considered separated -> collect
        else
            CollectingTacticOutput = CollectingTactic(CollectingTacticIndex,SheepMatrix,SheepNotInGoalIndex, ...
                SheepNotInGoalGCM,SheepNotInGoalNumber,RadiusSheep,NumSheep,Goal,ShepherdMatrix,y, ...
                SheepIndexInBiggestCluster,NumSheepInCluster,BiggestClusterLCM);
            SheepTargetCoordsX = CollectingTacticOutput(1);
            SheepTargetCoordsY = CollectingTacticOutput(2);
            SheepTargetCoords = [SheepTargetCoordsX SheepTargetCoordsY];
            SheepTargetID = CollectingTacticOutput(3);
            ShepherdCollectiveUpdate(y,4) = SheepTargetID; % update to show which sheep ID the shepherd is targetting
            
            SheepTargetVector = SheepTargetCoords - BiggestClusterLCM;
            NormalisedSheepTargetVector = (1/sqrt(SheepTargetVector(1,1)^2 ...
                + SheepTargetVector(1,2)^2))*SheepTargetVector;
            ShepherdCollectingPosition = GoalToLCMVector + SheepTargetVector ...
                + RadiusSheep*NormalisedSheepTargetVector;
            % Add angular noise to the x and y vector components
            ShepherdCollectingPosition(1,1) = cos(ShepherdCollectingPosition(1,1))*NoiseLevel + ShepherdCollectingPosition(1,1);
            ShepherdCollectingPosition(1,2) = sin(ShepherdCollectingPosition(1,2))*NoiseLevel + ShepherdCollectingPosition(1,2);
            % Shepherd direction the position behind the furthest sheep + inter-shepherd attraction and repulsion
            ShepherdDirection = ShepherdCollectingPosition - GoalToShepherdVector;
            ShepherdCollectiveUpdate(y,6) = 1; % dog is running

            ShepherdCollectiveUpdate(y,7) = ShepherdCollectingPosition(1,1);
            ShepherdCollectiveUpdate(y,8) = ShepherdCollectingPosition(1,2);
    
        end
         
         NewShepherdDirection = 1/(sqrt(ShepherdDirection(1,1)^2 + ShepherdDirection(1,2)^2))*ShepherdDirection;
         % Update shepherds direction in DEGREES
         ShepherdCollectiveUpdate(y,3) = rad2deg(atan2(NewShepherdDirection(1,2),NewShepherdDirection(1,1)));
         
         % Update shepherd y's position in the matrix
         ShepherdCollectiveUpdate(y,1) = ShepherdMatrix(y,1) + ShepherdStep*NewShepherdDirection(1,1); 
         ShepherdCollectiveUpdate(y,2) = ShepherdMatrix(y,2) + ShepherdStep*NewShepherdDirection(1,2); 
         
         XNewShepherd = ShepherdCollectiveUpdate(y,1);
         YNewShepherd = ShepherdCollectiveUpdate(y,2);

         % use the full environment as containment
         if XNewShepherd < MinX
             ShepherdCollectiveUpdate(y,1) = MinX;
         end
         if XNewShepherd > MaxX
             ShepherdCollectiveUpdate(y,1) = MaxX;
         end
         if YNewShepherd < MinY
             ShepherdCollectiveUpdate(y,2) = MinY;
         end
         if YNewShepherd > MaxY
             ShepherdCollectiveUpdate(y,2) = MaxY;
         end
         
         % Preserve the index of shepherd y
         ShepherdCollectiveUpdate(y,5) = ShepherdMatrix(y,5);
    
    end


end



