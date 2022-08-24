% Author: Adam J Hepworth
% LastModified: 2022-06-20
% Explanaton: Experimentation and analysis script for SSCI22 conference
% paper submission, recognition and 

%% Experimentation: Training Data Generation
% State Data

clear
clc

IsTest = false; % test scenarios are presently commented out - do not use

if IsTest
    ScenarioIterator = ["T1"];%,"T2","T3"]; % Test data
else
    ScenarioIterator = ["S1","S2","S3","S4","S5","S6","S7","S8","S9","S10","S11"]; % Training data
end

%seedGen = randperm(300,30); % seed already generated here and saved as 'seed.mat' for 
%seed = seedGen;

load('/Users/ajh/GitHub/RecognitionController/seed.mat') % load seed setting

for p = 1:size(ScenarioIterator,2) % scenario iterate 
    parameters.ScenarioIndex = char(ScenarioIterator(p));
    for q = 1:10 % replicates of each scenario
        parameters.Replicate = q;
        rng(seed(q))
        RecognitionController;
        varName = ['s',num2str(p),'_rep',num2str(q),'_seed',num2str(seed(q))];       
        if IsTest
            save(sprintf('/Users/ajh/GitHub/swarmRecognition/SSCI22/Test/%s.mat',varName),'output') % for Test data
        else
            save(sprintf('/Users/ajh/GitHub/swarmRecognition/SSCI22/SimData/%s.mat',varName),'output') % macOS-mini
        end
        %save(sprintf('/Users/fadamos/GitHub/swarmRecognition/SSCI22/%s.mat',varName),'output') % macOS-mbp
    end
end

% Raw data pre-processing

clear
clc

IsTest = false; 

Verbose = false; % Adam: I really need to stop using verbose as my flag haha (at least we all know what it means ...)  

% setup files for import 
if IsTest 
    myDir = '/Users/ajh/GitHub/swarmRecognition/SSCI22/Test'; % gets directory for test data
else 
   myDir = '/Users/ajh/GitHub/swarmRecognition/SSCI22/SimData'; % gets directory for training data 
