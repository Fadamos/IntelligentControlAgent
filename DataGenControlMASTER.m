% Author: Adam J Hepwort
% LastModified: 2022-10-27
% Explanaton: Experimentation data generation and analysis script
% Purpose: Agent performance testing 

    %% scenario generation
    
    clear
    clc

    % user set this
    parameters.Adam = true; 
    
    parameters.ScenarioIterator = ["S1","S2","S3","S4","S5","S6","S7","S8","S9","S10","S11"]; % manually set per terminal! 
    parameters.replicates = 10; 
    parameters.BatchCurrentRun = 0; 
    parameters.BatchTotalRuns = 110; 
    
    %parameters.seedGen = randperm(1000000,30); % seed already generated here and saved as 'seed.mat' for 
    %parameters.seed = parameters.seedGen;
    
    %load('/Users/ajh/GitHub/RecognitionController/seed.mat') % load seed setting

    for scenario = 1:size(parameters.ScenarioIterator,2) % scenario iterate 
        parameters.ScenarioIndex = char(parameters.ScenarioIterator(scenario));
        for iterator = 1:parameters.replicates % replicates of each scenario, integer 
                                    parameters.Replicate = iterator;
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
                                        fprintf('\nSim failed for: sim run=%i; iterator=%i.\n',parameters.BatchCurrentRun,iterator)          
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
                                        varName = [parameters.ScenarioIndex,'_r',num2str(parameters.BatchCurrentRun),'-',num2str(parameters.BatchTotalRuns),'_seed',num2str(parameters.seed(iterator))];       
                                        save(sprintf('/Users/ajh/GitHub/IntelligentControlAgent/SimData/control_sim/classic/%s.mat',varName),'output') % macOS-mini
                                        %save(sprintf('/Users/fadamos/GitHub/RecognitionController/SimData/%s.mat',varName),'output') % macOS-mbp
                                        %save(sprintf('C:/Users/danie/OneDrive/Documents/GitHub/RecognitionController/SimData/%s.mat',varName),'output') % WIN
        end
    end
%