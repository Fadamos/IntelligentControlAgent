function SheepForces = SheepCalculations(i,SheepMatrix,NumSheepNeighbours,ShepherdMatrix, ...
    RadiusSheep,RadiusShepherd,CollisionRangeIndex,DistanceToGoal,Goal,SheepNotInGoalIndex, ...
    NumberOfSheepNotInGoal)

% INPUTS
% SheepMatrix        = Sheep population matrix
% NumSheepNeighbours = Number of sheep neighbours
% ShepherdPosition   = Shepherd position coordinates
% RadiusSheep        = Radius of the sheep
% RadiusShepherd     = Radius of the shepherd

% OUTPUTS
% RepulsionFromOtherSheep = Direction of repulsion from other sheep
% RepulsionFromShepherd   = Direction of repulsion from shepherd
% AttractionToOtherSheep  = Direction of attract to other sheep
% DistanceToShepherd      = Distance to shepherd

NumberOfSheep = size(SheepMatrix,1);
NumberOfShepherds = size(ShepherdMatrix,1);

%% Call SheepSeparationLibrary to determine the sheep-sheep separation level
CollisionRange = SheepSeparationLibrary(CollisionRangeIndex); %RadiusSheep = 2*RadiusSheep;

NearestNeighbours             = zeros(NumberOfSheep,3);
countSheep                    = 0;
countShepherds                = 0;
SeenAShepherd                 = 0;
RepulsionVectors              = [0,0];
RepulsionFromShepherds        = [0,0];
RepulsionVectorsFromShepherds = [0,0];
TotalRepulsionFromShepherds   = [0,0];
AttractionToOtherSheep        = [0,0];
ShepherdsTooCloseToSheep      = zeros(1,2);

