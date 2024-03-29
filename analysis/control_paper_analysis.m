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

% scenario success comparison
s_CRA = []; 
s_ICA = []; 
for scenario_iterator = 1:11
    s_CRA = [s_CRA; sum(msCRA(find(df_CRA.Scenario == scenarios(scenario_iterator)), :))];
    fprintf('--- CRA --- Scenario: %s Result: , %i \n', scenarios(scenario_iterator), s_CRA(end))
    s_ICA = [s_ICA; sum(msICA(find(df_ICA.Scenario == scenarios(scenario_iterator)), :))];
    fprintf('--- ICA --- Scenario: %s Result: , %i \n\n\n', scenarios(scenario_iterator), s_ICA(end))
end
mean(s_CRA)/10
std(s_CRA)/10
mean(s_ICA)/10
std(s_ICA)/10

ica_sorted = [s_ICA(1); s_ICA(4:end); s_ICA(2); s_ICA(3)];
cra_sorted = [s_CRA(1); s_CRA(4:end); s_CRA(2); s_CRA(3)];

% plot performance
plot(cra_sorted/10, 'LineWidth', 3)
hold on 
plot(ica_sorted/10, 'LineWidth', 3)
hold off
axis([1 11 0 1])
xlabel('Scenarios') 
ylabel('Scenario Performance') 
legend('CRA', 'ICA')
title('Performance Comparison')

cumsum_cra = cumsum(sort(s_CRA/10)/10);
cumsum_ica = cumsum(sort(s_ICA/10)/10);

% plot cumsum 
plot(cumsum_cra, 'LineWidth', 3)
hold on 
plot(cumsum_ica, 'LineWidth', 3)
hold off
axis([1 11 0 1])
xlabel('Scenarios') 
ylabel('Cumulative Performance') 
legend('CRA', 'ICA')
title('Performance Comparison')
xticklabels('')

% IS DATA NORMAL? 
[h p] = kstest(msCRA)
[h p] = kstest(msICA)

% IS VARIANCE EQUAL?
vartestn([msCRA, msICA], 'TestType', 'LeveneAbsolute')

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

    round(CRA,2)
    round(ICA,2)
   
% (2) Run Time Performance 

df_CRA = df.classic;
df_ICA = df.intelligent; 

scenarios = unique(df_ICA.Scenario);

CRAlength = df_CRA.("Mssn Length");
ICAlength = df_ICA.("Mssn Length"); 

% IS DATA NORMAL? 
[h,p] = kstest(msCRA)
[h,p] = kstest(msICA)

% IS VARIANCE EQUAL? 
vartestn([msICA, msCRA], 'TestType', 'LeveneAbsolute')

% all runs 
[p, h, stats] = ranksum(df_ICA.("Mssn Length"), df_CRA.("Mssn Length"))
[h, p, ci, stats] = ttest2(df_ICA.("Mssn Length"), df_CRA.("Mssn Length"))
[h, p, k2stat] = kstest2(df_ICA.("Mssn Length"), df_CRA.("Mssn Length"))

