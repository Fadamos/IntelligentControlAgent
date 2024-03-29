% Author: Aam J Hepworth
% LastModified: 2022-08-12
% Explanaton: Experimentation and analysis script for Information Markers paper

%% INFORMATION MARKERS VISUALISATIONS - "FOOTPRINTS" 

fn = fieldnames(output.MarkerSet);
q=42; % number of markers 
p=20; % number of agents 
w = length(fn); % number of marker windows

markers3D = nan(q,p,w);

for seqIter = 1:numel(fn)
    tmp = output.MarkerSet.(fn{seqIter}).MarkerState; 
    markers3D(:,:,seqIter) = tmp;
    clear tmp 
end

load('/Users/ajh/GitHub/swarmRecognition/SSCI22/MarkerData/s1_rep1_seed106.mat')
markers3D = df.MarkerState; 

% Figure 1
figure(1)
imagesc(normalize(squeeze(markers3D(15,:,:))))
title('Marker $M_{15}$ for Swarm $\Pi$','interpreter','latex','FontSize',20)
ylabel('Swarm Agents $\pi_{1\dots 23}$','interpreter','latex','FontSize', 16)
xlabel('Window','interpreter','latex','FontSize', 16)
colorbar()

% Figure 2
figure(2)
imagesc(normalize(squeeze(markers3D(19,:,:))))
title('Marker $M_{19}$ for Swarm $\Pi$','interpreter','latex','FontSize',20)
ylabel('Swarm Agents $\pi_{1\dots 23}$','interpreter','latex','FontSize', 16)
xlabel('Window','interpreter','latex','FontSize', 16)
colorbar()

% Figure 3
figure(3)
imagesc(normalize(squeeze(markers3D(:,15,:))))
title('Marker set $M_{1\dots 23}$ for Agent $\pi_{15}$','interpreter','latex','FontSize',20)
ylabel('Markers $M_{1\dots 23}$','interpreter','latex','FontSize', 16) 
xlabel('Window','interpreter','latex','FontSize', 16)
colorbar()

% Figure 4 
figure(4)
imagesc(normalize(squeeze(markers3D(:,3,:))))
title('Marker set $M_{1\dots 23}$ for Agent $\pi_{3}$','interpreter','latex','FontSize',20)
ylabel('Markers $M_{1\dots 23}$','interpreter','latex','FontSize', 16) 
xlabel('Window','interpreter','latex','FontSize', 16)
colorbar()

% marker set per agent 
for i = 1:p
    figure(i)
    imagesc(normalize(squeeze(markers3D(:,i,:))))
end

% all agents per marker
for i = 1:q
    figure(i)
    imagesc(normalize(squeeze(markers3D(i,:,:))))
end

%% M1 - AGENT STATIONARY 
% Objective: discover the profile of an agent (agent type)
% Evaluation: (1) class accuracy (during training), (2) compare to a
% 'classic' method such as training a classifier on information only and
% (3) Value of Information to identify the optimal [window] + [overlap] to increase classification accuracy

%% Build data 
ClassicData = false; 

% initialise data
if ClassicData 
    myDir = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/dataClassic'; 
else 
    myDir = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE'; 
end
myFiles = dir(fullfile(myDir, '*.mat')); 

FlatMarker = [];
ClassY = [];
MasterKey = []; 
TimeCost = []; 
ClassYswarm = []; 