% Only calculate forces for those not in the goal area
if SheepMatrix(i,6) == 0

    %% Repulsion vectors from shepherds
    for k = 1:NumberOfShepherds
        VectorFromShepherdToSheep = [SheepMatrix(i,1)-ShepherdMatrix(k,1), SheepMatrix(i,2)-ShepherdMatrix(k,2)];
        DistanceToShepherd = sqrt(VectorFromShepherdToSheep(1,1)^2 + VectorFromShepherdToSheep(1,2)^2); % Distance from shepherd
        if DistanceToShepherd < RadiusShepherd % If the shepherd is within RadiusShepherd
            countShepherds = countShepherds + 1;
            SeenAShepherd = 1;
            ShepherdsTooCloseToSheep(countShepherds,:) = [ShepherdMatrix(k,1),ShepherdMatrix(k,2)];
        end
    end
    ShepherdsTooCloseToSheep = ShepherdsTooCloseToSheep(1:countShepherds,:); % Reduce it to only the size it needs to be
    SizeShepherdsTooCloseToSheep = size(ShepherdsTooCloseToSheep,1);
    
    if SizeShepherdsTooCloseToSheep > 0 
        for j = 1:SizeShepherdsTooCloseToSheep % For each shepherd within distance
            VectorFromShepherdToSheep = [SheepMatrix(i,1)-ShepherdsTooCloseToSheep(j,1), SheepMatrix(i,2)-ShepherdsTooCloseToSheep(j,2)];
            DistanceVectorFromShepherdToSheep = sqrt(VectorFromShepherdToSheep(1,1)^2 + VectorFromShepherdToSheep(1,2)^2);
            EachRepulsionVector = (1/DistanceVectorFromShepherdToSheep^2) * VectorFromShepherdToSheep; % Relative strength is inversly proportional to distance.
            TotalRepulsionFromShepherds=TotalRepulsionFromShepherds + EachRepulsionVector; % Add upp all repulsion vectors
        end
        RepulsionFromShepherds = (1/sqrt(TotalRepulsionFromShepherds(1,1)^2 ...
            + TotalRepulsionFromShepherds(1,2)^2))*TotalRepulsionFromShepherds;
    end
    
    %% Calculate distance from sheep i to all other sheep not in goal
    DistanceToOtherSheepNotInGoal = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1)-SheepMatrix(i,1)*ones(NumberOfSheepNotInGoal(1),1)).^2 ...
        + (SheepMatrix(SheepNotInGoalIndex(:),2) - SheepMatrix(i,2)*ones(NumberOfSheepNotInGoal(1),1)).^2),SheepNotInGoalIndex(:)];%[1:NumberOfSheepNotInGoal(1)]'];
    SortedDistanceToOtherSheepNotInGoal = sortrows(DistanceToOtherSheepNotInGoal);
    
    %% Calculate attraction to other sheep not in goal
    if NumSheepNeighbours >= NumberOfSheepNotInGoal(1)
        NumSheepNeighbours = NumberOfSheepNotInGoal(1);
    end

    %% this next bit of code has an error when it doesnt attract to those outside the goal, 
    %% it attracts to IDs 1,2,3,... as the sheep ID is not being preserved in the neighbours 
    %% calculations
    AttractionToOtherSheepTotal = SortedDistanceToOtherSheepNotInGoal(1:NumSheepNeighbours,2);
    for j = 1:NumSheepNeighbours
        AttractionToOtherSheepLocal(j,:) = [SheepMatrix(AttractionToOtherSheepTotal(j,1),1),SheepMatrix(AttractionToOtherSheepTotal(j,1),2)];
    end
                                                                                         
    AttractionToOtherSheepLCM = (1/NumSheepNeighbours)*[sum(AttractionToOtherSheepLocal(:,1)), ...
        sum(AttractionToOtherSheepLocal(:,2))] - [SheepMatrix(i,1),SheepMatrix(i,2)];
    AttractionToOtherSheep = (1/sqrt(AttractionToOtherSheepLCM(1,1)^2 ...
        + AttractionToOtherSheepLCM(1,2)^2))*AttractionToOtherSheepLCM;
    
    %% Calculate matrix of nearest neighbours 
    % If sheep j within distance RadiusSheep from sheep i
    for j = 1:size(SheepMatrix,1)
        if j ~= i
            if (SheepMatrix(i,1)-SheepMatrix(j,1))^2 + (SheepMatrix(i,2)-SheepMatrix(j,2))^2 < CollisionRange^2
                countSheep = countSheep+1;
                NearestNeighbours(countSheep,:) = [SheepMatrix(j,1),SheepMatrix(j,2),SheepMatrix(j,3)];
            end
        end
    end
    
    %% Calculate repulsion from other sheep
    NearestNeighbours = NearestNeighbours(1:countSheep,:);
    SizeNearestNeighbours = size(NearestNeighbours,1);
    
    if SizeNearestNeighbours > 0
        for j = 1:SizeNearestNeighbours % For each neighbour
            NearestNeighbourToSheepVector = [SheepMatrix(i,1) - NearestNeighbours(j,1), ...
                SheepMatrix(i,2) - NearestNeighbours(j,2)];
            DistanceToNearestNeighbour = sqrt(NearestNeighbourToSheepVector(1,1)^2 ...
                + NearestNeighbourToSheepVector(1,2)^2);
            % Relative strength is inversly proportional to distance.
            RepulsionVectorStrength = (1/DistanceToNearestNeighbour^2)*NearestNeighbourToSheepVector;
            RepulsionVectors = RepulsionVectors+RepulsionVectorStrength; % Add upp all repulsion vectors
        end
        RepulsionFromOtherSheep = (1/sqrt(RepulsionVectors(1,1)^2 + RepulsionVectors(1,2)^2))*RepulsionVectors;
    else
        RepulsionFromOtherSheep = [0,0]; % If no neighbour, no new direction.
    end
end

SheepForces = [RepulsionFromOtherSheep;RepulsionFromShepherds;AttractionToOtherSheep; ...
    DistanceToShepherd,SeenAShepherd];
