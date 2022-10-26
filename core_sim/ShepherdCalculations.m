function ShepherdForces = ShepherdCalculations(y,NumShepherds,RadiusShepherd,ShepherdMatrix) 
   
% INPUTS
% y              = Indexed number of shepherd being applied to function
% NumShepherds   = The number of shepherds in the field
% RadiusShepherd = Radius of shepherd
% ShepherdMatrix = Position matrix of shepherds

% OUTPUTS
% RepulsionFromOtherShepherds = Direction of repulsion from other shepherds
% AttractionToOtherShepherds  = Direction of attraction to other shepherds
% NumberOfShepherdNeighbours  = Number of nearest neighbours shepherds

NumShepherdNeighbours=zeros(NumShepherds,2); % Initialise matrix
countShepherds                   = 0;     % Used to keep recored of number of shepherds
CombinedShepherdRepulsionVectors = [0,0]; % Initialise vector
RepulsionFromOtherShepherds      = [0,0]; % Initialise vector
SeparationDistanceStrengthFactor = 2;     % Factor to keep the shepherds separated
RadiusShepherd                   = 2*RadiusShepherd; % create a radius where RadiusShepherd exists between both shepherds

% Replusion vectors between shepherds
for j = 1:NumShepherds 
    if j ~= y % if j is not equal to y
        if ((ShepherdMatrix(y,1)-ShepherdMatrix(j,1))^2 + (ShepherdMatrix(y,2) - ShepherdMatrix(j,2))^2) < RadiusShepherd % If shepherd j within dist RadiusShepherd from shepherd y
            countShepherds = countShepherds+1;
            NumShepherdNeighbours(countShepherds,:) = [ShepherdMatrix(j,1),ShepherdMatrix(j,2)];
        end
    end
end
NumShepherdNeighbours = NumShepherdNeighbours(1:countShepherds,:); % Reduce it to only the size it needs to be 
NumberOfShepherdNeighbours = size(NumShepherdNeighbours,1);

if NumberOfShepherdNeighbours > 0 
    for j = 1 : NumberOfShepherdNeighbours % For each neighbour
        NearestNeighbourToShepherdVector = [ShepherdMatrix(y,1) - NumShepherdNeighbours(j,1), ...
            ShepherdMatrix(y,2) - NumShepherdNeighbours(j,2)];
        DistanceOfShepherds = sqrt(NearestNeighbourToShepherdVector(1,1)^2 ...
            + NearestNeighbourToShepherdVector(1,2)^2);
        ShepherdRepulsionStrength = (1/DistanceOfShepherds^2) * NearestNeighbourToShepherdVector; % Relative strength is inversly proportional to distance.
        CombinedShepherdRepulsionVectors = CombinedShepherdRepulsionVectors ...
            + ShepherdRepulsionStrength; % Add upp all repulsion vectors
    end
    RepulsionFromOtherShepherds = (1/sqrt(CombinedShepherdRepulsionVectors(1,1)^2 ...
        + CombinedShepherdRepulsionVectors(1,2)^2)) * CombinedShepherdRepulsionVectors * SeparationDistanceStrengthFactor;
end

% Topological attraction between shepherds
DistanceBetweenShepherdAndOtherShepherds = [sqrt((ShepherdMatrix(:,1) - ShepherdMatrix(y,1)*ones(NumShepherds,1)).^2 ...
    + (ShepherdMatrix(:,2) - ShepherdMatrix(y,2)*ones(NumShepherds,1)).^2),[1:NumShepherds]'];
SortedDistanceBetweenShepherdAndOtherShepherds = sortrows(DistanceBetweenShepherdAndOtherShepherds);
ShepherdAttractionList = SortedDistanceBetweenShepherdAndOtherShepherds(2:NumShepherds,2); % Adds them all except itself

for j = 1:NumShepherds - 1
    ShepherdAttractionToOtherShepherds(j,:) = [ShepherdMatrix(ShepherdAttractionList(j,1),1), ...
        ShepherdMatrix(ShepherdAttractionList(j,1),2)];
end

ShepherdCenterOfMass = (1/NumShepherds) * [sum(ShepherdAttractionToOtherShepherds(:,1)) - ShepherdMatrix(y,1), ...
    sum(ShepherdAttractionToOtherShepherds(:,2)) - ShepherdMatrix(y,2)]; % center of mass
AttractionToOtherShepherds = (1/sqrt(ShepherdCenterOfMass(1,1)^2 + ShepherdCenterOfMass(1,2)^2)) * ShepherdCenterOfMass; % normalised center of mass

ShepherdForces = [RepulsionFromOtherShepherds;AttractionToOtherShepherds; ...
    NumberOfShepherdNeighbours,NumberOfShepherdNeighbours]; % put NumberOfShepherdNeighbours 2x for cat sizes
