classdef MARKERS
    % Author: Adam J Hepworth
    % LastModified: 8-Apr-2022
    % Explanaton: This class calculates each marker as a function, which
    % is called from a control script 
    
    %% Markers   
    % --- COMPLETE ---
    %Y   Situation Awareness
    %Y   Predation Risk 
    %Y   Synchronicity 
    %~   Cohesion
    %~   Separation (Given by distances)
    %~   Alignment
    %Y   Mission Speed Marker 
    %Y   Mission Completion Rate 
    %Y   Dynamic Body Acceleration
    %Y   Overall Dynamic Body Acceleration
    %Y   Speed  
    %Y 	Granger Causality 
    %~   Acceleration (covered by DBA) 
    %Y   Rate of Change (Angular Velocity) 
    %Y   Heading 
    %Y   Distance (for swarm summary only -- no individual calc)
    %~   Information Storage - need to confirm correct (gives total for the swarm) 
    %Y   Local Transfer Entropy
    %N   Global Transfer Entropy
    %Y   Dynamic Time Warping 
    %Y   Effort-To-Compress
    %Y   Lyapunov Exponent
    %Y   Node Degree (higher-level marker) 
    %Y   Cross Correlation Function
    %Y   Information Flow
    %Y   Influence Contribution Marker 
    %Y   Power Spectral (Spectral entroopy PSD) 
    %Y   Geometric Information Flow 
        
    % --- NOT IMPLEMENTING ---
    %   OUT - Compression Complexity Causality (ETC-based) <-- python based and needs to be imported to Matlab
    %   OUT - Geotaxi -- remove this from the list (it is not a real measure
    %   OUT - Topological Structure Marker <-- not a measure
    %   OUT - Lebesgue Measure
    %   OUT - Escape Trajectory <-- not a measure
    %   OUT - Trajectory Estimation <-- not a measure
    %   OUT - Polarisation
    %   OUT - Social Network Analysis (included as part of nodal analysis)  
    

    
    %% Methods 
        methods(Static)
            
            %% Lower level markers (M_L) as a transformation of sensed data
            
            %% Situation Awareness Marker
            function SituationAwarenessOutput = SituationAwarenessMarker(SheepX, SheepY, SheepDogX, SheepDogY, timeStep, numSheep, Epsilon, verbose)
                if ~exist('Epsilon', 'var')
                    Epsilon = 12; % vision corridor of Sheep agent 
                end
                if ~exist('verbose', 'var')
                    verbose = false; 
                end
                 
                ResultsSheepPositions = zeros(20,3);
                                
                SheepMatrix = [SheepX(timeStep,:)', SheepY(timeStep,:)']; % variable consistency to minimise changes to SSCI20 code 
                ShepherdMatrix = [SheepDogX(timeStep), SheepDogY(timeStep)]; 
                
                SheepGlobalCentreOfMass = MARKERS.CentreOfMassMarker(SheepX, SheepY, numSheep, timeStep);

                % Find distances between every point in set 1 to every point in set #2.
                % Return distance and index of farthest from every point in set #1.
                [distances, index] = pdist2([ShepherdMatrix(:,1), ShepherdMatrix(:,2)], [SheepMatrix(:,1), SheepMatrix(:,2)], 'euclidean', 'largest', 1);
                
                % Find max distance
                [maxDistance, indexOfMax] = max(distances);
                indexMax2 = indexOfMax;
                indexMax1 = index(indexOfMax);
                
                % Find min distances
                [minDistance, indexOfMin] = min(distances);
                indexMin2 = indexOfMin;
                indexMin1 = index(indexOfMin);
                
                % Get position into single points
                furthestSheepFromShepherdXPos=SheepMatrix(:,1);
                furthestSheepFromShepherdYPos=SheepMatrix(:,2);
                shepherdXPos=ShepherdMatrix(:,1);
                shepherdYPos=ShepherdMatrix(:,2);
                
                if verbose
                    % Draw a line between the two points farthest apart.
                    plot([furthestSheepFromShepherdXPos(indexMax2), shepherdXPos(indexMax1)], [furthestSheepFromShepherdYPos(indexMax2), shepherdYPos(indexMax1)], 'mo-', 'LineWidth', 1.25, 'MarkerSize', 15);
                    plot([furthestSheepFromShepherdXPos(indexMin2), shepherdXPos(indexMin1)], [furthestSheepFromShepherdYPos(indexMin2), shepherdYPos(indexMin1)], 'mo-', 'LineWidth', 1.25, 'MarkerSize', 15);

                    % Draw concentric rings around the shepherd that are based on the sheep distances between the closest and furthest sheep to divide them into "bins"
                    theta = linspace(0, 2*pi, 50);
                end
                
                %RingClosest = minDistance;
                %RingFurthest = maxDistance;
                deltaSheepMinMaxDist = maxDistance - minDistance;
                numBins = round(sqrt(length(SheepMatrix(:,1))));
                distBins = deltaSheepMinMaxDist/numBins;
                
                % Assign bin numbers to the rings
                for i=1:numBins
                    binRingDist(i,1)=minDistance+distBins*i;
                end
                
                if verbose
                    % Loop through and plot the LoS rings, 'bins' as a function of the sqrt of the number of sheep
                    for i=0:numBins
                        plot(cos(theta)*(distBins*i+minDistance)+shepherdXPos, sin(theta)*(distBins*i+minDistance)+shepherdYPos);
                        hold on
                    end
                end
                    
                % Calculate and draw the Convex-Hull and the Area and Volume 
                sheepPointForConvexHull = [SheepMatrix(:,1),SheepMatrix(:,2)];
                if ~isnan(sheepPointForConvexHull)
                    [sheepConvexHull, ~] = convhull(sheepPointForConvexHull);
                end
                
                if verbose 
                    plot(sheepPointForConvexHull(sheepConvexHull,1), sheepPointForConvexHull(sheepConvexHull,2));
                end

                % Situation Awareness Results Matrix
                % Save each sheeps position at time t and number of nearest neighbours Matrix = [xpos; ypos; kNN]
                for i=1:numSheep
                    ResultsSheepPositions(i,1) = SheepMatrix(i,1); % Save sheep x-pos for that timestep
                    ResultsSheepPositions(i,2) = SheepMatrix(i,2); % Save sheep y-pos for that timestep
                end

                % Save the shepherd position at time t matrix = [xpos; ypos]
                ResultsShepherdPositions(1,1)=ShepherdMatrix(1,1); % Save shepherd x-pos for that timestep
                ResultsShepherdPositions(1,2)=ShepherdMatrix(1,2); % Save shepherd y-pos for that timestep

                % Save the sheeps distance to the GCM, distance to shepherd, and bin number Matrix = [dist to GCM; dist to shep; bin number; min dist to convex-hull boundary]
                for i=1:numSheep
                    ResultsSheepDistances(1,i)=pdist2([SheepGlobalCentreOfMass(1,1), SheepGlobalCentreOfMass(1,2)], [SheepMatrix(i,1), SheepMatrix(i,2)], 'euclidean'); % Save dist between sheep i and GCM
                    ResultsSheepDistances(2,i)=pdist2([ShepherdMatrix(1,1), ShepherdMatrix(1,2)], [SheepMatrix(i,1), SheepMatrix(i,2)], 'euclidean'); % Save sheep y-pos for that timestep
                    % Calculate the distance between sheep i and the convex-hull boundary
                end

                % Line of Sight Calculations
                for p=1:numSheep
                    Slope = (SheepMatrix(p,2) - ShepherdMatrix(1,2)) / (SheepMatrix(p,1) - ShepherdMatrix(1,1));
                    Constant = SheepMatrix(p,2) - Slope * SheepMatrix(p,1);
                    for q=1:numSheep-1
                        if q ~= p
                            if (abs((SheepMatrix(q,2) - Slope * SheepMatrix(q,1) - Constant)) <= Epsilon) && (distances(:,q) < distances(p))
                                ResultsSheepPositions(p,3) = ResultsSheepPositions(p,3) + 1;
                            else
                                ResultsSheepPositions(p,3) = 0;
                            end
                        end
                    end 
                end

                SituationAwarenessOutput.ResultsSheepDistances = ResultsSheepDistances'; 
                SituationAwarenessOutput.ResultsSheepPositions = ResultsSheepPositions; 
                
                %  Equation: 
                %   SA_pi(i) = 1 / ( (d_(pi -> beta)^2) / ((d_(pi -> Gamma)) * (d_(pi->beta)max))) * (Theta+1) )
                %
                %  resultsSheepDistances = [dist to GCM; 
                %                           dist to shep; 
                %                           bin number; 
                %                           min dist to convex-hull boundary]
                % 
                %  ResultsSheepPositions = [xpos; 
                %                           ypos; 
                %                           kNN;
                %                           LoS Level]
                
                % setup calculations  
                distFromGCM = SituationAwarenessOutput.ResultsSheepDistances(:,1); 
                distFromShepherd = SituationAwarenessOutput.ResultsSheepDistances(:,2);
                blockingAgents = SituationAwarenessOutput.ResultsSheepPositions(:,3); 
                
                % calculate subordinate statistics 
                sheepDistToShepherdSquared = distFromShepherd.^2; 
                sheepDistToGCMMultipliedDistToShepherd = distFromShepherd .* distFromGCM;
                normDistToShepherd = sheepDistToShepherdSquared ./ sheepDistToGCMMultipliedDistToShepherd;
                saDenominator = normDistToShepherd .* (blockingAgents+1);

                % Calculate Agent SA for time time period 
                SituationAwarenessOutput.ResultSA = 1 ./ saDenominator; 
                SituationAwarenessOutput.LogResultSA = log(SituationAwarenessOutput.ResultSA);

            end
            
            %% Predation Risk Marker 
            function PredationRiskOutput = PredationRiskMarker(SheepX, SheepY, SheepDogX, SheepDogY, NumberOfSheep, timeStep, SheepRadius)
                if ~exist('SheepRadius', 'var')
                    SheepRadius = 2; % standard Strombom Model value 
                end

                %numberOfTimeSteps = 1;
                %numberOfShepherds = 1;
                numSheep = NumberOfSheep(timeStep); 
                                                
                SheepMatrix = nan(numSheep,3);
                SheepMatrix(:,1) = SheepX(timeStep,:)'; 
                SheepMatrix(:,2) = SheepY(timeStep,:)'; 
               
                % calculating kNN for PR element 2 and 3 -- cleaner implementation, but still not theta_pi_pi as discussed in the paper 
                [Idx,~] = rangesearch(SheepMatrix,SheepMatrix,SheepRadius);
                
                for i=1:size(Idx,1)
                    SheepMatrix(i,3) = size(Idx{i},2);
                end
                
                ShepherdMatrix = [SheepDogX(timeStep), SheepDogY(timeStep)]; 
                
                SheepGlobalCentreOfMass = MARKERS.CentreOfMassMarker(SheepX, SheepY, NumberOfSheep, timeStep);

                % Find distances between every point in set 1 to every point in set #2.
                % Return distance and index of farthest from every point in set #1.
                [distances, ~] = pdist2([ShepherdMatrix(:,1), ShepherdMatrix(:,2)], [SheepMatrix(:,1), SheepMatrix(:,2)], 'euclidean', 'largest', 1);
                
                % Find max distance
                [maxDistance, ~] = max(distances);
                
                % Find min distances
                [minDistance, ~] = min(distances);

                deltaSheepMinMaxDist = maxDistance - minDistance;
                numBins = round(sqrt(length(SheepMatrix(:,1))));
                distBins = deltaSheepMinMaxDist/numBins;

                % Calculate and draw the Convex-Hull and the Area and Volume 
                sheepPointForConvexHull = [SheepMatrix(:,1),SheepMatrix(:,2)];
                if ~isnan(sheepPointForConvexHull)
                    [sheepConvexHull,~] = convhull(sheepPointForConvexHull);
                end

                for i=1:numSheep
                    ResultsSheepPositions(i,1) = SheepMatrix(i,1); % Save sheep x-pos for that timestep
                    ResultsSheepPositions(i,2) = SheepMatrix(i,2); % Save sheep y-pos for that timestep
                end
                
                PredRisk = nan(3,numSheep);
                
                for i=1:numSheep
                    ResultsSheepDistances(1,i)=pdist2([SheepGlobalCentreOfMass(1,1), SheepGlobalCentreOfMass(1,2)], [SheepMatrix(i,1), SheepMatrix(i,2)], 'euclidean'); % Save dist between sheep i and GCM
                    ResultsSheepDistances(2,i)=pdist2([ShepherdMatrix(1,1), ShepherdMatrix(1,2)], [SheepMatrix(i,1), SheepMatrix(i,2)], 'euclidean'); % Save sheep y-pos for that timestep
                    if (minDistance<=ResultsSheepDistances(2,i)) && (ResultsSheepDistances(2,i)<=(minDistance+distBins))
                        ResultsSheepDistances(3,i)=1;
                        PredRisk(1,i) = 1/1;%bin ID capture only
                        PredRisk(2,i) = numSheep/(SheepMatrix(i,3)+1);
                        PredRisk(3,i) = (1/1)*(numSheep/(SheepMatrix(i,3)+1));
                        %is the sheep in bin one and on the chull boundary && the closest sheep to the shepherd
                        if ismember(i,sheepConvexHull)&&ResultsSheepDistances(2,i)==minDistance
                            closestShoid = i;
                        end
                    elseif ((minDistance+distBins)<ResultsSheepDistances(2,i)) && (ResultsSheepDistances(2,i)<=(minDistance+2*distBins))
                        ResultsSheepDistances(3,i)=2;
                            PredRisk(1,i) = 1/2;%bin ID capture only
                            PredRisk(2,i) = numSheep/(SheepMatrix(i,3)+1);
                            PredRisk(3,i) = (1/2)*(numSheep/(SheepMatrix(i,3)+1));
                    elseif ((minDistance+2*distBins)<ResultsSheepDistances(2,i)) && (ResultsSheepDistances(2,i)<=(minDistance+3*distBins))
                        ResultsSheepDistances(3,i)=3;
                            PredRisk(1,i) = 1/3;%bin ID capture only
                            PredRisk(2,i) = numSheep/(SheepMatrix(i,3)+1);
                            PredRisk(3,i) = (1/3)*(numSheep/(SheepMatrix(i,3)+1));
                    elseif ((minDistance+2*distBins)<ResultsSheepDistances(2,i)) && (ResultsSheepDistances(2,i)<=(minDistance+4*distBins))
                        ResultsSheepDistances(3,i)=4;
                            PredRisk(1,i) = 1/4;%bin ID capture only
                            PredRisk(2,i) = numSheep/(SheepMatrix(i,3)+1);
                            PredRisk(3,i) = (1/4)*(numSheep/(SheepMatrix(i,3)+1));
                    else
                        ResultsSheepDistances(3,i)=5;
                            PredRisk(1,i) = 1/5;%bin ID capture only
                            PredRisk(2,i) = numSheep/(SheepMatrix(i,3)+1);
                            PredRisk(3,i) = (1/5)*(numSheep/(SheepMatrix(i,3)+1));
                    end
                end
                
                PredationRiskOutput = PredRisk';
                
            end 
            
            %% Information Theory Markers
            function InfThOutput = InfThMarkers(SheepX, SheepY, SheepDogX, SheepDogY, NumberOfSheep, timeTicks, windowInfTh)                
                if ~exist('timeTicks', 'var')
                    timeTicks = size(SheepDogX,1); 
                end
                if ~exist('windowSynchronicity', 'var')
                    %windowInfTh = 5; % from SSCI 20 paper
                    windowInfTh = size(SheepDogX,1); 
                end
                
                Verbose = False; % sys print 
                
                % init data
                numberOfShepherds = 1;
                numSheep = NumberOfSheep(timeTicks); 
                centreShepherd = [SheepDogX', SheepDogY'];
                xSheepPos = SheepX; 
                ySheepPos = SheepY; 
                
                 while timeTicks > windowInfTh
                
                    % setup
                    if Verbose
                        fprintf('Init Inf. Th. args...\n')

                        fprintf('Inf. Th. window size = %d\n', windowInfTh)
                    end
                    
                    InfThX = [centreShepherd((timeTicks-windowInfTh):timeTicks,1), nanmean(xSheepPos((timeTicks-windowInfTh):timeTicks,1:numSheep),2), xSheepPos((timeTicks-windowInfTh):timeTicks,1:numSheep)]; 

                    InfThY = [centreShepherd((timeTicks-windowInfTh):timeTicks,2), nanmean(ySheepPos((timeTicks-windowInfTh):timeTicks,1:numSheep),2), ySheepPos((timeTicks-windowInfTh):timeTicks,1:numSheep)];  
                    if Verbose 
                        fprintf('Inf. Th.: %d x %d\n', size(InfThY,1), size(InfThY,2))
                    end

                    ShepherdSynchronicity = 1;

                    % save x,y positions of all agents in the system 
                    xPositionOfAgents = InfThX;
                    yPositionOfAgents = InfThY;

                    % execution
                    fprintf('Start Inf. Th. iter %d\n', timeTicks)
                    [activeInfoStorage, netTEshepherd, totalTEshepherd, totalTEGCM, netTEGCM, combinedTE, agentSpec, internalSyncNetTE, internalSyncPeriod, internalSyncSummary, externalSyncTotalTE, externalSyncPeriod, externalSyncSummary] = transferEntropyModule(InfThX, InfThY, ShepherdSynchronicity, windowInfTh);
                    fprintf('End Inf. Th.for iter %d\n', timeTicks)

                    % analysis 
                    valueOfNetTEinternalSync = internalSyncNetTE;
                    valueOfTotalTEexternalSync = externalSyncTotalTE;

                    internalSyncSummaryStar = internalSyncSummary; % interim calc
                    %externalSyncPeriodStar = externalSyncPeriod; % interim calc
                    externalSyncSummaryStar = externalSyncSummary; % interim calc
                    %agentSpecSummary = agentSpec; % interim calc

                    % output: TotalTE for external influence 
                    totalTEtempCalc = externalSyncSummaryStar(ShepherdSynchronicity,:,:); % shepherd = pos 1; iterate over all elements in each frame
                    totalTEtempCalc = totalTEtempCalc/windowInfTh; % norm by the number of time steps used for calculations 

                    totalTEfinalCalc = totalTEtempCalc(2:(numSheep+numberOfShepherds)); % remove the shepherd column (=1) and counter column (=end)
                    totalTEexternalInfluence = totalTEfinalCalc == max(totalTEfinalCalc); % calculate the external influence (binary output)

                    externalInfluenceRank = floor(tiedrank(totalTEfinalCalc));

                    % output: NetTE for internal influence 
                    netTEtempCalc = internalSyncSummaryStar(numberOfShepherds+1:numSheep+1,numberOfShepherds+1:numSheep+1); % remove shepherd and array iter

                    % NetTE for source and target are equivalent but opposite (i.e. if source = 3 then target = -3)
                    % Ensuring that these are the same but opposite means our calculations are correct; if not, then review. 
                    netTEsource = sum(netTEtempCalc,2)'; % NetTE for source
                    netTEtarget = sum(netTEtempCalc,1); % NetTE for target

                    % we are interested in the source here as it infers influence within the flock
                    netTEinternalInfluence = netTEsource == max(netTEsource); 

                    internalInfluenceRank = floor(tiedrank(netTEsource)); 

                    % synchronicity 
                    synchronicityAggregateRank = (internalInfluenceRank+externalInfluenceRank);

                    % GCM
                    gcmLocalTransferEntropy = sign(netTEGCM) .* abs(totalTEGCM);

                    % Shepherd
                    shepherdLocalTransferEntropy = sign(netTEshepherd) .* abs(netTEshepherd);

                    % assign variables to struct 
                    InfThOutput.xPositionOfAgents = xPositionOfAgents;
                    InfThOutput.yPositionOfAgents = yPositionOfAgents; 
                    
                    % GCM TotalTE
                    InfThOutput.gcmTotalTE = totalTEGCM; 
                    
                    % GCM NetTE
                    InfThOutput.gcmNetTE = netTEGCM;
                    
                    % Flock NetTE
                    InfThOutput.valueOfNetTEinternalSync = valueOfNetTEinternalSync;
                    
                    % Flock/Shepherd TotalTE
                    InfThOutput.valueOfTotalTEexternalSync = valueOfTotalTEexternalSync;
                    
                    % Synchronicity Rank
                    InfThOutput.synchronicityAggregateRank = synchronicityAggregateRank; 
                    
                    % Internal Influence Rank 
                    InfThOutput.internalInfluenceRank = internalInfluenceRank; 
                    
                    % External Influence Rank 
                    InfThOutput.externalInfluenceRank = externalInfluenceRank; 
                    
                    % GCM LocalTE
                    InfThOutput.gcmLocalTransferEntropy = gcmLocalTransferEntropy;
                    
                    % Shepherd LocalTE
                    InfThOutput.shepherdLocalTransferEntropy = shepherdLocalTransferEntropy;
                    
                    % Flock internal NetTE
                    InfThOutput.netTEinternalInfluence = netTEinternalInfluence; 
                    
                    % NetTE Source 
                    InfThOutput.netTEsource = netTEsource;
                    
                    % NetTE Target 
                    InfThOutput.netTEtarget = netTEtarget;

                    % Flock-Shepherd External TotalTE 
                    InfThOutput.totalTEexternalInfluence = totalTEexternalInfluence;
                    
                    % Active Information Storage 
                    InfThOutput.AIS = activeInfoStorage; 
                    
                    break
                 end

                 while timeTicks < windowInfTh
                    InfThOutput.nan = timeTicks; 
                    break
                 end
                
            end
            
            %% Information Theory Markers
            function InfThOutput = InfTh2Markers(SheepX, SheepY, SheepDogX, SheepDogY, NumberOfSheep)                
                
                windowInfTh = size(SheepDogX,1);
                
                % init data
                numberOfShepherds = 1;
                numSheep = NumberOfSheep; 
                centreShepherd = [SheepDogX, SheepDogY];
                xSheepPos = SheepX; 
                ySheepPos = SheepY; 
                
                    % setup
                    InfThX = [centreShepherd, nanmean(xSheepPos,2), xSheepPos]; 

                    InfThY = [centreShepherd, nanmean(ySheepPos,2), ySheepPos];  
                    
                    ShepherdSynchronicity = 1; % do not change

                    % save x,y positions of all agents in the system 
                    xPositionOfAgents = InfThX;
                    yPositionOfAgents = InfThY;

                    % execution
                    %fprintf('Start Inf. Th. iter %d\n', timeTicks)
                    [activeInfoStorage, netTEshepherd, totalTEshepherd, totalTEGCM, netTEGCM, combinedTE, agentSpec, internalSyncNetTE, internalSyncPeriod, internalSyncSummary, externalSyncTotalTE, externalSyncPeriod, externalSyncSummary] = transferEntropyModule(InfThX, InfThY, ShepherdSynchronicity, windowInfTh);

                    % analysis 
                    valueOfNetTEinternalSync = internalSyncNetTE;
                    valueOfTotalTEexternalSync = externalSyncTotalTE;

                    internalSyncSummaryStar = internalSyncSummary; % interim calc
                    %externalSyncPeriodStar = externalSyncPeriod; % interim calc
                    externalSyncSummaryStar = externalSyncSummary; % interim calc
                    %agentSpecSummary = agentSpec; % interim calc

                    % output: TotalTE for external influence 
                    totalTEtempCalc = externalSyncSummaryStar(ShepherdSynchronicity,:,:); % shepherd = pos 1; iterate over all elements in each frame
                    totalTEtempCalc = totalTEtempCalc/windowInfTh; % norm by the number of time steps used for calculations 

                    totalTEfinalCalc = totalTEtempCalc(2:(numSheep+numberOfShepherds)); % remove the shepherd column (=1) and counter column (=end)
                    totalTEexternalInfluence = totalTEfinalCalc == max(totalTEfinalCalc); % calculate the external influence (binary output)

                    externalInfluenceRank = floor(tiedrank(totalTEfinalCalc));

                    % output: NetTE for internal influence 
                    netTEtempCalc = internalSyncSummaryStar(numberOfShepherds+1:numSheep+1,numberOfShepherds+1:numSheep+1); % remove shepherd and array iter

                    % NetTE for source and target are equivalent but opposite (i.e. if source = 3 then target = -3)
                    % Ensuring that these are the same but opposite means our calculations are correct; if not, then review. 
                    netTEsource = sum(netTEtempCalc,2)'; % NetTE for source
                    netTEtarget = sum(netTEtempCalc,1); % NetTE for target

                    % we are interested in the source here as it infers influence within the flock
                    netTEinternalInfluence = netTEsource == max(netTEsource); 

                    internalInfluenceRank = floor(tiedrank(netTEsource)); 

                    % synchronicity 
                    synchronicityAggregateRank = (internalInfluenceRank+externalInfluenceRank);

                    % GCM
                    gcmLocalTransferEntropy = sign(netTEGCM) .* abs(totalTEGCM);

                    % Shepherd
                    shepherdLocalTransferEntropy = sign(netTEshepherd) .* abs(netTEshepherd);

                    % assign variables to struct 
                    InfThOutput.xPositionOfAgents = xPositionOfAgents;
                    InfThOutput.yPositionOfAgents = yPositionOfAgents; 
                    
                    % Combined TE
                    InfThOutput.CombinedTE = combinedTE; 

                    % Total TE Shepherd
                    InfThOutput.totalTEshepherd = totalTEshepherd;

                    % Internal Synchronicity TE 
                    InfThOutput.internalSyncPeriod = internalSyncPeriod;
                    
                    % Internal Synchronicity TE 
                    InfThOutput.externalSyncPeriod = externalSyncPeriod;
                    
                    % Agent Spec 
                    InfThOutput.AgentSpec = agentSpec; 

                    % GCM TotalTE
                    InfThOutput.gcmTotalTE = totalTEGCM; 
                    
                    % GCM NetTE
                    InfThOutput.gcmNetTE = netTEGCM;
                    
                    % Flock NetTE
                    InfThOutput.valueOfNetTEinternalSync = valueOfNetTEinternalSync;
                    
                    % Flock/Shepherd TotalTE
                    InfThOutput.valueOfTotalTEexternalSync = valueOfTotalTEexternalSync;
                    
                    % Synchronicity Rank
                    InfThOutput.synchronicityAggregateRank = synchronicityAggregateRank; 
                    
                    % Internal Influence Rank 
                    InfThOutput.internalInfluenceRank = internalInfluenceRank; 
                    
                    % External Influence Rank 
                    InfThOutput.externalInfluenceRank = externalInfluenceRank; 
                    
                    % GCM LocalTE
                    InfThOutput.gcmLocalTransferEntropy = gcmLocalTransferEntropy;
                    
                    % Shepherd LocalTE
                    InfThOutput.shepherdLocalTransferEntropy = shepherdLocalTransferEntropy;
                    
                    % Flock internal NetTE
                    InfThOutput.netTEinternalInfluence = netTEinternalInfluence; 
                    
                    % NetTE Source 
                    InfThOutput.netTEsource = netTEsource;
                    
                    % NetTE Target 
                    InfThOutput.netTEtarget = netTEtarget;

                    % Flock-Shepherd External TotalTE 
                    InfThOutput.totalTEexternalInfluence = totalTEexternalInfluence;
                    
                    % Active Information Storage 
                    InfThOutput.AIS = activeInfoStorage; 
                    
            end
            
            %% Influence Contribution Marker
            function InfluenceContributionOutput = InfluenceContributionMarker(sensedData)
                
            end
            
            %% Cohesion Marker
            function CohesionOutput = CohesionMarker(SheepX, SheepY, timeStep, SheepID, CohesionRange)
                if ~exist('CohesionRange', 'var')
                    CohesionRange = 30; 
                end
                
                DiffX = SheepX(SheepID,timeStep) - SheepX(:,timeStep);
                DiffY = SheepY(SheepID,timeStep) - SheepY(:,timeStep);
                Distances = hypot(DiffX,DiffY);
                
                CohesionIndices = find(Distances<CohesionRange);
                NumberOfCohesion = sum(Distances<CohesionRange) - 1;
                
                if NumberOfCohesion > 0
                    GCMDirectionX = (sum(SheepX(CohesionIndices,timeStep)) -  SheepX(SheepID,timeStep)) / NumberOfCohesion;
                    GCMDirectionY = (sum(SheepY(CohesionIndices,timeStep)) -  SheepY(SheepID,timeStep)) / NumberOfCohesion;
                    GCMDirectionX = GCMDirectionX -  SheepX(SheepID,timeStep);
                    GCMDirectionY = GCMDirectionY -  SheepY(SheepID,timeStep);
                end
                
                GCMVectorMagnitude = hypot(GCMDirectionX,GCMDirectionY);
                GCMDirectionX = GCMDirectionX/(0.01+GCMVectorMagnitude);
                GCMDirectionY = GCMDirectionY/(0.01+GCMVectorMagnitude);
                
                CohesionOutput.X = GCMDirectionX;
                CohesionOutput.Y = GCMDirectionY;
                CohesionOutput.Distances = Distances; 
                CohesionOutput.CohesionIndices = CohesionIndices; 
                CohesionOutput.NumberOfCohesion = NumberOfCohesion; 
                CohesionOutput.GCMVectorMagnitude = GCMVectorMagnitude; 
            end
            
            %% Separation Marker
            function SeparationOutput = SeparationMarker(SheepX, SheepY, timeStep, SheepID, SeparationRange)
                if ~exist('SeparationRange', 'var')
                    SeparationRange = 0.4;
                end
                
                DiffX = SheepX(SheepID,timeStep) - SheepX(:,timeStep);
                DiffY = SheepY(SheepID,timeStep) - SheepY(:,timeStep);
                Distances = hypot(DiffX,DiffY);
                
                RepulsionIndices = find(Distances<SeparationRange);
                NumberOfRepulsion = sum(Distances<SeparationRange) - 1;
                
                if NumberOfRepulsion > 0
                    RepulsionX = (sum(SheepX(SheepID,timeStep) - SheepX(RepulsionIndices,timeStep)) ) / NumberOfRepulsion;
                    RepulsionY = (sum(SheepY(SheepID,timeStep) - SheepY(RepulsionIndices,timeStep)) ) / NumberOfRepulsion;
                end
                
                RepulsionMagnitude = hypot(RepulsionX,RepulsionY);
                RepulsionX = RepulsionX/(0.01+RepulsionMagnitude);
                RepulsionY = RepulsionY/(0.01+RepulsionMagnitude);
                
                SeparationOutput.Distances = Distances; 
                SeparationOutput.CohesionIndices = CohesionIndices; 
                SeparationOutput.NumberOfCohesion = NumberOfCohesion; 
                SeparationOutput.RepulsionX = RepulsionX;
                SeparationOutput.RepulsionY = RepulsionY;
                SeparationOutput.RepulsionMagnitude = RepulsionMagnitude; 
            end
            
            %% Alignment Marker
            function AlignmentOutput = AlignmentMarker(SensedData, timeStep, SheepID, AlignmentRange)
                if ~exist('AlignmentRange', 'var')
                    AlignmentRange = 50 / 10.0;
                end
                
                DiffX = SensedData.SheepX(SheepID,timeStep) - SensedData.SheepX(:,timeStep);
                DiffY = SensedData.SheepY(SheepID,timeStep) - SensedData.SheepY(:,timeStep);
                Distances = hypot(DiffX,DiffY);
                
                AlignmentIndices = find(Distances<AlignmentRange);
                NumberOfAllignment = sum(Distances<AlignmentRange) - 1;
                
                if NumberOfAllignment > 0
                    GCMAlignmentDirectionX = (sum(VelocityX(AlignmentIndices,timeStep)) -  VelocityX(SheepID,timeStep) ) / NumberOfAllignment;
                    GCMAlignmentDirectionY = (sum(VelocityY(AlignmentIndices,timeStep)) -  VelocityY(SheepID,timeStep) ) / NumberOfAllignment;
                    GCMAlignmentDirectionX = GCMAlignmentDirectionX -  VelocityX(SheepID,timeStep); %% Need the VelocityX and VelocityY variable here
                    GCMAlignmentDirectionY = GCMAlignmentDirectionY -  VelocityY(SheepID,timeStep);
                end
                
                AlignmentVectorMagnitude = hypot(GCMAlignmentDirectionX,GCMAlignmentDirectionY);
                GCMAlignmentDirectionX  = GCMAlignmentDirectionX/(0.01+AlignmentVectorMagnitude);
                GCMAlignmentDirectionY  = GCMAlignmentDirectionY/(0.01+AlignmentVectorMagnitude);
                
                AlignmentOutput.X = GCMAlignmentDirectionX;
                AlignmentOutput.Y = GCMAlignmentDirectionY;
                AlignmentOutput.Distances = Distances; 
                AlignmentOutput.AlignmentIndices = AlignmentIndices; 
                AlignmentOutput.NumberOfAlignment = NumberOfAlignment; 
                AlignmentOutput.AlignmentVectorMagnitude = AlignmentVectorMagnitude; 
            end
            
            %% Distance Marker
            function DistanceOutput = DistanceMarker(distMat, Verbose)
                if ~exist('Verbose', 'var')
                    Verbose = false;
                end
                if Verbose
                    DistanceOutput = squareform(pdist(distMat')); % return MxM matrix of pairwise distances
                else
                    DistanceOutput = pdist(distMat'); % return 1xM vector of pairwise distances 
                end
            end 
            
            %% Influence Stability Marker
            function InfluenceStabilityOutput = InfluenceStabilityMarker(SensedData)
                
                % This is either Effort-To-Compress OR Local TE values
                % compared period-to-period. This is a marker which
                % operates on the meta-level of local TE, i.e. it calcuates
                % the deviation for each agent and overall between each
                % time period to look at how stable the total internal
                % flock influences are 
            
                % I've calculated this before in the 'analysis file'
                % that looks at all of the different TE calculations
            end
            
            %% Rate of Change Marker 
            function RateOfChangeOutput = RateOfChangeMarker(PositionX, PositionY, GoalX, GoalY, timeStep)
                distOneToTwo = sqrt((PositionX(timeStep) - PositionX(timeStep-1))^2 + (PositionY(timeStep)-PositionY(timeStep-1))^2);
                distPreviousToTarget = sqrt((PositionX(timeStep-1)-GoalX(timeStep-1))^2 + (PositionY(timeStep-1)-GoalY(timeStep-1))^2);
                distCurrentToTarget = sqrt((PositionX(timeStep)-GoalX(timeStep))^2 + (PositionY(timeStep)-GoalY(timeStep))^2);
                
                RateOfChangeOutput = acos((distOneToTwo^2 + distPreviousToTarget^2 - distCurrentToTarget^2)/(2*distPreviousToTarget*distOneToTwo));
            end
            
            %% Mission Speed Marker 
            function MissionSpeedOutput = MissionSpeedMarker(SheepX, SheepY, NumSheep, t, Verbose)
                MissionSpeedOutput.ChangeInTime = t; 
                if strcmp('swarm', Verbose)
                    MissionSpeedOutput.FlockInitialPos = MARKERS.CentreOfMassMarker(SheepX, SheepY, NumSheep, 1); 
                    MissionSpeedOutput.FlockCurrentPos = MARKERS.CentreOfMassMarker(SheepX, SheepY, NumSheep, t); 
                end
                if strcmp('agent', Verbose)
                    MissionSpeedOutput.FlockInitialPos = [SheepX(1), SheepY(1)];
                    MissionSpeedOutput.FlockCurrentPos = [SheepX(t), SheepY(t)];
                end
                MissionSpeedOutput.Result = (pdist([MissionSpeedOutput.FlockCurrentPos; MissionSpeedOutput.FlockInitialPos], 'euclidean')/MissionSpeedOutput.ChangeInTime);
            end 
            
            %% Mission Completion Rate
            function MissionCompletionRateOutput = MissionCompletionRateMarker(SheepX, SheepY, NumSheep, GoalX, GoalY, timeStep, Verbose)
                MissionCompletionRateOutput.ChangeInTime = timeStep; 
                if strcmp('swarm', Verbose)
                    MissionCompletionRateOutput.FlockInitialPos = MARKERS.CentreOfMassMarker(SheepX, SheepY, NumSheep, 1); 
                    MissionCompletionRateOutput.FlockCurrentPos = MARKERS.CentreOfMassMarker(SheepX, SheepY, NumSheep, timeStep); 
                end
                if strcmp('agent', Verbose)
                    MissionCompletionRateOutput.FlockInitialPos = [SheepX(1), SheepY(1)];
                    MissionCompletionRateOutput.FlockCurrentPos = [SheepX(timeStep), SheepY(timeStep)];
                end
                MissionCompletionRateOutput.Goal = [GoalX(timeStep), GoalY(timeStep)];
                MissionCompletionRateOutput.Result = pdist([MissionCompletionRateOutput.FlockCurrentPos; MissionCompletionRateOutput.Goal], 'euclidean')/(pdist([MissionCompletionRateOutput.FlockCurrentPos; MissionCompletionRateOutput.FlockInitialPos], 'euclidean')+eps);
            end 
           
            %% Centre of Mass Marker
            function CentreOfMassOutput = CentreOfMassMarker(SheepX, SheepY, NumberOfSheep, t)
                 iterGCM = t;
                 
                 % initialise with first sheep 
                 GCMX = SheepX(iterGCM,1);
                 GCMY = SheepY(iterGCM,1);

                 % include all sheep 
                 for i = 2:NumberOfSheep(iterGCM)
                     GCMX = GCMX + SheepX(iterGCM,i);
                     GCMY = GCMY + SheepY(iterGCM,i);
                 end 
                
                 % Output 
                CentreOfMassOutput = [GCMX/NumberOfSheep(iterGCM), GCMY/NumberOfSheep(iterGCM)];

             end
            
            %% Dynamic Body Acceleration proxy, Acceleration (BDA)
            function DBAOutput = DBAMarker(SheepX, SheepY, timeStep, SheepID, timeStepSize)
                if ~exist('timeStepSize', 'var')
                    timeStepSize = 1; 
                end
                
                if (timeStep-(2*timeStepSize)) > 0
                    DBAOutput.ChangeInTime = timeStep - (timeStep-timeStepSize);
                    DBAOutput.SheepTwiceLastPos = [SheepX(timeStep-2*timeStepSize, SheepID), SheepY(timeStep-2*timeStepSize, SheepID)]; 
                    DBAOutput.SheepLastPos = [SheepX(timeStep-timeStepSize, SheepID), SheepY(timeStep-timeStepSize, SheepID)]; 
                    DBAOutput.SheepCurrentPos = [SheepX(timeStep, SheepID), SheepY(timeStep, SheepID)]; 

                    % calculate velocity, v = diff(position_now, position_last) / (time_now - time_last)
                    DBAOutput.VelocityLast = pdist([DBAOutput.SheepLastPos; DBAOutput.SheepTwiceLastPos], 'euclidean')/DBAOutput.ChangeInTime;
                    DBAOutput.VelocityCurrent = pdist([DBAOutput.SheepCurrentPos; DBAOutput.SheepLastPos], 'euclidean')/DBAOutput.ChangeInTime;

                    % calculate acceleration, a = diff(v_now, v_last) / (time_now - time_last)
                    DBAOutput.Acceleration = diff([DBAOutput.VelocityCurrent, DBAOutput.VelocityLast])/DBAOutput.ChangeInTime;
                else
                     DBAOutput.Acceleration = NaN; 
                end
            end
            
            %% Overall Dynamic Body Acceleration (ODBA) Marker
            function ODBAOutput = ODBAMarker(DBA, timeStep)
                if ~exist('timeStepSize', 'var')
                    timeStepSize = 1; 
                end
                
                ODBAOutput.ODBA = nansum(DBA(1:timeStep)); 
            end
            
            %% Heading Marker  
            function HeadingOutput = HeadingMarker(x,y)
                % Translate the raw positions into delta Positions
                velX = x(2:end,:) - x(1:end-1,:);
                velY = y(2:end,:) - y(1:end-1,:);

                % Translate velocities into headings:
                [headingXY,speed] = cart2pol(velX, velY);
                
                HeadingOutput.headingXY = headingXY; 
                HeadingOutput.speed = speed; 
            end 
            
            %% Granger Causality Marker 
            function GrangerOutput = GrangerMarker(TimeSeriesX1, TimeSeriesX2, TimeSeriesY1, TimeSeriesY2)
                % calculate headings as a dimension reduction for position
                HeadingTimeSeriesX = MARKERS.HeadingMarker(TimeSeriesX1,TimeSeriesX2);  
                HeadingTimeSeriesY = MARKERS.HeadingMarker(TimeSeriesY1,TimeSeriesY2);
                
                
                [h,pvalue,stat,cvalue] = gctest(HeadingTimeSeriesX.headingXY,HeadingTimeSeriesY.headingXY);

                % Outputs 
                GrangerOutput.h = h; 
                GrangerOutput.pvalue = pvalue;
                GrangerOutput.stat = stat; 
                GrangerOutput.cvalue = cvalue; 
            end

            %% Dynamic Time Warping
            function DTWoutput = DynamicTimeWarpingMarker(TimeSeriesX1, TimeSeriesX2, TimeSeriesY1, TimeSeriesY2)
                % calculate headings as a dimension reduction for position
                HeadingTimeSeriesX = MARKERS.HeadingMarker(TimeSeriesX1,TimeSeriesX2);  
                HeadingTimeSeriesY = MARKERS.HeadingMarker(TimeSeriesY1,TimeSeriesY2);
                
                DTWoutput = dtw(HeadingTimeSeriesX.headingXY,HeadingTimeSeriesY.headingXY);

            end            
            
            %% Effort-To-Compress Marker
            function ETCoutput = ETCMarker(TimeSeriesX1, TimeSeriesX2, NumBins)
                if ~exist('NumBins', 'var')
                    NumBins = 8; % Kathpalia (2021), pg 246 (Thesis: Theoretical and Experimental Investigations into Causality, its Measures and Applications)
                end                
                % Bin size selection for CCC (based on ETC): 
                % Auto Regressive = 2
                % Tent Map = 8
                % Squid Giant Axom System = 2
                % Predator Prey Ecosystem = 8 
                % Resolution increases as NumBins is increased --> therefore has the ability to inform correct causal relations

                HeadingTimeSeries = MARKERS.HeadingMarker(TimeSeriesX1,TimeSeriesX2);  

                hdg = HeadingTimeSeries.headingXY; 

                [N, EntLen] = ETC(hdg,NumBins);
                
                ETCoutput.N = N;
                ETCoutput.EntLen = EntLen;
            end
            
            %% Lyapunov Exponent
            function LyaExpOutput = LyaExpMarker(TimeSeriesX1, TimeSeriesX2, TimeSeriesY1, TimeSeriesY2)
                                
                % Dimension reduction - calculate headings 
                HeadingX = MARKERS.HeadingMarker(TimeSeriesX1, TimeSeriesX2);
                HeadingY = MARKERS.HeadingMarker(TimeSeriesY1, TimeSeriesY2);
                               
                % calculate LE 
                LyaExpOutput = lyapunovExponent([HeadingX.headingXY, HeadingY.headingXY]);
                
            end
            
            %% Cross Correlation Marker 
            function CrossCorrOutput = CrossCorrMarker(TimeSeriesX, TimeSeriesY)
                if ~exist('TimeSeriesY', 'var')
                    [r, lags] = xcorr(TimeSeriesX); 
                end
                if exist('TimeSeriesY', 'var')
                    [r, lags] = xcorr(TimeSeriesX, TimeSeriesY); 
                end
                CrossCorrOutput.r = r; 
                CrossCorrOutput.lags = lags; 
            end
            
            %% Speed Marker 
            function SpeedOutput = SpeedMarker(PositionNow, PositionPast, timeStepLength)
                SpeedOutput = pdist2(PositionNow, PositionPast,  'euclidean')/timeStepLength;
            end
            
            %% Accleeration Marker 
            function AccelerationOutput = AccelerationMarker(VelocityNow, VelocityPast, timeStepLength)
                AccelerationOutput = (VelocityNow-VelocityPast)/timeStepLength;
            end
            
            %% Graph Theory Markers 
            function GraphOutput = GraphMarker(G) % from a square adjacency matrix
                % graph of source-target pairs (s-t)
                %G = digraph(s,t); 
                
                GraphOutput.CentralityPageRank = centrality(G, 'pagerank'); 
                GraphOutput.CentralityEigen = centrality(G, 'eigenvector');
                GraphOutput.CentralityBetweeness = centrality(G,'betweenness');
                GraphOutput.CentralityInCloseness = centrality(G,'incloseness');
                GraphOutput.CentralityOutCloseness = centrality(G,'outcloseness');
                GraphOutput.CentralityOutDegree = centrality(G,'outdegree');
                GraphOutput.CentralityInDegree = centrality(G,'indegree');
                
                GraphOutput.CentralityDegree = GraphOutput.CentralityOutDegree - GraphOutput.CentralityInDegree; 
                GraphOutput.CentralityCloseness = GraphOutput.CentralityOutCloseness - GraphOutput.CentralityInCloseness;
            end
            
            %% Normalised Information Flow 
            function [tau21b, tau21l, err90, dH1_star, dH1_noise] = NormalisedInformationFlow(TimeSeriesX1, TimeSeriesX2, TimeSeriesY1, TimeSeriesY2, np)
                % 
                % [tau21b, tau21l, dH1_noise] = tau_est(xx1, xx2, np)
                %
                % Estimate tau21, the normalized information transfer from X2 to X1 
                % dt is taken to be 1.
                %
                % On input:
                %    X1, X2: the time series
                %    np: integer >=1, time advance in performing Euler forward 
                %	 differencing, e.g., 1, 2. Unless the series are generated
                %	 with a highly chaotic deterministic system, np=1 should be
                %	 used.
                %
                % On output:
                %    tau21b:  relative info flow from X2 to X1	(Bai et al., 2017)
                %    tau21l:  relative info flow from X2 to X1	(Liang, 2015)
                %    dH1_star:  relative contribution from X1 to itself
                %		(Lyapunov exponent)
                %    dH1_noise: relative noise contribution
                %		(noise-to-signal ratio)
                %
                %
                %    err90: standard error at 90% significance level
                %    err95: standard error at 95% significance level
                %    err99: standard error at 99% significance level
                %    
                % n1 = 1; dn = 1;
                %
                % References
                % Liang (2014): Unraveling the Cause-effect Relation between Time Series
                % Liang (2015): Normalizing the Causality between Time Series
                % Bai et al.(2017): A New Framework of Detecting Cyclone-climate Interactions and Forecasting Tropical Cyclone Activity 
                % in the Northwest Pacific
                if ~exist('np', 'var')
                    np = 1; 
                end

                HeadingX = MARKERS.HeadingMarker(TimeSeriesX1, TimeSeriesX2);
                HeadingY = MARKERS.HeadingMarker(TimeSeriesY1, TimeSeriesY2);

                xx1 = HeadingX.headingXY; 
                xx2 = HeadingY.headingXY; 
                
                dt = 1;	 
                [nm, one] = size(xx1);
                dx1(:,1) = (xx1(1+np:nm, 1) - xx1(1:nm-np, 1)) / (np*dt);
                 x1(:,1) = xx1(1:nm-np, 1);
                dx2(:,1) = (xx2(1+np:nm, 1) - xx2(1:nm-np, 1)) / (np*dt);
                 x2(:,1) = xx2(1:nm-np, 1);
                clear xx1 xx2;
                N = nm-np;
                C = cov(x1, x2);
                dC(1,1) = sum((x1 - mean(x1)) .* (dx1 - mean(dx1))); 
                dC(1,2) = sum((x1 - mean(x1)) .* (dx2 - mean(dx2))); 
                dC(2,1) = sum((x2 - mean(x2)) .* (dx1 - mean(dx1))); 
                dC(2,2) = sum((x2 - mean(x2)) .* (dx2 - mean(dx2))); 
                dC = dC / (N-1);
                % C_infty = cov(x1, x2);
                C_infty = C;
                detc = det(C);
                a11 = C(2,2) * dC(1,1) - C(1,2) * dC(2,1);
                a12 = -C(1,2) * dC(1,1) + C(1,1) * dC(2,1);
                % a21 = -C(1,2) * dC(1,2) + C(1,1) * dC(2,2);
                % a22 = C(2,2) * dC(1,2) - C(1,2) * dC(2,2);
                a11 = a11 / detc;
                a12 = a12 / detc;
                % a21 = a21 / detc;
                % a22 = a22 / detc;
                f1 = mean(dx1) - a11 * mean(x1) - a12 * mean(x2);
                % f2 = mean(dx2) - a21 * mean(x1) - a22 * mean(x2);
                R1 = dx1 - (f1 + a11*x1 + a12*x2);
                % R2 = dx2 - (f2 + a21*x1 + a22*x2);
                Q1 = sum(R1 .* R1);
                % Q2 = sum(R2 .* R2);
                b1 = sqrt(Q1 * dt / N);
                % b2 = sqrt(Q2 * dt / N);
                %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % covariance matrix of the estimation of (f1, a11, a12, b1)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                NI(1,1) = N * dt / b1/b1;
                NI(2,2) = dt/b1/b1 * sum(x1 .* x1);
                NI(3,3) = dt/b1/b1 * sum(x2 .* x2);
                NI(4,4) = 3*dt/b1^4 * sum(R1 .* R1) - N/b1/b1;
                NI(1,2) = dt/b1/b1 * sum(x1);
                NI(1,3) = dt/b1/b1 * sum(x2);
                NI(1,4) = 2*dt/b1^3 * sum(R1);
                NI(2,3) = dt/b1/b1 * sum(x1 .* x2);
                NI(2,4) = 2*dt/b1^3 * sum(R1 .* x1);
                NI(3,4) = 2*dt/b1^3 * sum(R1 .* x2);
                NI(2,1) = NI(1,2);
                NI(3,1) = NI(1,3);    NI(3,2) = NI(2,3);
                NI(4,1) = NI(1,4);    NI(4,2) = NI(2,4);   NI(4,3) = NI(3,4);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                invNI = inv(NI);
                var_a12 = invNI(3,3);		%% 
                %
                % approx. variance of a12, corr. to variance of T21
                %
                %
                % Information transfer: T21 = C12/C11 * a12
                %			T12 = C21/C22 * a21
                %
                 T21 = C_infty(1,2)/C_infty(1,1) * (-C(2,1)*dC(1,1) + C(1,1)*dC(2,1)) / detc;
                % T12 = C_infty(2,1)/C_infty(2,2) * (-C(1,2)*dC(2,2) + C(2,2)*dC(1,2)) / detc;
                %
                var_T21 = (C_infty(1,2)/C_infty(1,1))^2 * var_a12;
                %
                % From the standard normal distribution table, 
                % significance level alpha=95%, z=1.96
                % 		           99%, z=2.56
                % 			   90%, z=1.65
	                z99 = 2.56;
	                z95 = 1.96;
	                z90 = 1.65;
	                z80 = 1.28;
	                err90 = sqrt(var_T21) * z90;
	                err95 = sqrt(var_T21) * z95;
	                err99 = sqrt(var_T21) * z99;
                dH1_star = a11;
                dH1_noise = b1^2 / (2. * C(1,1));
                Z = abs(T21) + abs(dH1_star) + abs(dH1_noise);
                tau21b = abs(T21) / (abs(dH1_noise)+ abs(T21));
                tau21l = T21 / Z;
            end

            %% PSD Spectral Entropy via Shannon 
            function ShanEntPSD = SpecEntPSD(TimeSeriesX, TimeSeriesY)
                Heading = MARKERS.HeadingMarker(TimeSeriesX, TimeSeriesY);
                hdg = Heading.headingXY; 
                
                ShanEntPSD = wentropy(hdg, 'shannon');
            end

            %% Shannon Entropy 
            function  H = ShannonEntropy(TimeSeriesX, TimeSeriesY,varargin)
                %ENTROPY Compute the Shannon entropy of a set of variables.
                %   ENTROPY(X,P) returns the (joint) entropy for the joint distribution 
                %   corresponding to object matrix X and probability vector P.  Each row of
                %   MxN matrix X is an N-dimensional object, and P is a length-M vector 
                %   containing the corresponding probabilities.  Thus, the probability of 
                %   object X(i,:) is P(i).  
                %
                %   ENTROPY(X), with no probability vector specified, will assume a uniform
                %   distribution across the objects in X.
                %   
                %   If X contains duplicate rows, these are assumed to be occurrences of the 
                %   same object, and the corresponding probabilities are added.  (This is 
                %   actually the only reason that object matrix X is needed -- to detect and 
                %   merge repeated objects.  Of course, the entropy itself only depends on 
                %   the probability vector P.)  Matrix X need NOT be an exhaustive list of 
                %   all *possible* objects in the universe; objects that do not appear in X
                %   are simply assumed to have zero probability. 
                %
                %   The elements of probability vector P must sum to 1 +/- .00001.
                %
                %   For further information about entropy in information theory, see
                %   <a href="matlab:web('http://en.wikipedia.org/wiki/Information_entropy','-browser')">Information entropy</a>. Wikipedia, The Free Encyclopedia. 
                %  
                %   https://au.mathworks.com/matlabcentral/fileexchange/12857-entropy   
                %   Author: David Fass, 2016. 
                %
                %   See also: MUTUALINFO

                Heading = MARKERS.HeadingMarker(TimeSeriesX, TimeSeriesY);
                objectSet = Heading.headingXY;                 

                %% Error checking %%
                if size(objectSet,1) == 1,
                    objectSet = objectSet';
                    %warning('Object set row vector is being transposed to a column vector.')
                end
                if ~isempty(varargin),
                    probSet = varargin{1};
                else
                    probSet = repmat(1/size(objectSet,1),size(objectSet,1),1);
                end
                if ~isequal(size(objectSet,1),length(probSet)),    
                    error('Object set must have an object for each probability.')
                end
                % Check probabilities sum to 1:
                if abs(sum(probSet) - 1) > .00001,
                    error('Probablities don''t sum to 1.')
                end
                %% Merge duplicate objects/probabilities %%
                % We do not use objectSet in the calculations, but just need to deal with 
                % duplicated objects (add probabilities together).
                [minimalObjSet I equivClass] = unique(objectSet,'rows');
                if ~isequal(size(minimalObjSet,1),size(objectSet,1)),    
                    probSetReduced = zeros(size(minimalObjSet,1),1);
                    for i = 1:length(probSetReduced),     
                        probSetReduced(i) = sum(probSet(equivClass==i));
                    end   
                    probSet = probSetReduced;
                end
                %% Remove any zero probabilities %%
                zeroProbs = find(probSet < eps);
                if ~isempty(zeroProbs),
                    probSet(zeroProbs) = [];
                    %disp('Removed zero or negative probabilities.')
                end
                %% Compute the entropy
                H = -sum(probSet .* log2(probSet));   
            end
        
        end

end
