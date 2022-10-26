function MarkerState = CalculateMarkers(df, Verbose)
% Author: Adam J Hepworth
% LastModified: 2022-06-16
% Explanaton: Calculate marker states for an observation period
% Input: df = Table for the period of observation 

if ~exist('Verbose', 'var')
    Verbose = true; 
end

t           = df.t;
TimeStart   = df.t(1);
TimeEnd     = df.t(end); 
TimeRange   = size(df.t,1); % length of vector 
GoalX       = df.GoalX;
GoalY       = df.GoalY;
NumSheep    = df.NumSheep;
SheepDogX   = df.SheepDogXY(:,1);
SheepDogY   = df.SheepDogXY(:,2);
SheepX      = df.SheepX; 
SheepY      = df.SheepY; 

%% Global Centre of Mass 
for i = 1:TimeRange
    GlobalCentreOfMass(i,:) = MARKERS.CentreOfMassMarker(SheepX, SheepY, NumSheep, i); % GCM positions over segment 
end

%% Segment Speed 
for agent = 1:NumSheep(end)
    tmp = MARKERS.MissionSpeedMarker(SheepX(:,agent), SheepY(:,agent), NumSheep, TimeRange, 'agent'); % speed over segment 
    SegmentSpeed(agent) = tmp.Result;
end
clear tmp

%% Segment Completion Rate 
for agent = 1:NumSheep(end)
    tmp = MARKERS.MissionCompletionRateMarker(SheepX(:,agent), SheepY(:,agent), NumSheep, GoalX, GoalY, TimeRange, 'agent'); % completion over segment
    SegmentCompletionRate(agent) = tmp.Result;
end
clear tmp
    

%% Individual - Agent Level (Individual Calculation) 
for agent = 1:NumSheep(end)
    tmp = MARKERS.HeadingMarker(SheepX(:,agent), SheepY(:,agent));
    Heading(:,agent) = tmp.headingXY; 
    Speed(:,agent) = tmp.speed; 
    clear tmp
end

%% Individual - Agent Level (Collective Claculation) -- PR and SA 
for i = 1:TimeRange
    tmpSA = MARKERS.SituationAwarenessMarker(SheepX, SheepY, SheepDogX, SheepDogY, i, NumSheep); 
    SituationAwareness(:,i) = tmpSA.LogResultSA; 
    tmpPR = MARKERS.PredationRiskMarker(SheepX, SheepY, SheepDogX, SheepDogY, NumSheep, i);
    PredationRisk(:,i) = tmpPR(:,3); 
    clear tmpSA tmpPR
end
SituationAwareness = SituationAwareness'; 
PredationRisk = PredationRisk'; 

%% Inf Th Markers
InfTh = MARKERS.InfTh2Markers(SheepX, SheepY, SheepDogX, SheepDogY, NumSheep);
InternalNetTE(1,:) = mean(mean(InfTh.valueOfNetTEinternalSync(:,2:NumSheep+1,2:NumSheep+1)));
ExternalTotalTE = mean(InfTh.valueOfTotalTEexternalSync(:,2:NumSheep+1));
AIS = repmat(InfTh.AIS, NumSheep(end), 1); 
InternalInfRank = InfTh.internalInfluenceRank; 
ExternalInfRank = InfTh.externalInfluenceRank; 
SyncAggRank = InfTh.synchronicityAggregateRank; 
NetTEsource = InfTh.netTEsource; 

%% Dynamic Body Acceleration
for i = 1:TimeRange
    for agent = 1:NumSheep(end)
        tmp = MARKERS.DBAMarker(SheepX, SheepY, i, agent);
        DynamicBodyAcceleration(i,agent) = tmp.Acceleration;
    end
end

%% Overall Dynamic Body Acceleration 
OverallDBA = sum(DynamicBodyAcceleration,'omitnan');

%% Rate of Change, ETC
for agent = 1:NumSheep(end)
    RateOfChange(agent) = MARKERS.RateOfChangeMarker(SheepX(:,agent), SheepY(:,agent), GoalX, GoalY, TimeRange);
    tmp = MARKERS.ETCMarker(SheepX(:,agent), SheepY(:,agent));
    EffToCompres(agent) = tmp.N;
    clear tmp
    PSDentropy(agent) = MARKERS.SpecEntPSD(SheepX(:,agent), SheepY(:,agent));
    ShanEnt(agent) = MARKERS.ShannonEntropy(SheepX(:,agent), SheepY(:,agent));
end 

