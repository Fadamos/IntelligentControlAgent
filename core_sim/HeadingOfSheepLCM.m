function Output = HeadingOfSheepLCM(BiggestClusterLCM,SimulationTime)
% Author: Daniel Baxter
% LastModified: 03-Aug-2022
% Explanation: This function calculates the direction and then compass heading of the sheep in
% the target clusters LCM

% calculate the direction of the new move compared to the last position
SheepLCMDirectionVector = BiggestClusterLCM(SimulationTime,:) - BiggestClusterLCM(SimulationTime-1,:);
NewLCMDirection = 1/(sqrt(SheepLCMDirectionVector(1,1)^2 + SheepLCMDirectionVector(1,2)^2))*SheepLCMDirectionVector;
    
% New directional angle
SheepLCMDirectionUpdate = rad2deg(atan2(NewLCMDirection(1,2),NewLCMDirection(1,1)));

% calculate the compass heading of the sheep GCM heading
% SheepGCMHeading = CompassHeadings(SheepLCMDirectionUpdate);

Output = SheepLCMDirectionUpdate; % SheepLCMHeading;