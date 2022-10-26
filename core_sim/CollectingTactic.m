function CollectingTacticCalc = CollectingTactic(CollectingTacticIndex,SheepMatrix,SheepNotInGoalIndex, ...
                SheepNotInGoalGCM,SheepNotInGoalNumber,RadiusSheep,NumSheep,Goal,ShepherdMatrix,y, ...
                SheepIndexInBiggestCluster,NumSheepInCluster,BiggestClusterLCM)
% Author: Daniel Baxter
% LastModified: 3-July-2022
% Explanation: This function calculates the target separated sheep given a
% particular collecting tactic


    switch CollectingTacticIndex  
        case 'F2H' % Furthest astray sheep to giant cluster first -- Strombom base-case 
            % Find sheep furthest away from the LCM not in goal **F2H**
            SheepDistanceFromLCM = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1) - BiggestClusterLCM(1,1)*ones(SheepNotInGoalNumber(1),1)).^2 ...
                + (SheepMatrix(SheepNotInGoalIndex(:),2) - BiggestClusterLCM(1,2)*ones(SheepNotInGoalNumber(1),1)).^2),SheepMatrix(SheepNotInGoalIndex(:),5)];
            SortedSheepDistanceFromLCM = sortrows(SheepDistanceFromLCM,'descend');
            IndexOfFurthestSheepToLCM = SortedSheepDistanceFromLCM(1,2); % Index of furthest sheep to LCM
            CollectingTacticCalculations = [SheepMatrix(IndexOfFurthestSheepToLCM,1) SheepMatrix(IndexOfFurthestSheepToLCM,2)];
            IndexOfTargetSheep = IndexOfFurthestSheepToLCM;
            CollectingTacticNumber = 1;

        case 'C2H' % Closest astray sheep to giant cluster first 
            % Find the closest separated sheep to the GCM **C2H**
            SheepDistanceFromLCM = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1) - BiggestClusterLCM(1,1)*ones(SheepNotInGoalNumber(1),1)).^2 ...
                + (SheepMatrix(SheepNotInGoalIndex(:),2) - BiggestClusterLCM(1,2)*ones(SheepNotInGoalNumber(1),1)).^2),SheepMatrix(SheepNotInGoalIndex(:),5)];
            SortedSheepDistanceFromLCM = sortrows(SheepDistanceFromLCM);
            SeparatedSheepDistances = sortrows(SortedSheepDistanceFromLCM(find(SheepDistanceFromLCM(:,1) > RadiusSheep*NumSheep^(2/3)),:));
            EmptyCheck = isempty(SeparatedSheepDistances);
            if EmptyCheck == 0 
                ClosestSeparatedSheepToLCMDistance = SeparatedSheepDistances(1,1);
                IndexClosestSeparatedSheepToLCM = SeparatedSheepDistances(1,2);
            end
            CollectingTacticCalculations = [SheepMatrix(IndexClosestSeparatedSheepToLCM,1) SheepMatrix(IndexClosestSeparatedSheepToLCM,2)];
            IndexOfTargetSheep = IndexClosestSeparatedSheepToLCM;
            CollectingTacticNumber = 2;

        case 'F2G' % Furthest astray sheep to goal first
            % Find sheep furthest away from the goal **F2G**
            SheepDistanceToGoal = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1) - Goal(1)*ones(SheepNotInGoalNumber(1),1)).^2 ...
                + (SheepMatrix(SheepNotInGoalIndex(:),2) - Goal(2)*ones(SheepNotInGoalNumber(1),1)).^2),SheepMatrix(SheepNotInGoalIndex(:),5)];
            SortedSheepDistanceToGoal = sortrows(SheepDistanceToGoal,'descend');
            IndexOfFuthestSheepToGoal = SortedSheepDistanceToGoal(1,2); % Index of furthest sheep to goal
            CollectingTacticCalculations = [SheepMatrix(IndexOfFuthestSheepToGoal,1) SheepMatrix(IndexOfFuthestSheepToGoal,2)];
            IndexOfTargetSheep = IndexOfFuthestSheepToGoal;
            CollectingTacticNumber = 3;

        case 'F2D' % Furthest astray sheep to dog first
            % Find sheep furthest to the shepherd **F2D**
            SheepDistanceToShepherd = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1) - ShepherdMatrix(y,1)*ones(SheepNotInGoalNumber(1),1)).^2 ...
                + (SheepMatrix(SheepNotInGoalIndex(:),2) - ShepherdMatrix(y,2)*ones(SheepNotInGoalNumber(1),1)).^2),SheepMatrix(SheepNotInGoalIndex(:),5)];
            SortedSheepDistanceFromShepherd = sortrows(SheepDistanceToShepherd,'descend');
            IndexOfFurthestSheepToShepherd = SortedSheepDistanceFromShepherd(1,2); % Index of furthest sheep to dog
            CollectingTacticCalculations = [SheepMatrix(IndexOfFurthestSheepToShepherd,1) SheepMatrix(IndexOfFurthestSheepToShepherd,2)];
            IndexOfTargetSheep = IndexOfFurthestSheepToShepherd;
            CollectingTacticNumber = 4;

        case 'C2D' % Closest astray sheep to dog first
            % Find sheep closest to the shepherd **C2D**
            SheepDistanceToShepherd = [sqrt((SheepMatrix(SheepNotInGoalIndex(:),1) - ShepherdMatrix(y,1)*ones(SheepNotInGoalNumber(1),1)).^2 ...
                + (SheepMatrix(SheepNotInGoalIndex(:),2) - ShepherdMatrix(y,2)*ones(SheepNotInGoalNumber(1),1)).^2),SheepMatrix(SheepNotInGoalIndex(:),5)];
            SortedSheepDistanceToShepherd = sortrows(SheepDistanceToShepherd);
            IndexOfClosestSheepToShepherd = SortedSheepDistanceToShepherd(1,2); % Index of closest sheep to dog
            CollectingTacticCalculations = [SheepMatrix(IndexOfClosestSheepToShepherd,1) SheepMatrix(IndexOfClosestSheepToShepherd,2)];
            IndexOfTargetSheep = IndexOfClosestSheepToShepherd;
            CollectingTacticNumber = 5;
    end
    
    CollectingTacticCalc = [CollectingTacticCalculations,IndexOfTargetSheep,CollectingTacticNumber];
end 