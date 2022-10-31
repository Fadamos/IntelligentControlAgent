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

df_CRA = df.classic;
df_ICA = df.intelligent; 

scenarios = unique(df_ICA.Scenario);

% (1) Mission Success 

msCRA = df_CRA.("Mssn Success");
msICA = df_ICA.("Mssn Success"); 

% all runs 
[p, h, stats] = ranksum(df_ICA.("Mssn Success"), df_CRA.("Mssn Success"))
[h, p, ci, stats] = ttest2(df_ICA.("Mssn Success"), df_CRA.("Mssn Success"))
[h, p, k2stat] = kstest2(df_ICA.("Mssn Success"), df_CRA.("Mssn Success"))

% He scenarios 
subCRA = msCRA(find(df_CRA.Scenario == scenarios(1) | df_CRA.Scenario == scenarios(4) | df_CRA.Scenario == scenarios(5) | df_CRA.Scenario == scenarios(6)));
subICA = msICA(find(df_ICA.Scenario == scenarios(1) | df_ICA.Scenario == scenarios(4) | df_ICA.Scenario == scenarios(5) | df_ICA.Scenario == scenarios(6)));

[p, h, stats] = ranksum(subCRA, subICA)
[h, p, ci, stats] = ttest2(subCRA, subICA)
[h, p, k2stat] = kstest2(subCRA, subICA)

% Ho scenarios 
subCRA = msCRA(find(df_CRA.Scenario == scenarios(2) | df_CRA.Scenario == scenarios(3) | df_CRA.Scenario == scenarios(7) | df_CRA.Scenario == scenarios(8) | df_CRA.Scenario == scenarios(9) | df_CRA.Scenario == scenarios(10) | df_CRA.Scenario == scenarios(11)));
subICA = msICA(find(df_ICA.Scenario == scenarios(2) | df_ICA.Scenario == scenarios(3) | df_ICA.Scenario == scenarios(7) | df_ICA.Scenario == scenarios(8) | df_ICA.Scenario == scenarios(9) | df_ICA.Scenario == scenarios(10) | df_ICA.Scenario == scenarios(11)));

[p, h, stats] = ranksum(subCRA, subICA)
[h, p, ci, stats] = ttest2(subCRA, subICA)
[h, p, k2stat] = kstest2(subCRA, subICA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = msCRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = msICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

   
% (2) Run Time Performance 

df_CRA = df.classic;
df_ICA = df.intelligent; 

scenarios = unique(df_ICA.Scenario);

msCRA = df_CRA.("Mssn Length");
msICA = df_ICA.("Mssn Length"); 

% all runs 
[p, h, stats] = ranksum(df_ICA.("Mssn Length"), df_CRA.("Mssn Length"))
[h, p, ci, stats] = ttest2(df_ICA.("Mssn Length"), df_CRA.("Mssn Length"))
[h, p, k2stat] = kstest2(df_ICA.("Mssn Length"), df_CRA.("Mssn Length"))

% He scenarios 
subCRA = msCRA(find(df_CRA.Scenario == scenarios(1) | df_CRA.Scenario == scenarios(4) | df_CRA.Scenario == scenarios(5) | df_CRA.Scenario == scenarios(6)));
subICA = msICA(find(df_ICA.Scenario == scenarios(1) | df_ICA.Scenario == scenarios(4) | df_ICA.Scenario == scenarios(5) | df_ICA.Scenario == scenarios(6)));

[p, h, stats] = ranksum(subCRA, subICA)
[h, p, ci, stats] = ttest2(subCRA, subICA)
[h, p, k2stat] = kstest2(subCRA, subICA)

% Ho scenarios 
subCRA = msCRA(find(df_CRA.Scenario == scenarios(2) | df_CRA.Scenario == scenarios(3) | df_CRA.Scenario == scenarios(7) | df_CRA.Scenario == scenarios(8) | df_CRA.Scenario == scenarios(9) | df_CRA.Scenario == scenarios(10) | df_CRA.Scenario == scenarios(11)));
subICA = msICA(find(df_ICA.Scenario == scenarios(2) | df_ICA.Scenario == scenarios(3) | df_ICA.Scenario == scenarios(7) | df_ICA.Scenario == scenarios(8) | df_ICA.Scenario == scenarios(9) | df_ICA.Scenario == scenarios(10) | df_ICA.Scenario == scenarios(11)));

[p, h, stats] = ranksum(subCRA, subICA)
[h, p, ci, stats] = ttest2(subCRA, subICA)
[h, p, k2stat] = kstest2(subCRA, subICA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = msCRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = msICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)

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

df_CRA = df.classic;
df_ICA = df.intelligent; 

scenarios = unique(df_ICA.Scenario);

% (1) Separated agents 

msCRA = df_CRA.("Avg Num Sep pi");
msICA = df_ICA.("Avg Num Sep pi"); 

% all runs 
[p, h, stats] = ranksum(df_ICA.("Avg Num Sep pi"), df_CRA.("Avg Num Sep pi"))
[h, p, ci, stats] = ttest2(df_ICA.("Avg Num Sep pi"), df_CRA.("Avg Num Sep pi"))
[h, p, k2stat] = kstest2(df_ICA.("Avg Num Sep pi"), df_CRA.("Avg Num Sep pi"))

% He scenarios 
subCRA = msCRA(find(df_CRA.Scenario == scenarios(1) | df_CRA.Scenario == scenarios(4) | df_CRA.Scenario == scenarios(5) | df_CRA.Scenario == scenarios(6)));
subICA = msICA(find(df_ICA.Scenario == scenarios(1) | df_ICA.Scenario == scenarios(4) | df_ICA.Scenario == scenarios(5) | df_ICA.Scenario == scenarios(6)));

[p, h, stats] = ranksum(subCRA, subICA)
[h, p, ci, stats] = ttest2(subCRA, subICA)
[h, p, k2stat] = kstest2(subCRA, subICA)

% Ho scenarios 
subCRA = msCRA(find(df_CRA.Scenario == scenarios(2) | df_CRA.Scenario == scenarios(3) | df_CRA.Scenario == scenarios(7) | df_CRA.Scenario == scenarios(8) | df_CRA.Scenario == scenarios(9) | df_CRA.Scenario == scenarios(10) | df_CRA.Scenario == scenarios(11)));
subICA = msICA(find(df_ICA.Scenario == scenarios(2) | df_ICA.Scenario == scenarios(3) | df_ICA.Scenario == scenarios(7) | df_ICA.Scenario == scenarios(8) | df_ICA.Scenario == scenarios(9) | df_ICA.Scenario == scenarios(10) | df_ICA.Scenario == scenarios(11)));

[p, h, stats] = ranksum(subCRA, subICA)
[h, p, ci, stats] = ttest2(subCRA, subICA)
[h, p, k2stat] = kstest2(subCRA, subICA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = msCRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = msICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)

% (2-a) Mission Decision Stability

MDS_CRA = df_CRA.("Mssn Success")./df_CRA.("Decision Chg");
MDS_ICA = df_ICA.("Mssn Success")./df_ICA.("Decision Chg");

[p, h, stats] = ranksum(MDS_ICA, MDS_CRA)
[h, p, ci, stats] = ttest2(MDS_ICA, MDS_CRA)
[h, p, k2stat] = kstest2(MDS_ICA, MDS_CRA)

% Individual scenarios 

    for SCENARIO = 1:11
        subCRA = MDS_CRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = MDS_ICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)