nonzeros(subMScra.*subCRA)

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
        subMScra = msCRA(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subMSica = msICA(find(df_ICA.Scenario == scenarios(SCENARIO)));
        subCRA = CRAlength(find(df_CRA.Scenario == scenarios(SCENARIO)));
        subICA = ICAlength(find(df_ICA.Scenario == scenarios(SCENARIO)));
        try 
            [p, h] = ranksum(nonzeros(subMSica.*subICA), nonzeros(subMScra.*subCRA));
        catch 
            p = -1; 
            h = -1; 
        end
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRA(SCENARIO,1) = nanmean(nonzeros(subMScra.*subCRA)); 
        CRA(SCENARIO,2) = nanstd(nonzeros(subMScra.*subCRA)); 
        ICA(SCENARIO,1) = nanmean(nonzeros(subMSica.*subICA)); 
        ICA(SCENARIO,2) = nanstd(nonzeros(subMSica.*subICA)); 
    end

    round(ICA,2)
    round(CRA,2)
    

% subset of only successful data 


clear
clc
load('/Users/ajh/GitHub/IntelligentControlAgent/analysis/df.mat')

df_CRA = df.classic;
df_ICA = df.intelligent; 

scenarios = unique(df_ICA.Scenario);

msCRA = df_CRA.("Mssn Success");
msICA = df_ICA.("Mssn Success"); 

CRAlength = df_CRA.("Mssn Length");
ICAlength = df_ICA.("Mssn Length"); 

[p, h] = ranksum(nonzeros(msICA.*CRAlength), nonzeros(msICA.*ICAlength));

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

% IS DATA NORMAL? 
[h,p] = kstest(msCRA)
[h,p] = kstest(msICA)

% IS VARIANCE EQUAL? 
vartestn([msICA, msCRA], 'TestType', 'LeveneAbsolute')

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

    mean(round(CRA,2))
    mean(round(ICA,2))

% (2-a) Mission Decision Stability

MDS_CRA = df_CRA.("Mssn Success")./df_CRA.("Decision Chg");
MDS_ICA = df_ICA.("Mssn Success")./df_ICA.("Decision Chg");

% IS DATA NORMAL? 
[h,p] = kstest(msCRA)
[h,p] = kstest(MDS_ICA)

% IS VARIANCE EQUAL? 
vartestn([MDS_ICA, MDS_CRA], 'TestType', 'LeveneAbsolute')

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

    mean(round(CRA,2))
    mean(round(ICA,2))

% (2-b) DSS

DSS_CRA = df_CRA.("Avg Num Sep pi")./(df_CRA.("Decision Chg")+1);
DSS_ICA = df_ICA.("Avg Num Sep pi")./(df_ICA.("Decision Chg")+1);

% IS DATA NORMAL? 
[h,p] = kstest(DSS_CRA)
[h,p] = kstest(DSS_ICA)

% IS VARIANCE EQUAL? 
vartestn([DSS_ICA, DSS_CRA], 'TestType', 'LeveneAbsolute')

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

    mean(round(CRA,2))
    mean(round(ICA,2))

% (2-c) MSS

MSS_CRA = df_CRA.("Mssn Success")./df_CRA.("Avg Num Sep pi");
MSS_ICA = df_ICA.("Mssn Success")./df_ICA.("Avg Num Sep pi");

% IS DATA NORMAL? 
[h,p] = kstest(MSS_CRA)
[h,p] = kstest(MSS_ICA)

% IS VARIANCE EQUAL? 
vartestn([MSS_ICA, MSS_CRA], 'TestType', 'LeveneAbsolute')

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

    mean(round(CRA,2))
    mean(round(ICA,2))

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

% IS DATA NORMAL? 
[h,p] = kstest(STD_CRA)
[h,p] = kstest(STD_ICA)

% IS VARIANCE EQUAL? 
vartestn([STD_ICA, STD_CRA], 'TestType', 'LeveneAbsolute')

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
        p = anova1([subICA, subCRA]);
        %pANOVA(SCENARIO) = p; 
        %clear p
        CRA(SCENARIO,1) = nanmean(subCRA); 
        CRA(SCENARIO,2) = nanstd(subCRA); 
        ICA(SCENARIO,1) = nanmean(subICA); 
        ICA(SCENARIO,2) = nanstd(subICA); 
    end

    round(CRA,2)
    round(ICA,2)

    mean(round(CRA,2))
    mean(round(ICA,2))


% (2) control agent distance moved

ATD_CRA = df_CRA.("Cntrl Total Dist");
ATD_ICA = df_ICA.("Cntrl Total Dist"); 

% IS DATA NORMAL? 
[h,p] = kstest(ATD_CRA)
[h,p] = kstest(ATD_ICA)

% IS VARIANCE EQUAL? 
vartestn([ATD_ICA, ATD_CRA], 'TestType', 'LeveneAbsolute')

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

    mean(round(CRA,2))
    mean(round(ICA,2))

% (3) MSp

MS_CRA = df_CRA.("Mssn Speed");
MS_ICA = df_ICA.("Mssn Speed"); 

% IS DATA NORMAL? 
[h,p] = kstest(MS_CRA)
[h,p] = kstest(MS_ICA)

% IS VARIANCE EQUAL? 
vartestn([MS_ICA, MS_CRA], 'TestType', 'LeveneAbsolute')

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

    mean(round(CRA,2))
    mean(round(ICA,2))

% (4) MCR 

MCR_CRA = df_CRA.("Mssn Comp Rate");
MCR_ICA = df_ICA.("Mssn Comp Rate");

% IS DATA NORMAL? 
[h,p] = kstest(MCR_CRA)
[h,p] = kstest(MCR_ICA)

% IS VARIANCE EQUAL? 
vartestn([MCR_ICA,  MCR_CRA], 'TestType', 'LeveneAbsolute')

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

    mean(round(CRA,2))
    mean(round(ICA,2))

%% Controlability Metric 

% How many agents are under the influence of the shepherding agent? 
% Metric: Calculate at each time step how many sheep are within the influence range of the dog 

% 1- get data set

clear 
clc

topLevelFolderMarkers = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/control_sim/markers';

%%%%% MARKERS %%%%% 

ScenarioKEY = [];
RunKEY = []; 
MPstats = []; 
SwarmX = []; 
SwarmY = []; 
CtrlX = []; 
CtrlY = []; 

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
        SwarmX = [SwarmX; dat.SensedData.SheepX];
        SwarmY = [SwarmY; dat.SensedData.SheepY];
        CtrlX = [CtrlX; dat.SensedData.SheepDogX'];
        CtrlY = [CtrlY; dat.SensedData.SheepDogY'];
        ScenarioKEY = [ScenarioKEY; repmat(convertCharsToStrings(dat.parameters.ScenarioIndex), size(dat.SensedData.SheepX,1), 1)]; 
        RunKEY = [RunKEY; repmat(dat.parameters.BatchCurrentRun, size(dat.SensedData.SheepX,1), 1)];
	end
else
	fprintf('     Folder %s has no files in it.\n', thisFolder);
end
fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

% arrange data 
dfA4markers = table(RunKEY, ScenarioKEY, SwarmX, SwarmY, CtrlX, CtrlY);

save('dfA4markers', 'dfA4markers')

%%%%% CLASSIC %%%%% 

clear 
clc

topLevelFolderMarkers = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/control_sim/classic';

%%%%% MARKERS %%%%% 

ScenarioKEY = [];
RunKEY = []; 
MPstats = []; 
SwarmX = []; 
SwarmY = []; 
CtrlX = []; 
CtrlY = []; 

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
        SwarmX = [SwarmX; dat.SensedData.SheepX];
        SwarmY = [SwarmY; dat.SensedData.SheepY];
        CtrlX = [CtrlX; dat.SensedData.SheepDogX'];
        CtrlY = [CtrlY; dat.SensedData.SheepDogY'];
        ScenarioKEY = [ScenarioKEY; repmat(convertCharsToStrings(dat.parameters.ScenarioIndex), size(dat.SensedData.SheepX,1), 1)]; 
        RunKEY = [RunKEY; repmat(dat.parameters.BatchCurrentRun, size(dat.SensedData.SheepX,1), 1)];
	end
else
	fprintf('     Folder %s has no files in it.\n', thisFolder);
end
fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

% arrange data 
dfA4classic = table(RunKEY, ScenarioKEY, SwarmX, SwarmY, CtrlX, CtrlY);

save('dfA4classic', 'dfA4classic')


% 2- compare position of each agent to that of the dog using the influence range and count the number of agents at each period under influence

clear
clc

load('/Users/ajh/GitHub/IntelligentControlAgent/SimData/dfA4.mat')

influence_range = 65; 

for t = 1:size(dfA4.markers,1)
    cnt = 0; 
    for pi = 1:size(dfA4.markers.SwarmX,2)
            cnt = cnt + double(pdist2([dfA4.markers.CtrlX(t) dfA4.markers.CtrlY(t)],[dfA4.markers.SwarmX(t,pi) dfA4.markers.SwarmX(t,pi)]) <= influence_range); 
    end
    influence_pi(t) = cnt;
end

dfA4.markers.influence_pi = influence_pi';
dfA4.markers

clear influence_pi

for t = 1:size(dfA4.classic,1)
    cnt = 0; 
    for pi = 1:size(dfA4.classic.SwarmX,2)
            cnt = cnt + double(pdist2([dfA4.classic.CtrlX(t) dfA4.classic.CtrlY(t)],[dfA4.classic.SwarmX(t,pi) dfA4.classic.SwarmX(t,pi)]) <= influence_range); 
    end
    influence_pi(t) = cnt;
end

dfA4.classic.influence_pi = influence_pi';
dfA4.classic

save('dfA4', 'dfA4')

% 3- calculate statistics for each scenario (intelligent vs classic)

clear
clc

load('/Users/ajh/GitHub/IntelligentControlAgent/SimData/dfA4.mat')

ICA = dfA4.markers.influence_pi;
CRA = dfA4.classic.influence_pi; 

[p, h, stats] = ranksum(ICA, CRA)

[round(mean(ICA),2) round(std(ICA),2)]
[round(mean(CRA),2) round(std(CRA),2)]

scenarios = unique(dfA4.markers.ScenarioKEY);

    for SCENARIO = 1:11
        subICA = ICA(find(dfA4.markers.ScenarioKEY == scenarios(SCENARIO)));
        subCRA = CRA(find(dfA4.classic.ScenarioKEY == scenarios(SCENARIO)));
        [p, h] = ranksum(subICA, subCRA);
        pRS(SCENARIO) = p; hRS(SCENARIO) = h; 
        clear p h
        [h, p] = ttest2(subICA, subCRA);
        hT(SCENARIO) = h; pT(SCENARIO) = p; 
        clear h p
        [h, p] = kstest2(subICA, subCRA);
        hKS(SCENARIO) = h; pKS(SCENARIO) = p; 
        clear h p 
        CRAstats(SCENARIO,1) = nanmean(subCRA); 
        CRAstats(SCENARIO,2) = nanstd(subCRA); 
        ICAstats(SCENARIO,1) = nanmean(subICA); 
        ICAstats(SCENARIO,2) = nanstd(subICA); 
    end

    round(ICAstats,2)
    round(CRAstats,2)

    mean(round(ICAstats,2))
    mean(round(CRAstats,2))


%% Summary analysis for evaluation discussions

mssn_len = [1136.4 665 863.1 3702.6 4099 1617.6 989 1187.5 768.7 3879.2 4824.9; 2956.3 4721.4 2229 4393.4 4507.9 2571.3 1891.6 2447.2 1182.8 5149 4471.6];
mssn_len_s = [690.6 665 863.1 2256.2 2524 734.8 526.8 747.3 768.7 2609.4 3528.5; 2016.6 3723.7 1904.6 2623.3 3866.8 2284.9 1891.6 1771.7 1182.8 0 4020];
swarm_dist = [175.39 173.59 173.59 168.82 159.24 172.37 175.44 174.8 176.36 173.04 164.92; 97.38 133.07 88.3 67.33 56.2 103.96 141.17 125.69 60.02 110.95 111.23];
msp = [0.24 0.27 0.23 0.06 0.05 0.21 0.31 0.23 0.23 0.06 0.04; 0.07 0.03 0.09 0.04 0.03 0.08 0.11 0.09 0.15 0.02 0.04];


[r,p] = corrcoef(mssn_len(1,:), swarm_dist(1,:))
[r,p] = corrcoef(mssn_len(2,:), swarm_dist(2,:))

[r,p] = corrcoef(mssn_len_s(1,:), swarm_dist(1,:))
[r,p] = corrcoef(mssn_len_s(2,:), swarm_dist(2,:))

[r,p] = corrcoef(mssn_len(1,:), msp(1,:))
[r,p] = corrcoef(mssn_len(2,:), msp(2,:))

[r,p] = corrcoef(mssn_len_s(1,:), msp(1,:))
[r,p] = corrcoef(mssn_len_s(2,:), msp(2,:))

[r,p] = corrcoef(swarm_dist(1,:), msp(1,:))
[r,p] = corrcoef(swarm_dist(2,:), msp(2,:))

%% Decisions vs number of separated agents 

mrk_sep = df_CRA.("Avg Num Sep pi"); 
cls_sep = df_CRA.("Avg Num Sep pi");

mrk_dec = df_ICA.("Decision Chg");
cls_dec = df_ICA.("Decision Chg");

scenarios = unique(df_CRA.Scenario);

    for SCENARIO = 1:11
        sub_mrk_sep = mrk_sep(find(df_ICA.Scenario == scenarios(SCENARIO)));
        sub_cls_sep = cls_sep(find(df_CRA.Scenario == scenarios(SCENARIO)));
        sub_mrk_dec = mrk_dec(find(df_ICA.Scenario == scenarios(SCENARIO)));
        sub_cls_dec = cls_dec(find(df_CRA.Scenario == scenarios(SCENARIO)));
        
        MrkSep(SCENARIO) = nanmean(sub_mrk_sep); 
        ClsSep(SCENARIO) = nanmean(sub_cls_sep); 
        MrkDec(SCENARIO) = nanmean(sub_mrk_dec); 
        ClsDec(SCENARIO) = nanmean(sub_cls_dec); 
    end

    [r,p] = corrcoef(MrkSep, MrkDec)
    [r,p] = corrcoef(ClsSep, ClsDec)