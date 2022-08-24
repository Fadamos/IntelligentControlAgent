function BiggestClusterOutput = FindBiggestCluster(SheepMatrix,SheepNotInGoalIndex,SheepNotInGoalNumber, ...
    CohesionRange)
% Author: Daniel Baxter
% LastModified: 11-July-2022
% Explanation: This function uses k-means to find the biggest cluster of
% sheep that are not in the goal, how many sheep are in the cluster, and
% the radius of the cluster.

    MaxNumberOfClusters = ceil(SheepNotInGoalNumber / 2);

    k = 1;
    % make X equal the x & y positions of remaining sheep NOT in the goal
    X = SheepMatrix(SheepNotInGoalIndex(:),1:2);
    CompactClusterFound = false;
    NumSheepInBiggestCluster = 0;

    while k <= MaxNumberOfClusters
        if CompactClusterFound == false
            %% HERE IS THE ISSUE
            % the sheep ID numbers are not being preserved during the kmeans calculations. If one sheep enters 
            % the goal, WhichCLusterSHeepIsIn goes from 1-39 (all 1's for the first round of kmeans), then the
            % "find(WhichClusterSheepIsIn)==BiggestClusterK returns numbers 1-39 which is then transposed back
            % to Sheep ID numbers as being in the cluster. So the issue is that if sheep 11 enters the goal, 
            % it will disappear from the list but every other ID moves up to take its place. So, when
            % transposed back into positions of IDs, it uses IDs 1-39, not the 40 minus sheep 11.
            [SheepMatrix(SheepNotInGoalIndex(:),7),ClusterCenteroid] = kmeans(X,k,'Distance','sqEuclidean','Replicates',10);
            [BiggestClusterK,NumSheepInBiggestCluster] = mode(SheepMatrix(SheepNotInGoalIndex(:),7));
            SheepIndexInBiggestCluster = find(SheepMatrix(:,7)==BiggestClusterK); 
            DistBetweenFurthestSheepInBiggestCluster = max(pdist(SheepMatrix(SheepIndexInBiggestCluster(:),1:2)));
            
            if DistBetweenFurthestSheepInBiggestCluster <= CohesionRange
                CompactClusterFound = true;
                BiggestCluster = NumSheepInBiggestCluster;
%                 BiggestCluster(1,2) = DistBetweenFurthestSheepInBiggestCluster;
                SheepIndexInBiggestCluster(:) = SheepIndexInBiggestCluster;
%                 % save all of them and determine which is the biggest out of all
%                 if BiggestCluster(k,1) > BiggestCluster(:,1)
%                     SheepIndexInBiggestCluster(:) = SheepIndexInBiggestCluster;
%                 end
            end
        
           
        end
        
        k = k+1;
    end
    % make BiggestCluster the same size as SheepIndexInBiggestCluster to output them both
%     NumToMultiply = size(SheepIndexInBiggestCluster(:,1));
%     BiggestCluster = BiggestCluster * ones(NumToMultiply(1),1);

    %% Output the sheep ID of the ones in the biggest cluster
    BiggestClusterOutput = [SheepIndexInBiggestCluster];
%     SortedSBiggestClusters = sortrows(BiggestCluster(:,1),'descend');
%     BiggestCluster = SortedSBiggestClusters(1);
%     BiggestClusterOutput = [SheepIndexInBiggestCluster];

% Implementing Find GiantCluster > SheepMatrix(:,1:2)
% MaxNumberOfCluster = Nremaining / 2;
% K = 1
% While k < MaxNumberOfCluster
% Apply kmeans
% Find largest cluster 
% Find the size of the largest cluster [number of sheep in the largest cluster]
% Calculate radius of the cluster
% If the cluster is compact
% Exit while loop and pass back the ID of the sheep forming the largest cluster
% Else
% K = k +1;
% End if
% End while
% Exit and pass back the ID of the sheep forming the largest cluster

    
end