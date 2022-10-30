% Author: Adam J Hepworth
% LastModified: 2022-10-30
% Explanaton: Analysis script for control agent paper (submitted to Swarm Intelligence) 


%% Init Data 

%%%%% MARKERS %%%%% 

clear 
clc

topLevelFolderMarkers = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/control_sim/markers';

ScenarioKEY = [];
AgentKEY = []; 
MPstats = []; 
CollectKEY = []; 
DriveKEY = []; 

format long g;
format compact;

% Specify the file pattern.
filePattern = sprintf('%s/*.mat', topLevelFolderMarkers);
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
 		%fprintf(' Processing file %d of %d : "%s".\n', k, totalNumberOfFiles, fullFileName);

		[~, baseNameNoExt, ~] = fileparts(thisBaseFileName);
		fprintf('%s\n', baseNameNoExt);

        dat = importdata(fullFileName);
            
        % MissionPerformanceStats
        MPstats = [MPstats; dat.MissionPerformanceStatistics];
        ScenarioKEY = [ScenarioKEY; convertCharsToStrings(dat.parameters.ScenarioIndex)]; 
        AgentKEY = [AgentKEY; dat.parameters.Scenario]; 
        CollectKEY = [CollectKEY; dat.parameters.DogCollectingTacticIndex];
        DriveKEY = [DriveKEY; dat.parameters.DogDrivingTacticIndex];
	end
else
	fprintf('     Folder %s has no files in it.\n', thisFolder);
end
fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

% arrange data 
dfMARKERS = table(MPstats(:,1), MPstats(:,2), MPstats(:,3), MPstats(:,4), MPstats(:,5), MPstats(:,6), MPstats(:,7), MPstats(:,8), MPstats(:,9), MPstats(:,10), MPstats(:,11), MPstats(:,12), ScenarioKEY, CollectKEY, DriveKEY, AgentKEY);
dfMARKERS.Properties.VariableNames = ["Mssn Success" "Decision Chg" "Mssn Length" "Mssn Speed" "Mssn Comp Rate" "Swarm Total Dist" "Swarm Avg Dist" "Cntrl Total Dist" "Cntrl Avg Dist" "Runtime" "Avg Num Sep pi" "Paddock Area" "Scenario" "Collect Tactic" "Drive Tactic" "Agent Distribution"];

save('dfMARKERS', 'dfMARKERS')

%%%%% CLASSIC %%%%% 

clear
clc

topLevelFolderClassic = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/control_sim/classic';

ScenarioKEY = [];
AgentKEY = []; 
MPstats = []; 
CollectKEY = []; 
DriveKEY = []; 

format long g;
format compact;

% Specify the file pattern.
filePattern = sprintf('%s/*.mat', topLevelFolderClassic);
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
% 		fprintf(' Processing file %d of %d : "%s".\n', k, totalNumberOfFiles, fullFileName);

		[~, baseNameNoExt, ~] = fileparts(thisBaseFileName);
		fprintf('%s\n', baseNameNoExt);

        dat = importdata(fullFileName);
            
        % MissionPerformanceStats
        MPstats = [MPstats; dat.MissionPerformanceStatistics];
        ScenarioKEY = [ScenarioKEY; convertCharsToStrings(dat.parameters.ScenarioIndex)]; 
        AgentKEY = [AgentKEY; dat.parameters.Scenario]; 
        CollectKEY = [CollectKEY; dat.parameters.DogCollectingTacticIndex];
        DriveKEY = [DriveKEY; dat.parameters.DogDrivingTacticIndex];
	end
else
	fprintf('     Folder %s has no files in it.\n', thisFolder);
end
fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

