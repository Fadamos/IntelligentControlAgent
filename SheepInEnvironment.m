function Output = SheepInEnvironment(NumberOfSheep, Iteration, SheepMatrix, Goal, GoalRadius)
% Author: Hussein Abbass
% LastModified: 19-June-2022 - Baxter
% Explanation: This function calculates whether a sheep is within the
% goal 

%% This is the end condition where if a sheep goes in the goal area, it cannot be influenced or 
%  influence others. It simply randomly moves within the bounds of the goal
X = SheepMatrix(:,1) - Goal(1);
Y = SheepMatrix(:,2) - Goal(2);
DistancesFromGoal = hypot(X,Y);

%% Find the sheep not yet in the goal area
NumbersWithinGoal = sum(DistancesFromGoal <= GoalRadius);
SheepsWithinGoalIndex = find(DistancesFromGoal <= GoalRadius);

if NumbersWithinGoal > 0 
    for i = 1 : NumbersWithinGoal
        SheepMatrix(SheepsWithinGoalIndex(i),6) = 1;
    end
end

Output = [SheepMatrix];