% generate flat file 
for simRun = 1:length(myFiles)
    % import 
    baseFileName = myFiles(simRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    dat = importdata(fullFileName);

    % consolidate data 
    fnWindow = fieldnames(dat.MarkerSet);  
    for WindowIter = 1:numel(fnWindow)
        FlatMarker = [FlatMarker; dat.MarkerSet.(fnWindow{WindowIter}).MarkerState'];
        ClassY = [ClassY; dat.parameters.SwarmAgentTypeDistribution'];
        tmp = repmat([dat.parameters.WindowSize, dat.parameters.Overlap], length(dat.parameters.SwarmAgentTypeDistribution), 1); 
        MasterKey = [MasterKey; tmp];
        clear tmp
        tmp = [dat.parameters.WindowSize dat.parameters.Overlap mean(dat.MarkerEvalVOI.Cost(:,2)) dat.MarkerEvalVOI.Cost(end,3)]; 
        TimeCost = [TimeCost; tmp];
        clear tmp 
    end
end

% randomly shuffle marker state to break data dependencies 
NewOrder = size(FlatMarker,1);
for i = 1:10 
    NewRowOrder = randperm(NewOrder);
end

FlatMarker = FlatMarker(NewRowOrder,:);
ClassY = ClassY(NewRowOrder,:);
MasterKey = MasterKey(NewRowOrder,:); 

%% M1 - Agent Classification Table - Optimal performance
% subset by [window] and [overlap] 
%window = 20; % [20 40 60 80 100]
%overlap = 0.25; % [0.25 0.50 0.75]

%idx = find(MasterKey(:,1)==window & MasterKey(:,2)==overlap); 
idx20_025 = find(MasterKey(:,1)==20 & MasterKey(:,2)==0.25); 
idx20_050 = find(MasterKey(:,1)==20 & MasterKey(:,2)==0.50); 
idx20_075 = find(MasterKey(:,1)==20 & MasterKey(:,2)==0.75); 
idx40_025 = find(MasterKey(:,1)==40 & MasterKey(:,2)==0.25); 
idx40_050 = find(MasterKey(:,1)==40 & MasterKey(:,2)==0.50); 
idx40_075 = find(MasterKey(:,1)==40 & MasterKey(:,2)==0.75); 
idx60_025 = find(MasterKey(:,1)==60 & MasterKey(:,2)==0.25); 
idx60_050 = find(MasterKey(:,1)==60 & MasterKey(:,2)==0.50); 
idx60_075 = find(MasterKey(:,1)==60 & MasterKey(:,2)==0.75); 
idx80_025 = find(MasterKey(:,1)==80 & MasterKey(:,2)==0.25); 
idx80_050 = find(MasterKey(:,1)==80 & MasterKey(:,2)==0.50); 
idx80_075 = find(MasterKey(:,1)==80 & MasterKey(:,2)==0.75); 
idx100_025 = find(MasterKey(:,1)==100 & MasterKey(:,2)==0.25); 
idx100_050 = find(MasterKey(:,1)==100 & MasterKey(:,2)==0.50); 
idx100_075 = find(MasterKey(:,1)==100 & MasterKey(:,2)==0.75); 

FLATidx20_025 = FlatMarker(idx20_025,:);
CLASSidx20_025 = ClassY(idx20_025,:);

FLATidx20_050 = FlatMarker(idx20_050,:); 
CLASSidx20_050 = ClassY(idx20_050,:);

FLATidx20_075 = FlatMarker(idx20_075,:); 
CLASSidx20_075 = ClassY(idx20_075,:);

FLATidx40_025 = FlatMarker(idx40_025,:);
CLASSidx40_025 = ClassY(idx40_025,:);

FLATidx40_050 = FlatMarker(idx40_050,:);
CLASSidx40_050 = ClassY(idx40_050,:);

FLATidx40_075 = FlatMarker(idx40_075,:);
CLASSidx40_075 = ClassY(idx40_075,:);

FLATidx60_025 = FlatMarker(idx60_025,:);
CLASSidx60_025 = ClassY(idx60_025,:);

FLATidx60_050 = FlatMarker(idx60_050,:);
CLASSidx60_050 = ClassY(idx60_050,:);

FLATidx60_075 = FlatMarker(idx60_075,:);
CLASSidx60_075 = ClassY(idx60_075,:);

FLATidx80_025 = FlatMarker(idx80_025,:);
CLASSidx80_025 = ClassY(idx80_025,:);

FLATidx80_050 = FlatMarker(idx80_050,:);
CLASSidx80_050 = ClassY(idx80_050,:);

FLATidx80_075 = FlatMarker(idx80_075,:);
CLASSidx80_075 = ClassY(idx80_075,:);

FLATidx100_025 = FlatMarker(idx100_025,:);
CLASSidx100_025 = ClassY(idx100_025,:);

FLATidx100_050 = FlatMarker(idx100_050,:);
CLASSidx100_050 = ClassY(idx100_050,:);

FLATidx100_075 = FlatMarker(idx100_075,:);
CLASSidx100_075 = ClassY(idx100_075,:);

% convert to table 
AgentX = array2table(FLATidx100_075); 
AgentY = CLASSidx100_075; 

clear AgentX AgentY

% save classification-ready data
if ClassicData 
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/dataClassic/AgentX.mat',"AgentX")
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/dataClassic/AgentY.mat',"AgentY")
else 
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE/AgentX.mat',"AgentX")
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE/AgentY.mat',"AgentY")
end 

%% Agent Classification - Eval VOI Cost 
TimeCost20_025 = TimeCost(find(TimeCost(:,1)==20 & TimeCost(:,2)==0.25),:); 
TimeCost20_050 = TimeCost(find(TimeCost(:,1)==20 & TimeCost(:,2)==0.50),:); 
TimeCost20_075 = TimeCost(find(TimeCost(:,1)==20 & TimeCost(:,2)==0.75),:); 
TimeCost40_025 = TimeCost(find(TimeCost(:,1)==40 & TimeCost(:,2)==0.25),:); 
TimeCost40_050 = TimeCost(find(TimeCost(:,1)==40 & TimeCost(:,2)==0.50),:); 
TimeCost40_075 = TimeCost(find(TimeCost(:,1)==40 & TimeCost(:,2)==0.75),:); 
TimeCost60_025 = TimeCost(find(TimeCost(:,1)==60 & TimeCost(:,2)==0.25),:); 
TimeCost60_050 = TimeCost(find(TimeCost(:,1)==60 & TimeCost(:,2)==0.50),:); 
TimeCost60_075 = TimeCost(find(TimeCost(:,1)==60 & TimeCost(:,2)==0.75),:); 
TimeCost80_025 = TimeCost(find(TimeCost(:,1)==80 & TimeCost(:,2)==0.25),:); 
TimeCost80_050 = TimeCost(find(TimeCost(:,1)==80 & TimeCost(:,2)==0.50),:); 
TimeCost80_075 = TimeCost(find(TimeCost(:,1)==80 & TimeCost(:,2)==0.75),:); 
TimeCost100_025 = TimeCost(find(TimeCost(:,1)==100 & TimeCost(:,2)==0.25),:); 
TimeCost100_050 = TimeCost(find(TimeCost(:,1)==100 & TimeCost(:,2)==0.50),:); 
TimeCost100_075 = TimeCost(find(TimeCost(:,1)==100 & TimeCost(:,2)==0.75),:); 

mean(TimeCost20_025(:,3))
sum(TimeCost20_025(:,3))/11

mean(TimeCost20_050(:,3))
sum(TimeCost20_050(:,3))/11

mean(TimeCost20_075(:,3))
sum(TimeCost20_075(:,3))/11

mean(TimeCost40_025(:,3))
sum(TimeCost40_025(:,3))/11

mean(TimeCost40_050(:,3))
sum(TimeCost40_050(:,3))/11

mean(TimeCost40_075(:,3))
sum(TimeCost40_075(:,3))/11

mean(TimeCost60_025(:,3))
sum(TimeCost60_025(:,3))/11

mean(TimeCost60_050(:,3))
sum(TimeCost60_050(:,3))/11

mean(TimeCost60_075(:,3))
sum(TimeCost60_075(:,3))/11

mean(TimeCost80_025(:,3))
sum(TimeCost80_025(:,3))/11

mean(TimeCost80_050(:,3))
sum(TimeCost80_050(:,3))/11

mean(TimeCost80_075(:,3))
sum(TimeCost80_075(:,3))/11

mean(TimeCost100_025(:,3))
sum(TimeCost100_025(:,3))/11

mean(TimeCost100_050(:,3))
sum(TimeCost100_050(:,3))/11

mean(TimeCost100_075(:,3))
sum(TimeCost100_075(:,3))/11

%% Selecting optimal observation window size and overlap 

MeanCompTime = [mean(TimeCost20_025(:,3)) mean(TimeCost20_050(:,3)) mean(TimeCost20_075(:,3)) mean(TimeCost40_025(:,3)) mean(TimeCost40_050(:,3)) mean(TimeCost40_075(:,3)) mean(TimeCost60_025(:,3)) mean(TimeCost60_050(:,3)) mean(TimeCost60_075(:,3)) mean(TimeCost80_025(:,3)) mean(TimeCost80_050(:,3)) mean(TimeCost80_075(:,3)) mean(TimeCost100_025(:,3)) mean(TimeCost100_050(:,3)) mean(TimeCost100_075(:,3))];
TotalCompTime = [sum(TimeCost20_025(:,3)) sum(TimeCost20_050(:,3)) sum(TimeCost20_075(:,3)) sum(TimeCost40_025(:,3)) sum(TimeCost40_050(:,3)) sum(TimeCost40_075(:,3)) sum(TimeCost60_025(:,3)) sum(TimeCost60_050(:,3)) sum(TimeCost60_075(:,3)) sum(TimeCost80_025(:,3)) sum(TimeCost80_050(:,3)) sum(TimeCost80_075(:,3)) sum(TimeCost100_025(:,3)) sum(TimeCost100_050(:,3)) sum(TimeCost100_075(:,3))];
ProportionalCompTime = (TotalCompTime./MeanCompTime);
TestClassAccAgent = [88.7 83.0 79.7 84.4 85.9 80.0 87.2 83.8 83.1 86.7 86.5 79.5 86.0 86.9 80.2];

% visualising different calculations (EDA) 
MeanCompTime./TestClassAccAgent
scatter((MeanCompTime./TotalCompTime),TestClassAccAgent)
plot(TotalCompTime./TestClassAccAgent)
scatter(1./ProportionalCompTime,TestClassAccAgent)
ProportionalCompTime2 = (MeanCompTime./TotalCompTime);
scatter(TestClassAccAgent,TotalCompTime)

ProportionalCompTime = (TotalCompTime./MeanCompTime);

% Figure for paper 
figure(1)
scatter(ProportionalCompTime,TestClassAccAgent, 75, 'MarkerFaceColor',[0.19 0.55 0.91])
hold on 
scatter(ProportionalCompTime(14),TestClassAccAgent(14), 75, 'MarkerFaceColor',[245/255 102/255 0/255])
hold off
title('Observation period and window overlap sensitivity for $M_{1\dots 42}$','interpreter','latex','FontSize',16)
xlabel('Proportional computation time ($T/\mu_t $)','interpreter','latex','FontSize', 16) 
ylabel('Classification Accuracy (Percent)','interpreter','latex','FontSize', 16) 

%% M3 - SWARM STATIONARY 
% Objective: discover the swarm profile (swarm type)  
% Evaluation: (1) class accuracy (during training), (2) compare to a
% 'classic' method such as training a classifier on information only and
% (3) Value of Information to identify the optimal [window] + [overlap] to increase classification accuracy

%% Build data 
ClassicData = false; 

% initialise data
if ClassicData 
    myDir = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/dataClassic'; 
else 
    myDir = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE'; 
end
myFiles = dir(fullfile(myDir, '*.mat')); 

FlatMarkerSwarm = [];
ClassYswarm = [];
L2norm = []; 
MasterKeySwarm = []; 
TimeCostSwarm = []; 

% generate summary statistics of the swarm at each step
for simRun = 1:length(myFiles)
    % import 
    baseFileName = myFiles(simRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    dat = importdata(fullFileName);

    % summarise each time step
    fnWindow = fieldnames(dat.MarkerSet);  
    for WindowIter = 1:numel(fnWindow)
        
        tmp = dat.MarkerSet.(fnWindow{WindowIter}).MarkerState'; 
        tt = []; 
        % mean 
        tt(1,:) = mean(tmp); 
        % median
        tt(2,:) = median(tmp); 
        % mode
        tt(3,:) = mode(tmp);
        % var
        tt(4,:) = var(tmp);
        % skewness
        tt(5,:) = skewness(tmp); 
        % kurtosis
        tt(6,:) = kurtosis(tmp); 
        % iqr
        tt(7,:) = iqr(tmp); 
        % range 
        tt(8,:) = range(tmp); 
        % min
        tt(9,:) = min(tmp); 
        % max 
        tt(10,:) = max(tmp); 
        % std
        tt(11,:) = std(tmp);

        % L2 norm of each marker 
        L2norm = sqrt(sum(abs(tt),'omitnan'));
        
        % consolidate data 
        FlatMarkerSwarm = [FlatMarkerSwarm; L2norm];
        % data.parameters.ScenarioIndex is type character - convert to a
        % string prior to 
        ClassYswarm = [ClassYswarm; convertCharsToStrings(dat.parameters.ScenarioIndex)];
        clear L2norm tmp
        MasterKeySwarm = [MasterKeySwarm; [dat.parameters.WindowSize, dat.parameters.Overlap]];
        TimeCostSwarm = [TimeCostSwarm; [dat.parameters.WindowSize dat.parameters.Overlap mean(dat.MarkerEvalVOI.Cost(:,2)) dat.MarkerEvalVOI.Cost(end,3)]];
    end
end

% randomly shuffle marker state to break data dependencies 
NewOrder = size(FlatMarkerSwarm,1);
for i = 1:10 
    NewRowOrder = randperm(NewOrder);
end

FlatMarkerSwarm = FlatMarkerSwarm(NewRowOrder,:);
ClassYswarm = ClassYswarm(NewRowOrder,:);
MasterKeySwarm = MasterKeySwarm(NewRowOrder,:);
TimeCostSwarm = TimeCostSwarm(NewRowOrder,:);

for i = 1:length(ClassYswarm)
    if ClassYswarm(i) == "S1" 
        Class2Y(i) = "Heterogeneous";
    elseif ClassYswarm(i) == "S2" 
        Class2Y(i) = "Heterogeneous";
    elseif ClassYswarm(i) == "S3"
        Class2Y(i) = "Heterogeneous";
    elseif ClassYswarm(i) == "S4"
        Class2Y(i) = "Heterogeneous";
    else
        Class2Y(i) = "Homogeneous";
    end
end
Class2Y = Class2Y'; 

% subset by [window] and [overlap] 
%window = 20; % [20 40 60 80 100]
%overlap = 0.25; % [0.25 0.50 0.75]

%idx = find(MasterKeySwarm(:,1)==window & MasterKeySwarm(:,2)==overlap); 

%idx = find(MasterKeySwarm(:,1)==window & MasterKeySwarm(:,2)==overlap); 
idx20_025 = find(MasterKeySwarm(:,1)==20 & MasterKeySwarm(:,2)==0.25); 
idx20_050 = find(MasterKeySwarm(:,1)==20 & MasterKeySwarm(:,2)==0.50); 
idx20_075 = find(MasterKeySwarm(:,1)==20 & MasterKeySwarm(:,2)==0.75); 
idx40_025 = find(MasterKeySwarm(:,1)==40 & MasterKeySwarm(:,2)==0.25); 
idx40_050 = find(MasterKeySwarm(:,1)==40 & MasterKeySwarm(:,2)==0.50); 
idx40_075 = find(MasterKeySwarm(:,1)==40 & MasterKeySwarm(:,2)==0.75); 
idx60_025 = find(MasterKeySwarm(:,1)==60 & MasterKeySwarm(:,2)==0.25); 
idx60_050 = find(MasterKeySwarm(:,1)==60 & MasterKeySwarm(:,2)==0.50); 
idx60_075 = find(MasterKeySwarm(:,1)==60 & MasterKeySwarm(:,2)==0.75); 
idx80_025 = find(MasterKeySwarm(:,1)==80 & MasterKeySwarm(:,2)==0.25); 
idx80_050 = find(MasterKeySwarm(:,1)==80 & MasterKeySwarm(:,2)==0.50); 
idx80_075 = find(MasterKeySwarm(:,1)==80 & MasterKeySwarm(:,2)==0.75); 
idx100_025 = find(MasterKeySwarm(:,1)==100 & MasterKeySwarm(:,2)==0.25); 
idx100_050 = find(MasterKeySwarm(:,1)==100 & MasterKeySwarm(:,2)==0.50); 
idx100_075 = find(MasterKeySwarm(:,1)==100 & MasterKeySwarm(:,2)==0.75); 

FLATidx20_025 = FlatMarkerSwarm(idx20_025,:);
CLASSidx20_025 = Class2Y(idx20_025,:);

FLATidx20_050 = FlatMarkerSwarm(idx20_050,:); 
CLASSidx20_050 = Class2Y(idx20_050,:);

FLATidx20_075 = FlatMarkerSwarm(idx20_075,:); 
CLASSidx20_075 = Class2Y(idx20_075,:);

FLATidx40_025 = FlatMarkerSwarm(idx40_025,:);
CLASSidx40_025 = Class2Y(idx40_025,:);

FLATidx40_050 = FlatMarkerSwarm(idx40_050,:);
CLASSidx40_050 = Class2Y(idx40_050,:);

FLATidx40_075 = FlatMarkerSwarm(idx40_075,:);
CLASSidx40_075 = Class2Y(idx40_075,:);

FLATidx60_025 = FlatMarkerSwarm(idx60_025,:);
CLASSidx60_025 = Class2Y(idx60_025,:);
CLASSidx60_025 = ClassYswarm(idx60_025,:);

FLATidx60_050 = FlatMarkerSwarm(idx60_050,:);
CLASSidx60_050 = Class2Y(idx60_050,:);

FLATidx60_075 = FlatMarkerSwarm(idx60_075,:);
CLASSidx60_075 = Class2Y(idx60_075,:);

FLATidx80_025 = FlatMarkerSwarm(idx80_025,:);
CLASSidx80_025 = Class2Y(idx80_025,:);

FLATidx80_050 = FlatMarkerSwarm(idx80_050,:);
CLASSidx80_050 = Class2Y(idx80_050,:);

FLATidx80_075 = FlatMarkerSwarm(idx80_075,:);
CLASSidx80_075 = Class2Y(idx80_075,:);

FLATidx100_025 = FlatMarkerSwarm(idx100_025,:);
CLASSidx100_025 = Class2Y(idx100_025,:);

FLATidx100_050 = FlatMarkerSwarm(idx100_050,:);
CLASSidx100_050 = Class2Y(idx100_050,:);

FLATidx100_075 = FlatMarkerSwarm(idx100_075,:);
CLASSidx100_075 = Class2Y(idx100_075,:);

idx60_025Heterogeneous = find(MasterKeySwarm(:,1)==20 & MasterKeySwarm(:,2)==0.25);

idxHe = find(CLASSidx60_025 == "S1" | CLASSidx60_025 == "S2" | CLASSidx60_025 == "S3" | CLASSidx60_025 == "S4");
idxHo = find(CLASSidx60_025 == "S5" | CLASSidx60_025 == "S6" | CLASSidx60_025 == "S7" | CLASSidx60_025 == "S8" |  CLASSidx60_025 == "S9" | CLASSidx60_025 == "S10" | CLASSidx60_025 == "S11");



ClassYHe = CLASSidx60_025(idxHe,:);
ClassYHo = CLASSidx60_025(idxHo,:);

ClassXHe = FLATidx60_025(idxHe,:);
ClassXHo = FLATidx60_025(idxHo,:);

FLATidxHe = SwarmX(idxHe,:);
FLATidxHo = SwarmX(idxHo,:);
YclassHe = ClassYswarm(idxHe);
YclassHo = ClassYswarm(idxHo);

% convert to table 
clear AgentX AgentY
AgentX = array2table(FLATidx100_075); 
AgentY = CLASSidx100_075; 
clear AgentX AgentY

% convert to table 
SwarmX = array2table(FlatMarkerSwarm); 
SwarmY = array2table(Class2Y); 

% save classification-ready data
if ClassicData 
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/dataClassic/SwarmX.mat',"SwarmX")
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/dataClassic/SwarmY.mat',"SwarmY")
else 
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE/SwarmX.mat',"SwarmX")
    save('/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE/SwarmY.mat',"SwarmY")
end

%% Agent Classification - Eval VOI Cost 
TimeCostSwarm20_025 = TimeCostSwarm(find(TimeCostSwarm(:,1)==20 & TimeCostSwarm(:,2)==0.25),:); 
TimeCostSwarm20_050 = TimeCostSwarm(find(TimeCostSwarm(:,1)==20 & TimeCostSwarm(:,2)==0.50),:); 
TimeCostSwarm20_075 = TimeCostSwarm(find(TimeCostSwarm(:,1)==20 & TimeCostSwarm(:,2)==0.75),:); 
TimeCostSwarm40_025 = TimeCostSwarm(find(TimeCostSwarm(:,1)==40 & TimeCostSwarm(:,2)==0.25),:); 
TimeCostSwarm40_050 = TimeCostSwarm(find(TimeCostSwarm(:,1)==40 & TimeCostSwarm(:,2)==0.50),:); 
TimeCostSwarm40_075 = TimeCostSwarm(find(TimeCostSwarm(:,1)==40 & TimeCostSwarm(:,2)==0.75),:); 
TimeCostSwarm60_025 = TimeCostSwarm(find(TimeCostSwarm(:,1)==60 & TimeCostSwarm(:,2)==0.25),:); 
TimeCostSwarm60_050 = TimeCostSwarm(find(TimeCostSwarm(:,1)==60 & TimeCostSwarm(:,2)==0.50),:); 
TimeCostSwarm60_075 = TimeCostSwarm(find(TimeCostSwarm(:,1)==60 & TimeCostSwarm(:,2)==0.75),:); 
TimeCostSwarm80_025 = TimeCostSwarm(find(TimeCostSwarm(:,1)==80 & TimeCostSwarm(:,2)==0.25),:); 
TimeCostSwarm80_050 = TimeCostSwarm(find(TimeCostSwarm(:,1)==80 & TimeCostSwarm(:,2)==0.50),:); 
TimeCostSwarm80_075 = TimeCostSwarm(find(TimeCostSwarm(:,1)==80 & TimeCostSwarm(:,2)==0.75),:); 
TimeCostSwarm100_025 = TimeCostSwarm(find(TimeCostSwarm(:,1)==100 & TimeCostSwarm(:,2)==0.25),:); 
TimeCostSwarm100_050 = TimeCostSwarm(find(TimeCostSwarm(:,1)==100 & TimeCostSwarm(:,2)==0.50),:); 
TimeCostSwarm100_075 = TimeCostSwarm(find(TimeCostSwarm(:,1)==100 & TimeCostSwarm(:,2)==0.75),:); 

mean(TimeCostSwarm20_025(:,3))
sum(TimeCostSwarm20_025(:,3))/11

mean(TimeCostSwarm20_050(:,3))
sum(TimeCostSwarm20_050(:,3))/11

mean(TimeCostSwarm20_075(:,3))
sum(TimeCostSwarm20_075(:,3))/11

mean(TimeCostSwarm40_025(:,3))
sum(TimeCostSwarm40_025(:,3))/11

mean(TimeCostSwarm40_050(:,3))
sum(TimeCostSwarm40_050(:,3))/11

mean(TimeCostSwarm40_075(:,3))
sum(TimeCostSwarm40_075(:,3))/11

mean(TimeCostSwarm60_025(:,3))
sum(TimeCostSwarm60_025(:,3))/11

mean(TimeCostSwarm60_050(:,3))
sum(TimeCostSwarm60_050(:,3))/11

mean(TimeCostSwarm60_075(:,3))
sum(TimeCostSwarm60_075(:,3))/11

mean(TimeCostSwarm80_025(:,3))
sum(TimeCostSwarm80_025(:,3))/11

mean(TimeCostSwarm80_050(:,3))
sum(TimeCostSwarm80_050(:,3))/11

mean(TimeCostSwarm80_075(:,3))
sum(TimeCostSwarm80_075(:,3))/11

mean(TimeCostSwarm100_025(:,3))
sum(TimeCostSwarm100_025(:,3))/11

mean(TimeCostSwarm100_050(:,3))
sum(TimeCostSwarm100_050(:,3))/11

mean(TimeCostSwarm100_075(:,3))
sum(TimeCostSwarm100_075(:,3))/11

MeanCompTime = [mean(TimeCostSwarm20_025(:,3)) mean(TimeCostSwarm20_050(:,3)) mean(TimeCostSwarm20_075(:,3)) mean(TimeCostSwarm40_025(:,3)) mean(TimeCostSwarm40_050(:,3)) mean(TimeCostSwarm40_075(:,3)) mean(TimeCostSwarm60_025(:,3)) mean(TimeCostSwarm60_050(:,3)) mean(TimeCostSwarm60_075(:,3)) mean(TimeCostSwarm80_025(:,3)) mean(TimeCostSwarm80_050(:,3)) mean(TimeCostSwarm80_075(:,3)) mean(TimeCostSwarm100_025(:,3)) mean(TimeCostSwarm100_050(:,3)) mean(TimeCostSwarm100_075(:,3))];
TotalCompTime = [sum(TimeCostSwarm20_025(:,3)) sum(TimeCostSwarm20_050(:,3)) sum(TimeCostSwarm20_075(:,3)) sum(TimeCostSwarm40_025(:,3)) sum(TimeCostSwarm40_050(:,3)) sum(TimeCostSwarm40_075(:,3)) sum(TimeCostSwarm60_025(:,3)) sum(TimeCostSwarm60_050(:,3)) sum(TimeCostSwarm60_075(:,3)) sum(TimeCostSwarm80_025(:,3)) sum(TimeCostSwarm80_050(:,3)) sum(TimeCostSwarm80_075(:,3)) sum(TimeCostSwarm100_025(:,3)) sum(TimeCostSwarm100_050(:,3)) sum(TimeCostSwarm100_075(:,3))];
ProportionalCompTime = (TotalCompTime./MeanCompTime);

% Figure for paper 
TestClassAccAgent = [88.7 83.0 79.7 84.4 85.9 80.0 87.2 83.8 83.1 86.7 86.5 79.5 86.0 86.9 80.2];
figure(1)
scatter(ProportionalCompTime,TestClassAccAgent, 75, 'MarkerFaceColor',[0.19 0.55 0.91])
hold on 
scatter(ProportionalCompTime(14),TestClassAccAgent(14), 75, 'MarkerFaceColor',[245/255 102/255 0/255])
hold off
title('Observation period and window overlap sensitivity for $M_{1\dots 42}$','interpreter','latex','FontSize',16)
xlabel('Proportional computation time ($T/\mu_t $)','interpreter','latex','FontSize', 16) 
ylabel('Classification Accuracy (Percent)','interpreter','latex','FontSize', 16) 

% Figure for paper 
TestClassAcc11class = [83.3 77.7 57.3 66.8 69.1 55.8 65.3 50.0 58.3 67.4 47.5 34.6 56.3 65.4 33.3];
figure(2)
scatter(ProportionalCompTime,TestClassAcc11class, 75, 'MarkerFaceColor',[0.19 0.55 0.91])
hold on 
scatter(ProportionalCompTime(2),TestClassAcc11class(2), 75, 'MarkerFaceColor',[245/255 102/255 0/255])
hold off
title('Observation period and window overlap sensitivity for $M_{1\dots 42}$','interpreter','latex','FontSize',16)
xlabel('Proportional computation time ($T/\mu_t $)','interpreter','latex','FontSize', 16) 
ylabel('Classification Accuracy (Percent)','interpreter','latex','FontSize', 16) 

ProportionalCompTime = (TotalCompTime./MeanCompTime);

% Figure for paper 
TestClassAcc2class = [87.6 82.0 78.0 81.4 81.2 80.0 84.9 79.7 85.7 82.4 80.8 61.5 84.1 80.2 64.4]; 
figure(3)
scatter(ProportionalCompTime,TestClassAcc2class, 75, 'MarkerFaceColor',[0.19 0.55 0.91])
hold on 
scatter(ProportionalCompTime(9),TestClassAcc2class(9), 75, 'MarkerFaceColor',[245/255 102/255 0/255])
hold off
title('Observation period and window overlap sensitivity for $M_{1\dots 42}$','interpreter','latex','FontSize',16)
xlabel('Proportional computation time ($T/\mu_t $)','interpreter','latex','FontSize', 16) 
ylabel('Classification Accuracy (Percent)','interpreter','latex','FontSize', 16) 

% Combined Figure Agent vs Swarm 11-class
figure(4)
scatter(ProportionalCompTime([3,5:end])./TestClassAccAgent([3,5:end]),ProportionalCompTime([3,5:end])./TestClassAcc11class([3,5:end]), 75, 'MarkerFaceColor',[0.19 0.55 0.91])
hold on
scatter(ProportionalCompTime(4)/(TestClassAccAgent(4)),(ProportionalCompTime(4)/TestClassAcc11class(4)), 90, 'filled', 'd',  'MarkerFaceColor',[245/255 102/255 0/255])
hold on
scatter(ProportionalCompTime(2)/(TestClassAccAgent(2)),(ProportionalCompTime(2)/TestClassAcc11class(2)), 90, 'filled', 's',  'MarkerFaceColor',[245/255 102/255 0/255])
hold on 
scatter(ProportionalCompTime(1)/(TestClassAccAgent(1)),(ProportionalCompTime(1)/TestClassAcc11class(1)), 150, 'filled', 'p',  'MarkerFaceColor',[245/255 102/255 0/255])
hold off
title('Agent vs Swarm (11-class) Classification Trade-Off','interpreter','latex','FontSize',16)
xlabel('Agent-Normalised Proportional Time ($\frac{T/\mu_t}{\pi}$)','interpreter','latex','FontSize', 16) 
ylabel('Swarm-Normalised Proportional Time ($\frac{T/\mu_t}{\Pi}$)','interpreter','latex','FontSize', 16) 
legend({'window/overlap pairs','window=40, overlap=0.75','window=20, overlap=0.50','window=20, overlap=0.75'},'Location','northwest')

% Combined Figure Agent vs Swarm 2-class
figure(5)
scatter(ProportionalCompTime([3,5:end])./TestClassAccAgent([3,5:end]),ProportionalCompTime([3,5:end])./TestClassAcc2class([3,5:end]), 75, 'MarkerFaceColor',[0.19 0.55 0.91])
hold on
scatter(ProportionalCompTime(4)/(TestClassAccAgent(4)),(ProportionalCompTime(4)/TestClassAcc2class(4)), 90, 'filled', 'd',  'MarkerFaceColor',[245/255 102/255 0/255])
hold on
scatter(ProportionalCompTime(2)/(TestClassAccAgent(2)),(ProportionalCompTime(2)/TestClassAcc2class(2)), 90, 'filled', 's',  'MarkerFaceColor',[245/255 102/255 0/255])
hold on 
scatter(ProportionalCompTime(1)/(TestClassAccAgent(1)),(ProportionalCompTime(1)/TestClassAcc2class(1)), 150, 'filled', 'p', 'MarkerFaceColor',[245/255 102/255 0/255])
hold off
title('Agent vs Swarm (2-class) Classification Trade-Off','interpreter','latex','FontSize',16)
xlabel('Agent-Normalised Proportional Time ($\frac{T/\mu_t}{\pi}$)','interpreter','latex','FontSize', 16) 
ylabel('Swarm-Normalised Proportional Time ($\frac{T/\mu_t}{\Pi}$)','interpreter','latex','FontSize', 16) 
legend({'window/overlap pairs','window=40, overlap=0.75','window=20, overlap=0.50','window=20, overlap=0.75'},'Location','northwest')

%% M2 - AGENT NON-STATIONARY
% Objective: identify agent network characteristics
% Evaluation: cluster agents to identify themes (i.e. can we assess a
% change in agent roles over time) 

myDir = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE'; 

myFiles = dir(fullfile(myDir, '*.mat')); 

M2 = []; 
M4 = [];
MasterKey = []; 

% generate flat file 
for simRun = 1:length(myFiles)
    % import 
    baseFileName = myFiles(simRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    dat = importdata(fullFileName);

    % consolidate data 
    fnWindow = fieldnames(dat.MarkerSet); 
    for WindowIter = 1:numel(fnWindow)
        M2 = [M2; dat.MarkerSet.(fnWindow{WindowIter}).M2.InteractionFraction];
        MasterKey = [MasterKey; [convertCharsToStrings(dat.parameters.ScenarioIndex) dat.parameters.WindowSize dat.parameters.Overlap]];
    end 
end

idxS1 = find(MasterKey(:,1)=="S1");
idxS2 = find(MasterKey(:,1)=="S2");
idxS3 = find(MasterKey(:,1)=="S3");
idxS4 = find(MasterKey(:,1)=="S4");
idxS5 = find(MasterKey(:,1)=="S5");
idxS6 = find(MasterKey(:,1)=="S6");
idxS7 = find(MasterKey(:,1)=="S7");
idxS8 = find(MasterKey(:,1)=="S8");
idxS9 = find(MasterKey(:,1)=="S9");
idxS10 = find(MasterKey(:,1)=="S10");
idxS11 = find(MasterKey(:,1)=="S11");

M2S1 = M2(idxS1,:);
M2S2 = M2(idxS2,:);
M2S3 = M2(idxS3,:);
M2S4 = M2(idxS4,:);
M2S5 = M2(idxS5,:);
M2S6 = M2(idxS6,:);
M2S7 = M2(idxS7,:);
M2S8 = M2(idxS8,:);
M2S9 = M2(idxS9,:);
M2S10 = M2(idxS10,:);
M2S11 = M2(idxS11,:);

% summary plots 
c = jet(11); % colour set 

stdshade(M2S1,0.1,[c(1,:)]);
hold on 
stdshade(M2S2,0.1,[c(2,:)]);
hold on 
stdshade(M2S3,0.1,[c(3,:)]);
hold on 
stdshade(M2S4,0.1,[c(4,:)]);
hold on 
stdshade(M2S5,0.1,[c(5,:)]);
hold on 
stdshade(M2S6,0.1,[c(6,:)]);
hold on 
stdshade(M2S7,0.1,[c(7,:)]);
hold on 
stdshade(M2S8,0.1,[c(8,:)]);
hold on 
stdshade(M2S9,0.1,[c(9,:)]);
hold on 
stdshade(M2S10,0.1,[c(10,:)]);
hold on 
stdshade(M2S11,0.1,[c(11,:)]);
hold off

title('Agent interaction distribution for $S_{1,\dots 11}$','interpreter','latex','FontSize',16)
xlabel('Agent ($\pi_{1,\dots 20} $)','interpreter','latex','FontSize', 16) 
ylabel('Proportion of $\Pi$ interactions','interpreter','latex','FontSize', 16) 
legend({'', 'S1', '', 'S2', '', 'S3', '', 'S4', '', 'S5', '', 'S6', '', 'S7', '', 'S8', '', 'S9', '', 'S10', '', 'S11'})

% summarise the assignment of each agent to determine how much variance there is in the assignment of the agent profile 
% clustering profile associations (how many times each agent is in the same cluster)

% assumes we know k for each scenario, which could be estimated etc. 

ScenarioAgentImportance = []; 
%%% only execute once or the data is gone! 



k = 1; %[2 4 2 3 1 1 1 1 1 1 1]; % for kmeans 
var = M2S5; % data set 
ClustSet = []; 

for observation = 1:size(var,1)
    ClustSet(:,observation) = kmeans(var(observation,:)',k); 
end
ClustSet = ClustSet';

AssocMat = zeros(size(ClustSet,2), size(ClustSet,2));

for OBSERVATION = 1:size(ClustSet,1)
    for SOURCE = 1:size(ClustSet,2)
        for TARGET = 1:size(ClustSet,2)
            if SOURCE ~= TARGET 
                if ClustSet(OBSERVATION, SOURCE) == ClustSet(OBSERVATION, TARGET)
                    AssocMat(SOURCE, TARGET) = AssocMat(SOURCE, TARGET) + 1; 
                end
            end
        end
    end
end

G = graph(AssocMat,'upper');

% importance based on cluster assoication 
imp = centrality(G, 'degree', 'Importance', G.Edges.Weight);
SumImp = sum(imp); 
for agent = 1:length(imp)
    importance(agent) = imp(agent)/SumImp; 
end

ScenarioAgentImportance = [ScenarioAgentImportance; importance];
ScenarioAgentImportance

clear G SumImp imp importance 

plot(100*(ScenarioAgentImportance'), 'LineWidth', 2)
title('Swarm Heterogeneous Agent Association Profile','interpreter','latex','FontSize',16)
ylabel('Agent Asociation (\%)','interpreter','latex','FontSize', 16) 
xlabel('Agent $\pi_{1,\dots 20}$','interpreter','latex','FontSize', 16) 
legend({'$S_1$', '$S_2$', '$S_3$', '$S_4$'}, 'Interpreter','latex','FontSize',12, 'Location', 'northwest')

%%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% 
%%% SEE DataGenANALYSISplot.M for further analysis %%%
%%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% %%% 

% repeat for every scenario group 


%% M4 - SWARM NON-STATIONARY
% Objective: identify swarm attention points 
% Evaluation: identify distinct agents that require focus --> does this
% correlate to agent types (i.e. compare to classification) 

myDir = '/Users/ajh/GitHub/IntelligentControlAgent/SimData/DOE'; 

myFiles = dir(fullfile(myDir, '*.mat')); 

M2 = []; 
M4 = [];
MasterKey = []; 

% generate flat file 
for simRun = 1:length(myFiles)
    % import 
    baseFileName = myFiles(simRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    dat = importdata(fullFileName);

    % consolidate data 
    fnWindow = fieldnames(dat.MarkerSet); 
    for WindowIter = 1:numel(fnWindow)
        M4 = [M4; dat.MarkerSet.(fnWindow{WindowIter}).M4.AttentionPoints];
        MasterKey = [MasterKey; [convertCharsToStrings(dat.parameters.ScenarioIndex) dat.parameters.WindowSize dat.parameters.Overlap]];
    end 
end

idxS1 = find(MasterKey(:,1)=="S1");
idxS2 = find(MasterKey(:,1)=="S2");
idxS3 = find(MasterKey(:,1)=="S3");
idxS4 = find(MasterKey(:,1)=="S4");
idxS5 = find(MasterKey(:,1)=="S5");
idxS6 = find(MasterKey(:,1)=="S6");
idxS7 = find(MasterKey(:,1)=="S7");
idxS8 = find(MasterKey(:,1)=="S8");
idxS9 = find(MasterKey(:,1)=="S9");
idxS10 = find(MasterKey(:,1)=="S10");
idxS11 = find(MasterKey(:,1)=="S11");

M4S1 = M4(idxS1,:);
M4S2 = M4(idxS2,:);
M4S3 = M4(idxS3,:);
M4S4 = M4(idxS4,:);
M4S5 = M4(idxS5,:);
M4S6 = M4(idxS6,:);
M4S7 = M4(idxS7,:);
M4S8 = M4(idxS8,:);
M4S9 = M4(idxS9,:);
M4S10 = M4(idxS10,:);
M4S11 = M4(idxS11,:);



