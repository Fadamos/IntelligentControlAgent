% Author: Adam J Hepworth
% LastModified: 2022-09-11
% Explanaton: NOLH Exoperimental Design conduct script

    DOE_SCENARIO    = [5 2 3 5 5 5 1 5 2 6 2 2 4 1 4 5 4 6 3 3 4 6 5 3 4 6 2 3 4 3 6 2 6 4 4 3 4 5 4 6 3 3 2 1 3 2 2 5 2 3 1 5 3 1 5 4 4 3 4 3 2 2 1 1 2 5 3 4 2 3 3 3 3 1 4 5 5 2 2 6 6 5 2 6 5 2 5 4 4 4 5 3 1 5 5 4 2 2 5 3 6 3 2 1 4 4 3 1 2 3 4 4 2 5 6 4 5 5 5 1 4 5 1 4 2 2 3 2 6 7 10 9 7 7 7 11 7 10 6 10 10 8 11 8 7 8 6 9 9 8 6 7 9 8 6 10 9 8 9 6 10 6 8 9 9 8 7 8 6 9 9 10 11 9 10 10 7 10 9 11 7 9 11 7 8 8 9 8 9 10 10 11 11 10 7 9 8 10 9 9 9 9 11 8 7 7 10 10 6 6 7 10 6 7 10 7 8 8 8 7 9 11 7 7 8 10 10 7 9 6 9 10 11 8 8 9 11 10 9 8 8 10 7 6 8 7 7 7 11 8 7 11 8 10 10 9 10];
    DOE_DRIVE       = [5 3 3 2 3 2 3 1 3 1 5 2 5 2 4 2 3 2 4 2 3 2 4 3 3 2 4 1 4 2 5 3 4 3 4 2 3 2 3 2 4 2 5 2 4 2 4 2 4 1 4 1 5 2 4 3 4 2 4 2 5 1 5 1 4 1 4 2 4 1 4 2 5 2 3 2 4 2 3 1 3 3 3 1 5 3 4 3 4 2 4 3 3 1 4 3 5 1 4 3 4 3 5 1 4 2 5 2 4 1 4 2 3 2 4 3 3 3 5 3 3 2 4 1 5 1 5 2 3 1 3 3 4 3 4 3 5 3 5 1 4 1 4 2 4 3 4 2 4 3 4 2 3 3 4 2 5 2 4 1 3 2 3 2 4 3 4 3 4 2 4 1 4 2 4 2 4 2 5 2 5 1 4 2 3 2 4 2 4 1 5 1 5 2 5 2 4 2 5 2 4 1 4 3 4 2 4 3 5 3 3 3 5 1 4 2 3 2 4 2 3 3 5 2 3 1 5 2 3 2 3 1 5 2 4 1 4 2 5 2 4 3 4 2 3 3 3 1 3 3 4 2 5 1 5 2 4];
    DOE_COLLECT     = [3 4 1 3 3 5 3 2 5 4 3 1 4 4 1 2 4 4 3 2 4 3 3 2 4 5 3 2 5 3 2 2 4 4 2 3 3 4 3 2 5 4 2 2 4 4 2 2 4 5 2 1 4 3 1 2 4 4 2 2 5 5 1 1 4 4 2 1 4 4 2 1 3 4 1 2 3 5 2 2 3 5 3 3 4 3 1 3 4 3 2 2 4 3 3 1 4 3 1 1 5 5 2 3 5 4 2 2 4 4 2 1 4 3 3 2 5 3 3 3 4 5 3 2 5 4 1 1 3 3 2 5 3 3 1 3 4 1 2 3 5 2 2 5 4 2 2 3 4 2 3 3 4 2 1 3 4 1 3 4 4 2 2 4 3 3 2 3 4 1 2 4 4 2 2 4 4 2 1 4 5 2 3 5 4 2 2 4 4 1 1 5 5 2 2 4 5 2 2 4 5 3 2 5 4 3 1 4 4 3 1 3 3 2 3 5 4 2 3 4 4 2 3 3 5 2 3 5 5 1 1 4 3 1 2 4 4 2 2 4 5 2 3 3 4 1 3 3 3 2 1 3 4 2 2 5 5]; 
    DOE_CLOCK_2     = [10 14 9 10 7 3 3 7 10 11 14 11 2 3 8 2 12 10 8 10 4 4 8 5 14 8 12 11 4 2 8 5 8 11 9 11 3 5 6 7 10 13 13 12 1 3 4 4 11 9 15 12 6 1 4 2 15 15 14 13 4 5 4 5 12 12 13 14 5 4 6 2 8 14 13 10 7 6 1 3 11 10 14 10 8 2 7 7 11 9 9 15 3 7 5 5 15 13 12 9 4 7 2 2 10 10 12 14 1 3 5 6 15 9 9 10 6 8 7 3 13 13 13 14 5 2 7 5 8 6 2 7 6 9 13 13 9 6 5 2 5 14 13 8 14 4 6 8 6 12 12 8 11 2 8 4 5 12 14 8 11 8 5 7 5 13 12 10 9 6 3 3 4 15 13 12 12 5 7 1 4 10 15 12 14 1 1 2 3 12 11 12 11 4 4 3 2 11 12 10 14 8 2 3 6 9 10 15 13 5 6 2 6 8 14 9 9 5 7 7 1 13 9 11 11 1 3 4 7 12 9 14 14 6 6 4 2 15 13 11 10 1 7 7 6 10 8 9 13 3 3 3 2 11 14 9 11];
    DOE_CLOCK_3     = [7 7 10 8 9 9 6 9 4 1 5 4 5 2 2 5 9 6 8 8 8 9 6 8 3 5 5 4 3 3 5 3 7 9 9 8 10 9 8 8 5 4 5 4 2 3 4 5 10 10 9 9 8 8 8 7 3 5 1 3 4 1 3 2 6 9 9 7 6 7 10 9 3 3 3 2 4 3 4 2 7 6 6 10 8 6 7 7 4 4 1 4 5 2 5 5 7 7 8 9 10 8 8 7 1 2 3 5 3 5 2 2 9 9 9 10 7 10 6 7 1 5 5 4 4 5 5 2 6 4 4 1 3 2 2 5 2 7 10 6 7 6 9 9 6 2 5 3 3 3 2 5 3 8 6 6 7 8 8 6 8 4 2 2 3 1 2 3 3 6 7 6 7 9 8 7 6 1 1 2 2 3 3 3 4 8 6 10 8 7 10 8 9 5 2 2 4 5 4 1 2 8 8 8 9 7 8 7 9 4 5 5 1 3 5 4 4 7 7 10 7 6 9 6 6 4 4 3 2 1 3 3 4 10 9 8 6 8 6 9 9 2 2 2 1 4 1 5 4 10 6 6 7 7 6 6 9]; 
    
    parameters.IsolatedSim = false;

    parameters.seedGen = randperm(1000000,numel(DOE_SCENARIO)); % seed already generated here and saved as 'seed.mat' for 
    parameters.seed = parameters.seedGen;

    parameters.CollectIterator = ["F2H","C2H","F2G","F2D","C2D"];
    parameters.DriveIterator = ["DOAT","DQH","DHH","DTQH","DAH"]; 

    parameters.ObservationWindow = 60;%[20 40 60 80 100];
    parameters.OverlapWindow = 0.25;%[0.25 0.5 0.75];    parameters.replicates = 1; 
    parameters.Replicate = 1; 
    parameters.BatchCurrentRun = 191; 
    parameters.BatchTotalRuns = 262;
    
    for iterator = 192:numel(DOE_SCENARIO)
        
        rng(parameters.seed(iterator))
        
        parameters.ScenarioIndex = char(append("S",num2str(DOE_SCENARIO(iterator))));
        parameters.SheepDogVehicleSpeedLimit = "Dog1.5";
        parameters.DogDrivingTacticIndex = parameters.DriveIterator(DOE_DRIVE(iterator));
        parameters.DogCollectingTacticIndex = parameters.CollectIterator(DOE_COLLECT(iterator));
        parameters.visual = "classic"; % 'classic' if using original visuals
        parameters.IsolatedSim = false;
        parameters.BatchCurrentRun = parameters.BatchCurrentRun + 1; 
        parameters.SigmaLength = DOE_CLOCK_2(iterator); % 1 = strombom; > 1 = novel 
        parameters.SigmaPositioningPoint = DOE_CLOCK_3(iterator);  % 1 = strombom; > 1 = novel 
        
        try
            tic
            DataGenCONTROLLER
            parameters.SimTime = toc; 
            fprintf('time = %f\n', parameters.SimTime)
            fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n\n')

        catch 
            fprintf(' * * * * * * * * * * \n')
            fprintf(' * * * * * * * * * * * * * * * * * * * * \n')
            fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * \n')
            fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
            fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
            fprintf('\nSim failed for: sim run=%i; iterator=%i, collect=%i; drive=%i\n',parameters.BatchCurrentRun,iterator,DOE_DRIVE(iterator),DOE_COLLECT(iterator))
            fprintf('\n * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
            fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
            fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * \n')
            fprintf(' * * * * * * * * * * * * * * * * * * * * \n')
            fprintf(' * * * * * * * * * * \n')
        end

            %% Evaluation of tactic-pair combinations 
            % setup data 
            NumSheep = output.SensedData.NumberOfSheep; 
            MissionRunTime = output.SensedData.t; 
            SheepX = output.SensedData.SheepX;
            SheepY = output.SensedData.SheepY;
            GoalX = output.SensedData.GoalX;
            GoalY = output.SensedData.GoalY;
            SheepDogX = output.SensedData.SheepDogX;
            SheepDogY = output.SensedData.SheepDogY;
            SheepNotInGoal = output.SensedData.SheepNotInGoal(end); 
            
            %% calculate variables
            MissionSpeedOutput = MARKERS.MissionSpeedMarker(SheepX, SheepY, NumSheep, MissionRunTime(end)-1, 'swarm');
            MissionCompletionRateOutput = MARKERS.MissionCompletionRateMarker(SheepX, SheepY, NumSheep, GoalX, GoalY, MissionRunTime(end)-1, 'swarm');
            MissionObjectiveAchieved = output.SensedData.AllSheepWithinGoal;
            
            SheepDogPoints = [SheepDogX' SheepDogY'];
            SheepDogDiff = [diff(SheepDogPoints,1); SheepDogPoints(end,:)-SheepDogPoints(1,:)];
            SheepDogDistanceMoved = sqrt(sum(SheepDogDiff .* SheepDogDiff, 2));
            
            for i = 1:MissionRunTime(end)
                FlockGCM(i,:) = MARKERS.CentreOfMassMarker(SheepX, SheepY, NumSheep, i); % GCM positions over segment 
                try 
                    [~,chull(i)] = convhull(output.SensedData.SheepX(i,:), output.SensedData.SheepY(i,:));
                catch 
                    chull(i) = chull(i-1);
                end
            end
            
            FlockDiff = [diff(FlockGCM,1); FlockGCM(end,:)-FlockGCM(1,:)];
            FlockDistanceMoved = sqrt(sum(FlockDiff .* FlockDiff, 2));
            
            % save output for the trial run 
            % Col 1  = Mission success (all sheep in goal), 1 or 0
            % Col 2  = number of sheepdog decision changes during mission 
            % Col 3  = Length of missions (time)
            % Col 4  = Mission speed (effectively distance(start - end)/time)
            % Col 5  = Mission completion rate (effectively distance between current position and goal)
            % Col 6  = Total distance moved by the flock
            % Col 7  = Average distance moved by the flock (per time period)
            % Col 8  = Total distance moved by the sheepdog 
            % Col 9  = Average distance moved by the sheepdog (per time period)
            % Col 10 = sim run time (seconds)
            % Col 11 = Average number of separated sheep
            % Col 12 = Average convex hull of all agents swarm 
            % Col 13 = Average density (dispersion) of agents in convex hull - allows us to normalise between simulation runs
            % Col 14 = Paddock area 
            % Col 15 = flock density size over area as a proportion of the paddock size
            MissionPerformanceStatistics = [MissionObjectiveAchieved,...                        % 1
                sum(abs(diff(output.TranslationData.SheepDogBehaviour))),...                    % 2
                MissionRunTime(end),...                                                         % 3
                MissionSpeedOutput.Result,...                                                   % 4
                MissionCompletionRateOutput.Result,...                                          % 5
                FlockDistanceMoved(end),...                                                     % 6
                mean(FlockDistanceMoved(1:end-1)),...                                           % 7
                SheepDogDistanceMoved(end),...                                                  % 8 
                mean(SheepDogDistanceMoved(1:end-1)),...                                        % 9
                parameters.SimTime,...                                                          % 10
                mean(output.TranslationData.NumberOfSheepSeparated),...                         % 11
                parameters.Area                                                                 % 12
                ];                                                  
            output.MissionPerformanceStatistics = MissionPerformanceStatistics; 
            
            varName = [date, '_',parameters.ScenarioIndex,'_r',num2str(parameters.BatchCurrentRun),'-',num2str(parameters.BatchTotalRuns),'_seed',num2str(parameters.seed(iterator)),'_tc',num2str(DOE_COLLECT(iterator)),'_td',num2str(DOE_DRIVE(iterator)),'_CL2-',num2str(DOE_CLOCK_2(iterator)),'_CL3-',num2str(DOE_CLOCK_3(iterator))];       
                save(sprintf('/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE_CLOCK/%s.mat',varName),'output') % macOS-mini
                %save(sprintf('/Users/fadamos/GitHub/RecognitionController/SimData/%s.mat',varName),'output') % macOS-mbp
    
    end