% arrange data 
dfCLASSIC = table(MPstats(:,1), MPstats(:,2), MPstats(:,3), MPstats(:,4), MPstats(:,5), MPstats(:,6), MPstats(:,7), MPstats(:,8), MPstats(:,9), MPstats(:,10), MPstats(:,11), MPstats(:,12), ScenarioKEY, CollectKEY, DriveKEY, AgentKEY);
dfCLASSIC.Properties.VariableNames = ["Mssn Success" "Decision Chg" "Mssn Length" "Mssn Speed" "Mssn Comp Rate" "Swarm Total Dist" "Swarm Avg Dist" "Cntrl Total Dist" "Cntrl Avg Dist" "Runtime" "Avg Num Sep pi" "Paddock Area" "Scenario" "Collect Tactic" "Drive Tactic" "Agent Distribution"];

save('dfCLASSIC', 'dfCLASSIC')

df.classic = dfCLASSIC;
df.intelligent = dfMARKERS;

save('IntelligentControlAgent/analysis/df','df')

%% Analysis 1 - Mission Performance 
%   Intent:                     Compare mission performance of Intelligent Context Agent (ICA) and Classic Reactive Agent (CRA) across heterogeneous and homogeneous settings
%   Hypothesis:                 ICA > CRA 
%   Method:                     Summarise runs (1) for each scenario (2) for each scenario type (He, Ho) and (3) accross all scenarios (S0)
%   Key Metrics:                (1) Mission Success
%   Research Questions: 
%                               (1) Which agent performs better in aggregate, for heterogeneous settings and for homogeneous settings? 
%                               (2) What is the distribution of agent run-time performance? 
%   Statistical verification: 
%                               (1) t-test: Test difference in mean success rate across each scenario, for He settins, Ho settings and aggregate
%                               (2) KS Test or KL Divergence: Compare run-time distribution of agents

clear
clc
load('/Users/ajh/GitHub/IntelligentControlAgent/analysis/df.mat')



%% Analysis 2 - Control Impact on Stability 
%   Intent:                     Compare stability of the mission and swarm 
%   Hypothesis:                 ICA > CRA 
%   Method:                     Summarise runs (1) for each scenario (2) for each scenario type (He, Ho) and (3) accross all scenarios (S0)
%   Key Metrics:                (1) Number of Separated Swarm Agents (2) MDS (3) DSS (4) MSS
%   Research Questions: 
%                               (1) Which agent has greater stability in aggregate, for heterogeneous settings, and homogeneous settings?
%                               (2) Which agent has a lower mean number of separated swarm agents? 
%   Statistical verification: 
%                               (1) t-test: difference in stability for He, Ho and S0
%                               (2) t-test: difference in mean separated agents for He, Ho and S0   

clear
clc
load('/Users/ajh/GitHub/IntelligentControlAgent/analysis/df.mat')



%% Analysis 3 - Control Efficiency
%   Intent:                     Compare the efficiency of each method     
%   Hypothesis:                 ICA > CRA
%   Method:                     Summarise runs (1) for each scenario (2) for each scenario type (He, Ho) (3) accross all scenarios (S0)
%   Key Metrics:                (1) Total distance moved by the swarm (2) Total distance moved by the control agent (3) MS (4) MCR 
%   Research Questions: 
%                               (1) What is the difference in the distribution of total swarm movement in aggregate, for heterogeneous settings and for homogeneous settings? 
%                               (2) What is the difference in the distribution of total control agent movement in aggregate, for heterogeneous settings and for homogeneous settings?
%                               (3) Which agent type leads to greater swarm efficiency in aggregate, for heterogeneous settings and for homogeneous settings? 
%                               (4) Which agent type leads to greater swarm efficiency in aggregate, for heterogeneous settings and for homogeneous settings? 
%   Statistical verification: 
%                               (1) KS test or KL divergence: swarm distance distribution 
%                               (2) KS test or KL divergence: agent distance distribution
%                               (3) t-test: difference in swarm distance travelled for He, Ho and S0
%                               (4) t-test: difference in agent distance travelled for He, Ho and S0 

clear
clc
load('/Users/ajh/GitHub/IntelligentControlAgent/analysis/df.mat')

