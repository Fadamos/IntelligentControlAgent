% Author: Adam J Hepworth
% LastModified: 2022-09-12
% Explanaton: Summarise tactic-pair methods from generated data to
% determine optimal assignments, for a given set of simulation parameters

% read files 

clear
clc

% topLevelFolder = '/Users/ajh/UNSW/Sky Shepherds - FINALv2';

topLevelFolder = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE_CLOCK'; 

%[listOfFolderNames, listOfFileNames, numberOfFolders, allFileInfo, thisFolder, totalNumberOfFiles, baseNameNoExt] = RecurseFolderStructure(myDir);

ScenarioKEY = [];
AgentKEY = []; 
MPstats = []; 
CollectKEY = []; 
DriveKEY = []; 
CLOCK_2 = []; 
CLOCK_3 = [];

    % Initialization steps:
    clc;    % Clear the command window.
    workspace;  % Make sure the workspace panel is showing.
    format long g;
    format compact;
    
    % Specify the file pattern.
    filePattern = sprintf('%s/*.mat', topLevelFolder);
    allFileInfo = dir(filePattern);
    
    % Throw out any folders.  We want files only, not folders.
    isFolder = [allFileInfo.isdir]; % Logical list of what item is a folder or not.
    % Now set those folder entries to null, essentially deleting/removing them from the list.
    allFileInfo(isFolder) = [];
    % Get a cell array of strings.  We don't really use it.  I'm just showing you how to get it in case you want it.
    listOfFolderNames = unique({allFileInfo.folder});
    numberOfFolders = length(listOfFolderNames);
    fprintf('The total number of folders to look in is %d.\n', numberOfFolders);
    
    % Get a cell array of base filename strings.  We don't really use it.  I'm just showing you how to get it in case you want it.
    listOfFileNames = {allFileInfo.name};
    totalNumberOfFiles = length(listOfFileNames);
    fprintf('The total number of files in those %d folders is %d.\n', numberOfFolders, totalNumberOfFiles);
    
    % Process all files in those folders.
    totalNumberOfFiles = length(allFileInfo);
    % Now we have a list of all files, matching the pattern, in the top level folder and its subfolders.
    if totalNumberOfFiles >= 1
	    for k = 1 : totalNumberOfFiles
		    % Go through all those files.
		    thisFolder = allFileInfo(k).folder;
		    thisBaseFileName = allFileInfo(k).name;
		    fullFileName = fullfile(thisFolder, thisBaseFileName);
    % 		fprintf('     Processing file %d of %d : "%s".\n', k, totalNumberOfFiles, fullFileName);
    
		    [~, baseNameNoExt, ~] = fileparts(thisBaseFileName);
		    fprintf('%s\n', baseNameNoExt);
            
            dat = importdata(fullFileName);
            
            % MissionPerformanceStats
            MPstats = [MPstats; dat.MissionPerformanceStatistics];
            ScenarioKEY = [ScenarioKEY; convertCharsToStrings(dat.parameters.ScenarioIndex)]; 
            AgentKEY = [AgentKEY; dat.parameters.Scenario]; 
            CollectKEY = [CollectKEY; dat.parameters.DogCollectingTacticIndex];
            DriveKEY = [DriveKEY; dat.parameters.DogDrivingTacticIndex];
            CLOCK_2 = [CLOCK_2; dat.parameters.SigmaLength];
            CLOCK_3 = [CLOCK_3; dat.parameters.SigmaPositioningPoint];
	    end
    else
	    fprintf('     Folder %s has no files in it.\n', thisFolder);
    end
    fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

% arrange data 
df = table(MPstats(:,1), MPstats(:,2), MPstats(:,3), MPstats(:,4), MPstats(:,5), MPstats(:,6), MPstats(:,7), MPstats(:,8), MPstats(:,9), MPstats(:,10), MPstats(:,11), MPstats(:,12), ScenarioKEY, CollectKEY, DriveKEY, AgentKEY, CLOCK_2, CLOCK_3);
df.Properties.VariableNames = ["Mssn Success" "Decision Chg" "Mssn Length" "Mssn Speed" "Mssn Comp Rate" "Swarm Total Dist" "Swarm Avg Dist" "Cntrl Total Dist" "Cntrl Avg Dist" "Runtime" "Avg Num Sep pi" "Paddock Area" "Scenario" "Collect Tactic" "Drive Tactic" "Agent Distribution" "CLOCK_2" "CLOCK_3"];

%% REGRESSION MODEL --> CLOCK_2 and CLOCK_3 

load('/Users/ajh/GitHub/IntelligentControlAgent/SimData/CLOCK.mat')

% if CLOCK_3 > CLOCK_2, then set CLOCK_3 = CLOCK 2
for  i = 1:size(df,1)
    if df.CLOCK_3(i) > df.CLOCK_2(i)
        df.CLOCK_3(i) = df.CLOCK_2(i); 
    end 
end