end
myFiles = dir(fullfile(myDir, '*.mat')); % gets all mat files in struct 
for SimRun = 3%1:length(myFiles)
    % import files 
    baseFileName = myFiles(SimRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    dat = importdata(fullFileName);
    
    df.SimParameters = dat.parameters;
    SwarmAgentTypeDistribution = dat.parameters.SwarmAgentTypeDistribution; 
    Scenario = dat.parameters.ScenarioIndex;
    
    % create matlab table 
    DataTable = table(dat.SensedData.t', dat.SensedData.GoalX', dat.SensedData.GoalY', dat.SensedData.NumberOfSheep', [dat.SensedData.SheepDogX', dat.SensedData.SheepDogY'], dat.SensedData.SheepX, dat.SensedData.SheepY);
    DataTable = renamevars(DataTable, ["Var1","Var2","Var3","Var4","Var5","Var6","Var7"],["t","GoalX","GoalY","NumSheep","SheepDogXY","SheepX","SheepY"]);
    
    fprintf('Table size = [%i, %i]\n', size(DataTable,1), size(DataTable,2))

    % segment into 10-step elements
    windows = WindowSegments(DataTable);
    
    % save pre-processed files
    df.DataTable = DataTable; 
    df.windows = windows;
        % Window length = 20 
        % Window overlap = 50% 
        % Agent Type classification every 10 seconds 
        
    df.InputData = dat; % save all input data
    
    df.parameters.MaxNumAgents = max(df.DataTable.NumSheep);
    df.parameters.MaxTimeSteps = max(windows(:,2)-windows(:,1));
    df.parameters.NumMarkers = 23; % from CalculateMarkers
    df.parameters.NumScenarioWindows = size(windows,1);
    df.parameters.Scenario = Scenario;
    df.parameters.SwarmAgentTypeDistribution = SwarmAgentTypeDistribution;
    
    % Generate Marker State Data 
    MarkerState = nan(df.parameters.NumMarkers,df.parameters.MaxNumAgents,df.parameters.NumScenarioWindows); % pre-allocate memory to handle final window size (boundary case) 
    
    if Verbose 
        figure(1); clf; 
        title('MarkerState')
        contourf(squeeze(MarkerState(:,:,1)))
        ylabel('Markers')
        xlabel('Swarm Agents') 
        set(gca,'FontSize',14);
        hold on; 
    end
    
    %% Marker State Calculations
    fprintf('MarkerState = [%i, %i, %i]\n', size(MarkerState,1), size(MarkerState,2), size(MarkerState,3));    
    fprintf('- * - * - * - * - * - * - * - * - * - *\n')
    for DecisionWindow = 1:size(windows,1)
        fprintf('Commencing Window = %i. Observation Range = [%i, %i]\n', DecisionWindow, windows(DecisionWindow,1),windows(DecisionWindow,2)) 
        s = tic;
        MarkerState(:,:,DecisionWindow) = CalculateMarkers(df.DataTable(windows(DecisionWindow,1):windows(DecisionWindow,2),:));
        t = toc(s);
        if Verbose 
            LoopPlot = normalize(MarkerState(:,:,DecisionWindow),2,'range');
            contourf(LoopPlot) % normalise all values in 0,1 for the plot
            pause(0.01)
        end
        fprintf('Compute time = %f seconds\n', t)
        fprintf('%f%% complete.\n', DecisionWindow/size(windows,1)*100)
        dat.ComputeTime(DecisionWindow) = t; 
        fprintf('- * - * - * - * - * - * - * - * - * - *\n')
    end
    
    df.MarkerState = MarkerState;
       
    %% Generate flat data file (df.FlatMarker) - Predictor Matrix [X]
    % 1- Add agent and scenario state columns 

    df.parameters.Scenario = convertCharsToStrings(df.SimParameters.ScenarioIndex);
    df.parameters.Scenario = repelem(df.parameters.Scenario, df.parameters.MaxNumAgents); 
    df.parameters.Scenario = df.parameters.Scenario(1,1:20);

    df.ResponseY1 = repelem(df.parameters.SwarmAgentTypeDistribution, size(df.MarkerState,3));
    df.ResponseY2 = repelem(df.parameters.Scenario, size(df.MarkerState,3)); 
    fprintf('Are Y1 and Y2 the same size? %i\n', size(df.ResponseY1,2) == size(df.ResponseY2,2)) 

    % 2- flatten marker state 
    df.FlatMarker = [];
    for DecisionWindow = 1:size(df.MarkerState,3)
        tmp = df.MarkerState(:,:,DecisionWindow);
        if Verbose
            fprintf('Another %i markers (window = %i)\n', size(tmp,1), DecisionWindow)
        end
        df.FlatMarker = [df.FlatMarker, tmp]; 
        clear tmp 
    end
    fprintf('Is FlatMarker and Responses the same size? %i\n', size(df.ResponseY1,2) == size(df.FlatMarker,2)) 

    % 3- shuffle randomly the marker state 
    df.parameters.numberOfColumns = size(df.FlatMarker,2);
    for i = 1:10
        df.parameters.newColumnOrder = randperm(df.parameters.numberOfColumns);
    end

    df.FlatMarker = df.FlatMarker(:,df.parameters.newColumnOrder);
    df.ResponseY1 = df.ResponseY1(:,df.parameters.newColumnOrder);
    df.ResponseY2 = df.ResponseY2(:,df.parameters.newColumnOrder);

    df.X = df.FlatMarker';
    df.Y1 = df.ResponseY1';
    df.Y2 = df.ResponseY2';

    df.Tbl = array2table(df.X);
    df.TblY1 = array2table(df.Y1);
    df.TblY2 = array2table(df.Y2);
    
    if IsTest
        save(sprintf('/Users/ajh/GitHub/swarmRecognition/SSCI22/MarkerTestData/%s',baseFileName),'df')
    else
        save(sprintf('/Users/ajh/GitHub/swarmRecognition/SSCI22/MarkerData/%s',baseFileName),'df')
    end
    fprintf('Saving %s\n', baseFileName); 
    
    % change file name 
    dotLocations = find(baseFileName == '.'); 
    if isempty(dotLocations)
        % No dots at all found so just take entire name.
        nameBeforeFirstDot = baseFileName; 
    else
        % Take up to , but not including, the first dot.
        nameBeforeFirstDot = baseFileName(1:dotLocations(1)-1);
    end
    
    %% Combine all data to build a single master training dataset  
    X.(nameBeforeFirstDot) = df.Tbl; 
    Y1.(nameBeforeFirstDot) = df.TblY1; 
    Y2.(nameBeforeFirstDot) = df.TblY2; 
    
    assignin('base','X',X);
    assignin('base','Y1',Y1);
    assignin('base','Y2',Y2);
end 

%% save train data (if you overwrite later haha)
myDir = '/Users/ajh/GitHub/swarmRecognition/SSCI22/MarkerData'; % gets directory 
myFiles = dir(fullfile(myDir, '*.mat')); % gets all mat files in struct 
for SimRun = 1:length(myFiles)
    baseFileName = myFiles(SimRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    % change file name 
    dotLocations = find(baseFileName == '.'); 
    if isempty(dotLocations)
        % No dots at all found so just take entire name.
        nameBeforeFirstDot = baseFileName; 
    else
        % Take up to , but not including, the first dot.
        nameBeforeFirstDot = baseFileName(1:dotLocations(1)-1);
    end
    X.(nameBeforeFirstDot) = df.Tbl; 
    Y1.(nameBeforeFirstDot) = df.TblY1; 
    Y2.(nameBeforeFirstDot) = df.TblY2; 
end

%% Marker Performance: Model Development

clear 
clc

% load data 
load('/Users/ajh/GitHub/swarmRecognition/SSCI22/X.mat')
load('/Users/ajh/GitHub/swarmRecognition/SSCI22/Y1.mat')
load('/Users/ajh/GitHub/swarmRecognition/SSCI22/Y2.mat')

% generate flat file 

% Predictor 
x = []; 
Scenarios = fieldnames(X); 
for iterator = 1:numel(Scenarios)
    %tmp = table2array(X.(Scenarios{iterator})); 
    tmp = X.(Scenarios{iterator});
    x = [x; tmp]; 
    clear tmp
end

x = renamevars(x, ["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8","Var9","Var10","Var11","Var12","Var13","Var14","Var15","Var16","Var17","Var18","Var19","Var20","Var21","Var22","Var23"],["M1","M2","M3","M4","M5","M6","M7","M8","M9","M10","M11","M12","M13","M14","M15","M16","M17","M18","M19","M20","M21","M22","M23"]);

% Response (Agent)
y1 = []; 
Scenarios = fieldnames(Y1); 
for iterator = 1:numel(Scenarios)
    tmp = table2array(Y1.(Scenarios{iterator}));
    y1 = [y1; tmp]; 
    clear tmp
end

y1 = categorical(y1);

% Response (Swarm)
y2 = []; 
Scenarios = fieldnames(Y2); 
for iterator = 1:numel(Scenarios)
    tmp = table2array(Y2.(Scenarios{iterator}));
    y2 = [y2; tmp]; 
    clear tmp
end

y2 = categorical(y2);

clear X
clear Y1
clear Y2
clear Scenarios
clear iterator

classificationLearner

save('C1')

% randomly select indexes to split data into 80% training set, 0%
% validation set and 20% test set. <- Not required in R2022a
[train_idx, ~, test_idx] = dividerand(size(x,1), 0.9, 0, 0.1);

% slice training data with train indexes 
x_train = x(train_idx, :);
y1_train = y1(train_idx, :);
y2_train = y2(train_idx, :);

% select test data
x_test = x(test_idx, :);
y1_test = y1(test_idx, :);
y2_test = y2(test_idx, :);

%% Model Development

classificationLearner


%% Extract rules from the classifier

CP = trainedModel.ClassificationTree.CutPoint;
NC = trainedModel.ClassificationTree.NodeClass;
for i = 1:size(CP,1)
    if ~isnan(CP(i))
        fprintf('if x%d < %f then node %d elseif x%d >= %f then node %d else %d \n',str2num(NC{i}),CP(i),i+1,str2num(NC{i}),CP(i), i+2,i)  
    elseif isnan(CP(i))
        fprintf('Class = %d \n',str2num(NC{i}))   
    end
end

view(C1.ClassificationTree) % extract decision rules 

view(C1.ClassificationTree, 'Mode', 'graph')

CumSumImp = sum(imp); 
for pred = 1:length(imp)
    contribution(pred) = imp(pred)/CumSumImp;
end

%% Evauation: Model 
% Classification of Behaviours

% Value of Information 

% 1- Cost: Compute cost 
% 2- Information Gain: MoP (classification performance) 
% 3- Time: Decision Window 


yfit = C1.predictFcn(x_test);

confmat = confusionmat(y1_test,yfit);
cm = confusionchart(y1_test, yfit);
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

confusionchart(confmat)

%% Second-stage classifier: Proportion of agents in each scene as inputs to the scenario classifier 

% build training data set for Y2 
myDir = '/Users/ajh/GitHub/swarmRecognition/SSCI22/MarkerData'; % gets directory for test data
myFiles = dir(fullfile(myDir, '*.mat')); % gets all mat files in struct 
for SimRun = 1:length(myFiles)
    % import files 
    baseFileName = myFiles(SimRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    dat = importdata(fullFileName);

     % change file name 
    dotLocations = find(baseFileName == '.'); 
    if isempty(dotLocations)
        % No dots at all found so just take entire name.
        nameBeforeFirstDot = baseFileName; 
    else
        % Take up to , but not including, the first dot.
        nameBeforeFirstDot = baseFileName(1:dotLocations(1)-1);
    end

    agentDistribution = dat.SimParameters.Scenario;
    scenarioSetting = convertCharsToStrings(dat.SimParameters.ScenarioIndex);
    
    for repeats = 1:size(dat.MarkerState,3)
         fprintf('reps = %i\n', repeats)
         TrainingX(repeats,:) = agentDistribution;
         fprintf('X ok\n')
         TrainingY(repeats,:) = scenarioSetting;  
         fprintf('Y ok\n')
    end

    C2trgX.(nameBeforeFirstDot) = TrainingX; 
    C2trgY.(nameBeforeFirstDot) = TrainingY; 

    clear TrainingX
    clear TrainingY

end

save('C2trgX')
save('C2trgY')

X_C2 = []; 
Scenarios = fieldnames(C2trgX); 
for iterator = 1:numel(Scenarios)
    tmp = C2trgX.(Scenarios{iterator});
    X_C2 = [X_C2; tmp]; 
    clear tmp
end

Y_C2 = []; 
Scenarios = fieldnames(C2trgY); 
for iterator = 1:numel(Scenarios)
    tmp = C2trgY.(Scenarios{iterator});
    Y_C2 = [Y_C2; tmp]; 
    clear tmp
end

Y_C2 = categorical(Y_C2);

save('X_C2')
save('Y_C2')

classificationLearner

save('C2')

%% Create pipleine from C1 --> C2 


yfit = C1.predictFcn(x_test);

UniqueClasses = unique(yfit);

AgentTypeCounter = zeros(1,7); 

for i = 1:size(yfit,1)
    if yfit(i) == categorical("A1")
        AgentTypeCounter(1) = AgentTypeCounter(1) + 1; 
    elseif yfit(i) == categorical("A2")
        AgentTypeCounter(2) = AgentTypeCounter(2) + 1; 
    elseif yfit(i) == categorical("A3")
        AgentTypeCounter(3) = AgentTypeCounter(3) + 1; 
    elseif yfit(i) == categorical("A4")
        AgentTypeCounter(4) = AgentTypeCounter(4) + 1; 
    elseif yfit(i) == categorical("A5")
        AgentTypeCounter(5) = AgentTypeCounter(5) + 1; 
    elseif yfit(i) == categorical("A6")
        AgentTypeCounter(6) = AgentTypeCounter(6) + 1; 
    elseif yfit(i) == categorical("A7")
        AgentTypeCounter(7) = AgentTypeCounter(7) + 1; 
    end
end

for i = 1:length(AgentTypeCounter)
    AgentTypeNormalised(i) = AgentTypeCounter(i)/sum(AgentTypeCounter);
end

C2_yfit = C2.predictFcn(AgentTypeNormalised);


%% Streaming Classification (not online as sim has already run and this is a replay of it)

load('/Users/ajh/GitHub/swarmRecognition/SSCI22/Classifiers/C1.mat') % Classifier C1
load('/Users/ajh/GitHub/swarmRecognition/SSCI22/Classifiers/C2.mat') % Classifier C2
load('/Users/ajh/GitHub/swarmRecognition/SSCI22/Classifiers/C2marker.mat') % Classifier C2 from markers raw 

myDir = '/Users/ajh/GitHub/swarmRecognition/SSCI22/SimData'; % gets directory for data
myFiles = dir(fullfile(myDir, '*.mat')); % gets all mat files in struct 

    SimRun = 5; 
    % import files 
    baseFileName = myFiles(SimRun).name; 
    fullFileName = fullfile(myDir, baseFileName); 
    fprintf(1, 'Now reading %s\n', fullFileName); 
    dat = importdata(fullFileName);
    
    df.SimParameters = dat.parameters;
    SwarmAgentTypeDistribution = dat.parameters.SwarmAgentTypeDistribution; 
    Scenario = dat.parameters.ScenarioIndex;
    
    % create matlab table 
    DataTable = table(dat.SensedData.t', dat.SensedData.GoalX', dat.SensedData.GoalY', dat.SensedData.NumberOfSheep', [dat.SensedData.SheepDogX', dat.SensedData.SheepDogY'], dat.SensedData.SheepX, dat.SensedData.SheepY);
    DataTable = renamevars(DataTable, ["Var1","Var2","Var3","Var4","Var5","Var6","Var7"],["t","GoalX","GoalY","NumSheep","SheepDogXY","SheepX","SheepY"]);
    
    fprintf('Table size = [%i, %i]\n', size(DataTable,1), size(DataTable,2))

    % segment into 10-step elements
    windows = WindowSegments(DataTable);
    
    % save pre-processed files
    df.DataTable = DataTable; 
    df.windows = windows;
        % Window length = 20 
        % Window overlap = 50% 
        % Agent Type classification every 10 seconds 
        
    df.InputData = dat; % save all input data
    
    df.parameters.MaxNumAgents = max(df.DataTable.NumSheep);
    df.parameters.MaxTimeSteps = max(windows(:,2)-windows(:,1));
    df.parameters.NumMarkers = 23; % from CalculateMarkers
    df.parameters.NumScenarioWindows = size(windows,1);
    df.parameters.Scenario = Scenario;
    df.parameters.SwarmAgentTypeDistribution = SwarmAgentTypeDistribution;
    
    % Generate Marker State Data 
    MarkerState = nan(df.parameters.NumMarkers,df.parameters.MaxNumAgents,df.parameters.NumScenarioWindows); % pre-allocate memory to handle final window size (boundary case) 
    
    %% Marker State Calculations and Predictions
    fprintf('MarkerState = [%i, %i, %i]\n', size(MarkerState,1), size(MarkerState,2), size(MarkerState,3));    
    fprintf('- * - * - * - * - * - * - * - * - * - *\n')
    for DecisionWindow = 1:size(windows,1)
        fprintf('Commencing Window = %i. Observation Range = [%i, %i]\n', DecisionWindow, windows(DecisionWindow,1),windows(DecisionWindow,2)) 
        s = tic;
        MarkerState(:,:,DecisionWindow) = CalculateMarkers(df.DataTable(windows(DecisionWindow,1):windows(DecisionWindow,2),:));
        t = toc(s);
        fprintf('Compute time = %f seconds\n', t)
        fprintf('%f%% complete.\n', DecisionWindow/size(windows,1)*100)
        dat.ComputeTime(DecisionWindow) = t; 
        fprintf('- * - * - * - * - * - * - * - * - * - *\n')

        MarkerWindowData = array2table(MarkerState(:,:,1)'); 

        MarkerWindowData = renamevars(MarkerWindowData, ["Var1","Var2","Var3","Var4","Var5","Var6","Var7","Var8","Var9","Var10","Var11","Var12","Var13","Var14","Var15","Var16","Var17","Var18","Var19","Var20","Var21","Var22","Var23"],["M1","M2","M3","M4","M5","M6","M7","M8","M9","M10","M11","M12","M13","M14","M15","M16","M17","M18","M19","M20","M21","M22","M23"]);

        [ClassAgentLabel,ClassAgentScore] = C1.predictFcn(MarkerWindowData);
        
        UniqueClasses = unique(ClassAgentLabel);
        fprintf("Unique Classes = %i\n", length(UniqueClasses))
        fmt = ['Classified Agent Types: [', repmat('%g, ', 1, numel(ClassAgentLabel)-1), '%g]\n'];
        fprintf(fmt, ClassAgentLabel)

        AgentTypeCounter = zeros(1,7); 
        
        for i = 1:size(ClassAgentLabel,1)
            if ClassAgentLabel(i) == categorical("A1")
                AgentTypeCounter(1) = AgentTypeCounter(1) + 1; 
            elseif ClassAgentLabel(i) == categorical("A2")
                AgentTypeCounter(2) = AgentTypeCounter(2) + 1; 
            elseif ClassAgentLabel(i) == categorical("A3")
                AgentTypeCounter(3) = AgentTypeCounter(3) + 1; 
            elseif ClassAgentLabel(i) == categorical("A4")
                AgentTypeCounter(4) = AgentTypeCounter(4) + 1; 
            elseif ClassAgentLabel(i) == categorical("A5")
                AgentTypeCounter(5) = AgentTypeCounter(5) + 1; 
            elseif ClassAgentLabel(i) == categorical("A6")
                AgentTypeCounter(6) = AgentTypeCounter(6) + 1; 
            elseif ClassAgentLabel(i) == categorical("A7")
                AgentTypeCounter(7) = AgentTypeCounter(7) + 1; 
            end
        end
        
        for i = 1:length(AgentTypeCounter)
            AgentTypeNormalised(i) = AgentTypeCounter(i)/sum(AgentTypeCounter);
        end
        
        [ClassScenarioLabel,ClassScenarioScore] = C2.predictFcn(AgentTypeNormalised);
        fprintf('Classified Scenario = %s\n', ClassScenarioLabel)

        meanMarkerWindowData = mean(table2array(MarkerWindowData),'omitnan'); 
        meanMarkerWindowData = array2table(meanMarkerWindowData); 
        meanMarkerWindowData  = renamevars(meanMarkerWindowData, ["meanMarkerWindowData1","meanMarkerWindowData2","meanMarkerWindowData3","meanMarkerWindowData4","meanMarkerWindowData5","meanMarkerWindowData6","meanMarkerWindowData7","meanMarkerWindowData8","meanMarkerWindowData9","meanMarkerWindowData10","meanMarkerWindowData11","meanMarkerWindowData12","meanMarkerWindowData13","meanMarkerWindowData14","meanMarkerWindowData15","meanMarkerWindowData16","meanMarkerWindowData17","meanMarkerWindowData18","meanMarkerWindowData19","meanMarkerWindowData20","meanMarkerWindowData21","meanMarkerWindowData22","meanMarkerWindowData23"],["M1","M2","M3","M4","M5","M6","M7","M8","M9","M10","M11","M12","M13","M14","M15","M16","M17","M18","M19","M20","M21","M22","M23"]);

        [ClassScenarioLabelMarker,ClassScenarioScoreMarker] = C2marker.predictFcn(meanMarkerWindowData);
        fprintf('Classified Scenario (makrer classifier) = %s\n', ClassScenarioLabelMarker)

        TotalAgent(:,DecisionWindow) = ClassAgentLabel; 
        TotalScenario(:,DecisionWindow) = ClassScenarioLabel; 

        clear MarkerWindowData UniqueClasses cleClassAgentLAbel ClassAgentScore ClassScenarioLabel ClassScenarioScore AgentTypeNormalised ClassScenarioLabelMarker ClassScenarioScoreMarker

    end  

%% Stage 1 classifier is performing poorly <-- the homogeneous settings are skewing the results I think


save('C2marker', 'C2marker')
save('C1', 'C1')
save('C2', 'C2')



yNN = zeros(size(y1,1),7);

for element = 1:size(y1,1)
    if y1(element) == categorical("A1")
        yNN(element,1) = 1;
    elseif y1(element) == categorical("A2")
        yNN(element,2) = 1;
    elseif y1(element) == categorical("A3")
        yNN(element,3) = 1;
    elseif y1(element) == categorical("A4")
        yNN(element,4) = 1;
    elseif y1(element) == categorical("A5")
        yNN(element,5) = 1;
    elseif y1(element) == categorical("A6")
        yNN(element,6) = 1;
    elseif y1(element) == categorical("A7")
        yNN(element,7) = 1;
    end
    fprintf('element = %i\n', element)
end


%% Marker Value-Level 
% https://au.mathworks.com/help/stats/visualize-decision-surfaces-for-different-classifiers.html
% http://www.peteryu.ca/tutorials/matlab/visualize_decision_boundaries

% all data first 

%save('x_test','x_test')
%save('y1_test','y1_test')

for iterator = 1:23
    
    x_test = xTEST; % reset data 
    
    % Type 1 - Leave-one-out makrer to look at classification response for the test data
    
    features(13:end) % 10,7,21,23,2,8,9,17,18,19,20 --- COI = 7,8,9,10,21,22
    MarkerZz = 22; % what column
    
    xARRAY = table2array(x_test);
    value = mean(xARRAY(:,MarkerZz)); 
    x_test{:,MarkerZz} = value;
    
    %head(x_test)
    
    % now do the model 
    yfitALL = mdl.ClassificationTree.predict(x_test);
    
    confMat = confusionmat(y1_test,yfitALL);
    
    for i =1:size(confMat,1)
        recall(i)=confMat(i,i)/sum(confMat(i,:));
    end
    
    recall(isnan(recall))=[];
    
    Recall=sum(recall)/size(confMat,1);
    
    for i =1:size(confMat,1)
        precision(i)=confMat(i,i)/sum(confMat(:,i));
    end
    
    Precision=sum(precision)/size(confMat,1);
    
    F_score=2*Recall*Precision/(Precision+Recall); %%F_score=2*1/((1/Precision)+(1/Recall));
    
    fprintf('-M%i & %.1f & %.1f & %.1f \\ \n', MarkerZz, 100*Precision, 100*Recall, 100*F_score)

end

% Type 2 - Using only the top X markers identified by Mutual Information


%% Feature Selection Code (Mutual Information)

% RAW MARKERS 

% covert markers to M x N array 
markers = table2array(x);

% convert labels to numerical levels not categorical
elements = unique(y1);
labels = zeros(size(y1));
for k = 1:length(elements)
    labels(ismember(y1,elements(k))) = k;
end

[features,weights] = MI(markers,labels,1); 

% plot 
bar(weights)
set(gca, 'XTick', 1:length(features))
set(gca, 'XTickLabel', features)
xtickangle(45)
ylabel('MI Score')
xlabel('Markers')

for i = 1:length(weights)
    weightNorm(i) = weights(i)/sum(weights);
end

bar(weightNorm)
plot(cumsum(weightNorm)) 

CumSum = cumsum(weightNorm); 
CumSum > 0.95 % returns that the top 12 give 95% of CumSum when normalised

features(1:12)

% NORMALISED MARKERS -- not required 

% covert markers to M x N array 
markers = table2array(x);

% convert labels to numerical levels not categorical
elements = unique(y1);
labels = zeros(size(y1));
for k = 1:length(elements)
    labels(ismember(y1,elements(k))) = k;
end

[features,weights] = MI(markers,labels,1); 

% plot 
bar(weights)
set(gca, 'XTick', 1:length(features))
set(gca, 'XTickLabel', features)
xtickangle(45)
ylabel('MI Score')
xlabel('Markers')

% No difference between normalised and non-normalised data

summmAll = [2712 2424 2424 3636 2424 2424 5596];
for i = 1:length(summm)
    val(i) = 100*summm(i)/sum(summm);
end

summmTest = [265 232 249 381 240 210 587];
for i = 1:length(summmTest)
    valTest(i) = 100*summmTest(i)/sum(summmTest);
end

summTrain = summmAll - summmTest;
for i = 1:length(summTrain)
    valTrain(i) = 100*summTrain(i)/sum(summTrain);
end


%% INFORMATION MARKERS PAPER 

%% Visualisations 

% Figure 1
figure(1)
imagesc(normalize(squeeze(var(15,:,:))))
title('Marker $M_{15}$ for Swarm $\Pi$','interpreter','latex','FontSize',20)
ylabel('Swarm Agents','FontSize', 16) 
xlabel('Window','FontSize', 16)

% Figure 2
figure(2)
imagesc(normalize(squeeze(var(19,:,:))))
title('Marker $M_{19}$ for Swarm $\Pi$','interpreter','latex','FontSize',20)
ylabel('Swarm Agents','FontSize', 16) 
xlabel('Window','FontSize', 16)

% Figure 3
figure(3)
imagesc(normalize(squeeze(var(:,15,:))))
title('Marker set $M_{1\dots 23}$ for Agent $\pi_{15}$','interpreter','latex','FontSize',20)
ylabel('Markers','FontSize', 16) 
xlabel('Window','FontSize', 16)

% Figure 4 
figure(4)
imagesc(normalize(squeeze(var(:,3,:))))
title('Marker set $M_{1\dots 23}$ for Agent $\pi_{3}$','interpreter','latex','FontSize',20)
ylabel('Markers','FontSize', 16) 
xlabel('Window','FontSize', 16)


for i = 1:20
    figure(i)
    imagesc(normalize(squeeze(var(:,i,:))))
end

for i = 1:23
    figure(i)
    imagesc(normalize(squeeze(var(i,:,:))))
end