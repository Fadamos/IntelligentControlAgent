% Author: Adam J Hepworth
% LastModified: 2022-08-19
% Explanaton: Experimentation data generation and analysis script
% Purpose: Agent performance testing 

    %% scenario generation
    
    clear
    clc

    % user set this
    parameters.Adam = true; 
    
        parameters.ScenarioIterator = ["S1","S2","S3","S4","S5","S6","S7","S8","S9","S10","S11"]; % manually set per terminal! 
        parameters.CollisonIterator = "L1"; 
        parameters.SheepDogVehicleSpeedIterator = "Dog1.5";
        parameters.CollectIterator = ["F2H","C2H","F2G","F2D","C2D"];
        parameters.DriveIterator = ["DOAT","DQH","DHH","DTQH","DAH"]; 
        parameters.ObservationWindow = 60;%[20 40 60 80 100];
        parameters.OverlapWindow = 0.25;%[0.25 0.5 0.75];
        parameters.replicates = 30; 
        parameters.BatchCurrentRun = 0; 
        parameters.BatchTotalRuns = (length(parameters.ScenarioIterator) * length(parameters.CollisonIterator) * length(parameters.SheepDogVehicleSpeedIterator) * length(parameters.CollectIterator) * length(parameters.DriveIterator) * parameters.replicates); % per terminal above i.e. = 750 
    
    parameters.seedGen = randperm(1000000,30); % seed already generated here and saved as 'seed.mat' for 
    parameters.seed = parameters.seedGen;
    
    %load('/Users/ajh/GitHub/RecognitionController/seed.mat') % load seed setting

    for scenario = 1:size(parameters.ScenarioIterator,2) % scenario iterate 
        parameters.ScenarioIndex = char(parameters.ScenarioIterator(scenario));
        for iterator = 1:parameters.replicates % replicates of each scenario, integer 
            for collision = 1:size(parameters.CollisonIterator,2)
                for dogspeed = 1:size(parameters.SheepDogVehicleSpeedIterator,2)
                    for collect = 1:size(parameters.CollectIterator,2) 
                        for drive = 1:size(parameters.DriveIterator,2) 
                            % for ObsWindow = 5 %1:size(ObservationWindow,2)% not for this analysis
                                % for OverWindow = 2 %1:size(OverlapWindow,2) % not for this analysis
                                    % parameters.WindowSize = ObservationWindow(ObsWindow); % not for this analysis
                                    % parameters.Overlap = OverlapWindow(OverWindow); % not for this analysis
                                    parameters.Replicate = iterator;
                                    parameters.CollisionRange = parameters.CollisonIterator(collision); 
                                    parameters.SheepDogVehicleSpeedLimit = parameters.SheepDogVehicleSpeedIterator(dogspeed);
                                    parameters.DogCollectingTacticIndex = parameters.CollectIterator(collect);
                                    parameters.DogDrivingTacticIndex = parameters.DriveIterator(drive);
                                    parameters.visual = "classic"; % 'classic' if using original visuals
                                    parameters.IsolatedSim = false;
                                    parameters.BatchCurrentRun = parameters.BatchCurrentRun + 1; 
                                    rng(parameters.seed(iterator))
                                    
                                    %% Sim Run                                                             
                                    try 
                                        tic 
                                        DataGenCONTROLLER
                                        parameters.SimTime = toc; 
                                        fprintf('time = %f\n', parameters.SimTime)
                                    catch 
                                        fprintf(' * * * * * * * * * * \n')
                                        fprintf(' * * * * * * * * * * * * * * * * * * * * \n')
                                        fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * \n')
                                        fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
                                        fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
                                        if parameters.InternalMarkerCalculations
                                            fprintf('\nSim failed for: sim run=%i; iterator=%i, collision=%i; dogspeed=%i; collect=%i; drive=%i; window=%i; overlap=%d\n',parameters.BatchCurrentRun,iterator,collision,dogspeed,collect,drive,ObsWindow,OverWindow)
                                        else
                                            fprintf('\nSim failed for: sim run=%i; iterator=%i, collision=%i; dogspeed=%i; collect=%i; drive=%i\n',parameters.BatchCurrentRun,iterator,collision,dogspeed,collect,drive)
                                        end
                                        fprintf('\n * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
                                        fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n')
                                        fprintf(' * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * \n')
                                        fprintf(' * * * * * * * * * * * * * * * * * * * * \n')
                                        fprintf(' * * * * * * * * * * \n')
                                        % DataGenMESSAGE(...)
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
                                        [~,chull(i)] = convhull(output.SensedData.SheepX(i,:), output.SensedData.SheepY(i,:));
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
                                    
                                    if parameters.InternalMarkerCalculations
                                        varName = [parameters.ScenarioIndex,'_r',num2str(parameters.BatchCurrentRun),'-',num2str(parameters.BatchTotalRuns),'_seed',num2str(parameters.seed(iterator)),'_L',num2str(collision),'_speed',num2str(dogspeed),'_tc',num2str(collect),'_td',num2str(drive),'_w',num2str(parameters.WindowSize),'_o',num2str(parameters.Overlap)];       
                                    else 
                                        varName = [parameters.ScenarioIndex,'_r',num2str(parameters.BatchCurrentRun),'-',num2str(parameters.BatchTotalRuns),'_seed',num2str(parameters.seed(iterator)),'_L',num2str(collision),'_speed',num2str(dogspeed),'_tc',num2str(collect),'_td',num2str(drive)];       
                                    end
                                        save(sprintf('/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE/%s.mat',varName),'output') % macOS-mini
                                        %save(sprintf('/Users/fadamos/GitHub/RecognitionController/SimData/%s.mat',varName),'output') % macOS-mbp
                                        %save(sprintf('C:/Users/danie/OneDrive/Documents/GitHub/RecognitionController/SimData/%s.mat',varName),'output') % WIN
                                %end
                            %end
                        end
                    end
                end
            end
        end
    end
%