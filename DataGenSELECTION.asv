% Author: Adam J Hepworth
% LastModified: 2022-08-18
% Explanaton: Summarise tactic-pair methods from generated data to
% determine optimal assignments, for a given set of simulation parameters

% read files 

clear
clc

topLevelFolder = '/Users/ajh/UNSW/Sky Shepherds - FINALv2'; 
%[listOfFolderNames, listOfFileNames, numberOfFolders, allFileInfo, thisFolder, totalNumberOfFiles, baseNameNoExt] = RecurseFolderStructure(myDir);

ScenarioKEY = [];
CollisionKEY = [];
SpeedKEY = []; 
MPstats = []; 
CollectKEY = []; 
DriveKEY = []; 


    % Initialization steps:
    clc;    % Clear the command window.
    workspace;  % Make sure the workspace panel is showing.
    format long g;
    format compact;
    
    % Specify the file pattern.
    filePattern = sprintf('%s/**/*.mat', topLevelFolder);
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
            SpeedKEY = [SpeedKEY; dat.parameters.SheepDogVehicleSpeedLimit];
            CollisionKEY = [CollisionKEY; dat.parameters.CollisionRange];
            CollectKEY = [CollectKEY; dat.parameters.DogCollectingTacticIndex];
            DriveKEY = [DriveKEY; dat.parameters.DogDrivingTacticIndex];
	    end
    else
	    fprintf('     Folder %s has no files in it.\n', thisFolder);
    end
    fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

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