% ensure we only train for successful cases (i.e. we don't want to optimise for bad outcomes) 
df_SUB = df(df.("Mssn Success") == 1,:);

df_CLOCK_2 = table(df_SUB.Scenario, df_SUB.("Drive Tactic"), df_SUB.("Collect Tactic"), df_SUB.CLOCK_2); 
df_CLOCK_3 = table(df_SUB.Scenario, df_SUB.("Drive Tactic"), df_SUB.("Collect Tactic"), df_SUB.CLOCK_3);

%df_CLOCK_2 = renamevars(df_CLOCK_2, ["Var1", "Var2", "Var3", "Var4"], ["Scenario", "DriveTactic", "CollectTactic", "CLOCK_2"]);
%df_CLOCK_3 = renamevars(df_CLOCK_3, ["Var1", "Var2", "Var3", "Var4"], ["Scenario", "DriveTactic", "CollectTactic", "CLOCK_3"]);

v1 = categorical(df_CLOCK_2.Var1);
v2 = categorical(df_CLOCK_2.Var2);
v3 = categorical(df_CLOCK_2.Var3);

[logr, dev, stats] = mnrfit(df.CLOCK_2, categorical(df.("Mssn Success"))); 

X = [v1 v2 v3];

fitlm(df_CLOCK_2.Var4, X)

% Tree Regression for simplicity here as a module in the system 

CLOCK_2_regmdl = fitrtree(df_CLOCK_2,'Var4');

xnew = table("S11", "DHH", "F2D"); % how we have to predict the data (easily done in the main code) 
out = predict(tr, df_CLOCK_2(:,1:3));

CLOCK_3_regmdl = fitrtree(df_CLOCK_3,'Var4');





%% OLD FOR SWARM ANALYTICS PAPER 


% organise data by collect and drive tactic pairs PER scenario, speed or collision (needs to be manually changed)

% organise data to a specific dataset by scenario, speed or collision

% scenario response iterator
SCENARIO = "S9"; % replace this with SPEED or COLLISION as required below
% make sure 'sprintf' is used else it won't compare strings
COLLISION = "L1";
SPEED = "Dog1.5"; 
DRIVE = "DOAT";
COLLECT = "F2H";

output = find(DriveKEY==sprintf(DRIVE) & CollectKEY==sprintf(COLLECT) & ScenarioKEY==sprintf(SCENARIO));
output = find(DriveKEY==sprintf(DRIVE) & CollectKEY==sprintf(COLLECT) & CollisionKEY==sprintf(COLLISION) & SpeedKEY==sprintf(SPEED));

%% 25 tactic pairs
% F2H 
DOAT_F2H = find(DriveKEY=="DOAT" & CollectKEY=="F2H" & ScenarioKEY==sprintf(SCENARIO));
DQH_F2H = find(DriveKEY=="DQH" & CollectKEY=="F2H" & ScenarioKEY==sprintf(SCENARIO));
DHH_F2H = find(DriveKEY=="DHH" & CollectKEY=="F2H" & ScenarioKEY==sprintf(SCENARIO));
DTQH_F2H = find(DriveKEY=="DTQH" & CollectKEY=="F2H" & ScenarioKEY==sprintf(SCENARIO));
DAH_F2H = find(DriveKEY=="DAH" & CollectKEY=="F2H" & ScenarioKEY==sprintf(SCENARIO));

% C2H
DOAT_C2H = find(DriveKEY=="DOAT" & CollectKEY=="C2H" & ScenarioKEY==sprintf(SCENARIO));
DQH_C2H = find(DriveKEY=="DQH" & CollectKEY=="C2H" & ScenarioKEY==sprintf(SCENARIO));
DHH_C2H = find(DriveKEY=="DHH" & CollectKEY=="C2H" & ScenarioKEY==sprintf(SCENARIO));
DTQH_C2H = find(DriveKEY=="DTQH" & CollectKEY=="C2H" & ScenarioKEY==sprintf(SCENARIO));
DAH_C2H = find(DriveKEY=="DAH" & CollectKEY=="C2H" & ScenarioKEY==sprintf(SCENARIO));

% F2G
DOAT_F2G = find(DriveKEY=="DOAT" & CollectKEY=="F2G" & ScenarioKEY==sprintf(SCENARIO));
DQH_F2G = find(DriveKEY=="DQH" & CollectKEY=="F2G" & ScenarioKEY==sprintf(SCENARIO));
DHH_F2G = find(DriveKEY=="DHH" & CollectKEY=="F2G" & ScenarioKEY==sprintf(SCENARIO));
DTQH_F2G = find(DriveKEY=="DTQH" & CollectKEY=="F2G" & ScenarioKEY==sprintf(SCENARIO));
DAH_F2G = find(DriveKEY=="DAH" & CollectKEY=="F2G" & ScenarioKEY==sprintf(SCENARIO));

% F2D
DOAT_F2D = find(DriveKEY=="DOAT" & CollectKEY=="F2D" & ScenarioKEY==sprintf(SCENARIO));
DQH_F2D = find(DriveKEY=="DQH" & CollectKEY=="F2D" & ScenarioKEY==sprintf(SCENARIO));
DHH_F2D = find(DriveKEY=="DHH" & CollectKEY=="F2D" & ScenarioKEY==sprintf(SCENARIO));
DTQH_F2D = find(DriveKEY=="DTQH" & CollectKEY=="F2D" & ScenarioKEY==sprintf(SCENARIO));
DAH_F2D = find(DriveKEY=="DAH" & CollectKEY=="F2D" & ScenarioKEY==sprintf(SCENARIO));

% C2D
DOAT_C2D = find(DriveKEY=="DOAT" & CollectKEY=="C2D" & ScenarioKEY==sprintf(SCENARIO));
DQH_C2D = find(DriveKEY=="DQH" & CollectKEY=="C2D" & ScenarioKEY==sprintf(SCENARIO));
DHH_C2D = find(DriveKEY=="DHH" & CollectKEY=="C2D" & ScenarioKEY==sprintf(SCENARIO));
DTQH_C2D = find(DriveKEY=="DTQH" & CollectKEY=="C2D" & ScenarioKEY==sprintf(SCENARIO));
DAH_C2D = find(DriveKEY=="DAH" & CollectKEY=="C2D" & ScenarioKEY==sprintf(SCENARIO));

% calculate summary statistics 