%% LyapExp, CrossCorr, DTW, GC 
for AgentSOURCE = 1:NumSheep(end)
    for AgentTARGET = 1:NumSheep(end)
        if AgentSOURCE ~= AgentTARGET
            tmp = MARKERS.CrossCorrMarker(Heading(:,AgentSOURCE), Heading(:,AgentTARGET));
            CrossCorr(AgentSOURCE, AgentTARGET) = mean(tmp.r); 
            clear tmp
            DTW(AgentSOURCE, AgentTARGET) = MARKERS.DynamicTimeWarpingMarker(SheepX(:,AgentSOURCE), SheepX(:,AgentTARGET), SheepY(:,AgentSOURCE), SheepY(:,AgentTARGET));
            [tau21b, tau21l, err90, dH1_star, dH1_noise] = MARKERS.NormalisedInformationFlow(SheepX(:,AgentSOURCE), SheepY(:,AgentSOURCE), SheepX(:,AgentTARGET), SheepY(:,AgentTARGET));
            InfFlow2017(AgentSOURCE, AgentTARGET) = tau21b; 
            InfFlow2015(AgentSOURCE, AgentTARGET) = tau21l; 
            LyapExp(AgentSOURCE, AgentTARGET) = dH1_star; 
            NoiseSignalRatio(AgentSOURCE, AgentTARGET) = dH1_noise; 
            clear tau21b tau21l err90 dH1_star dH1_noise
        end
    end
end

%% Distances Between 
MeanDistanceBetween = MARKERS.DistanceMarker([mean(SheepX,'omitnan'); mean(SheepY,'omitnan')], true);
VarDistanceBetween = MARKERS.DistanceMarker([var(SheepX,'omitnan'); var(SheepY,'omitnan')], true);
MaxDistanceBetween = MARKERS.DistanceMarker([nanmax(SheepX); nanmax(SheepY)], true);
MinDistanceBetween = MARKERS.DistanceMarker([nanmin(SheepX); nanmin(SheepY)], true);

%% Agent State Vector
% m x n = [agents x marker state levels] 

MarkerState = [SegmentSpeed; SegmentCompletionRate; mean(Speed,'omitnan'); var(Speed,'omitnan'); mean(Heading,'omitnan'); var(Heading,'omitnan'); 
    mean(SituationAwareness,'omitnan'); var(SituationAwareness,'omitnan'); mean(PredationRisk,'omitnan'); var(PredationRisk,'omitnan'); mean(DynamicBodyAcceleration,'omitnan'); 
    var(DynamicBodyAcceleration,'omitnan'); OverallDBA; RateOfChange; mean(CrossCorr,'omitnan'); var(CrossCorr,'omitnan'); 
    mean(MeanDistanceBetween,'omitnan'); mean(VarDistanceBetween,'omitnan'); max(MaxDistanceBetween); min(MinDistanceBetween); mean(InfTh.gcmLocalTransferEntropy(:,2:NumSheep+1)); 
    var(InfTh.gcmLocalTransferEntropy(:,2:NumSheep+1)); InternalNetTE]; % original marker state for SSCI22 paper

if Verbose
    MarkerState = [SegmentSpeed;                                        % 1
                   SegmentCompletionRate;                               % 2
                   mean(Speed,'omitnan');                               % 3
                   var(Speed,'omitnan');                                % 4
                   mean(Heading,'omitnan');                             % 5 
                   var(Heading,'omitnan');                              % 6
                   mean(SituationAwareness,'omitnan');                  % 7
                   var(SituationAwareness,'omitnan');                   % 8
                   mean(PredationRisk,'omitnan');                       % 9 
                   var(PredationRisk,'omitnan');                        % 10
                   mean(DynamicBodyAcceleration,'omitnan');             % 11
                   var(DynamicBodyAcceleration,'omitnan');              % 12
                   OverallDBA;                                          % 13
                   RateOfChange;                                        % 14
                   mean(CrossCorr,'omitnan');                           % 15
                   var(CrossCorr,'omitnan');                            % 16
                   mean(MeanDistanceBetween,'omitnan');                 % 17
                   mean(VarDistanceBetween,'omitnan');                  % 18
                   max(MaxDistanceBetween);                             % 19
                   min(MinDistanceBetween);                             % 20
                   mean(InfTh.gcmLocalTransferEntropy(:,2:NumSheep+1)); % 21
                   var(InfTh.gcmLocalTransferEntropy(:,2:NumSheep+1));  % 22
                   InternalNetTE;                                       % 23
                   mean(DTW,'omitnan');                                 % 24
                   var(DTW,'omitnan');                                  % 25
                   AIS';                                                % 26
                   ExternalTotalTE;                                     % 27
                   EffToCompres;                                        % 28
                   InternalInfRank;                                     % 29
                   ExternalInfRank;                                     % 30
                   SyncAggRank;                                         % 31
                   NetTEsource;                                         % 32
                   mean(InfFlow2017,'omitnan');                         % 33
                   var(InfFlow2017,'omitnan');                          % 34
                   mean(InfFlow2015,'omitnan');                         % 35
                   var(InfFlow2015,'omitnan');                          % 36
                   mean(LyapExp,'omitnan');                             % 37
                   var(LyapExp,'omitnan');                              % 38
                   mean(NoiseSignalRatio,'omitnan');                    % 39
                   var(NoiseSignalRatio,'omitnan');                     % 40
                   PSDentropy;                                          % 41
                   ShanEnt                                              % 42
                   ];                                            
end