% (2-b) DSS

DSS_CRA = df_CRA.("Avg Num Sep pi")./df_CRA.("Decision Chg");
DSS_ICA = df_ICA.("Avg Num Sep pi")./df_ICA.("Decision Chg");

[p, h, stats] = ranksum(DSS_ICA, DSS_CRA)
[h, p, ci, stats] = ttest2(DSS_ICA, DSS_CRA)
[h, p, k2stat] = kstest2(DSS_ICA, DSS_CRA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = DSS_CRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = DSS_ICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)

% (2-c) MSS

MSS_CRA = df_CRA.("Mssn Success")./df_CRA.("Avg Num Sep pi");
MSS_ICA = df_ICA.("Mssn Success")./df_ICA.("Avg Num Sep pi");

[p, h, stats] = ranksum(MSS_ICA, MSS_CRA)
[h, p, ci, stats] = ttest2(MSS_ICA, DSS_CRA)
[h, p, k2stat] = kstest2(MSS_ICA, MSS_CRA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = MSS_CRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = MSS_ICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)


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

df_CRA = df.classic;
df_ICA = df.intelligent; 

scenarios = unique(df_ICA.Scenario);

% (1) swarm distance moved

STD_CRA = df_CRA.("Swarm Total Dist");
STD_ICA = df_ICA.("Swarm Total Dist");

[p, h, stats] = ranksum(STD_ICA, STD_CRA)
[h, p, ci, stats] = ttest2(STD_ICA, STD_CRA)
[h, p, k2stat] = kstest2(STD_ICA, STD_CRA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = STD_CRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = STD_ICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)


% (2) control agent distance moved

ATD_CRA = df_CRA.("Cntrl Total Dist");
ATD_ICA = df_ICA.("Cntrl Total Dist"); 

[p, h, stats] = ranksum(ATD_ICA, ATD_CRA)
[h, p, ci, stats] = ttest2(ATD_ICA, ATD_CRA)
[h, p, k2stat] = kstest2(ATD_ICA, ATD_CRA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = ATD_CRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = ATD_ICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)

% (3) MS 

MS_CRA = df_CRA.("Mssn Speed");
MS_ICA = df_ICA.("Mssn Speed"); 

[p, h, stats] = ranksum(MS_ICA, MS_CRA)
[h, p, ci, stats] = ttest2(MS_ICA, MS_CRA)
[h, p, k2stat] = kstest2(MS_ICA, MS_CRA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = MS_CRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = MS_ICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)

% (4) MCR 

MCR_CRA = df_CRA.("Mssn Comp Rate");
MCR_ICA = df_ICA.("Mssn Comp Rate"); 

[p, h, stats] = ranksum(MCR_ICA, MCR_CRA)
[h, p, ci, stats] = ttest2(MCR_ICA, MCR_CRA)
[h, p, k2stat] = kstest2(MCR_ICA, MCR_CRA)

% Individual scenarios

    for SCENARIO = 1:11
        subCRA = MCR_CRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = MCR_ICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)
