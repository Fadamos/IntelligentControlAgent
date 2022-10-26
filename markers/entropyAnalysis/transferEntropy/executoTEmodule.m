%% outputs 
% 1 - Heatmap of internal influence rank
figure(1)
imagesc(externalInfluenceRank);

% 2 - Heatmap of external influence rank
figure(2)
heatmap(sync.internalInfluenceRank(10:20,:));

% 3 - Heatmap of aggregate synchronicity 
figure(3)
heatmap(syncSEED.synchronicityAggregateRank(1:end,:));

% 4 - Distance to the GCM vs NetTE (per s12t02 update)
% figure(4)

% 5 - Heading change vs NetTE (per s12t02 update)
% figure(5)


%% Spatial Features 
% ResultsSheepDistances = [dist to GCM; 
%                          dist to shep; 
%                          bin number; 
%                          min dist to convex-hull boundary]

% ResultsSheepHeadings = [heading; 
%                         heading change from t-1]

% ResultsSheepPositions = [xpos; 
%                          ypos; 
%                          kNN]

% ResultsShepherdPositions = [xpos; 
%                             ypos] 

% Raw Data 


for i = 1:TimeTicks-1
    % ResultsSheepDistances
    distancesToGCM(i,:) = [ResultsSheepDistances(i,1,:)];
    distancesToShepherd(i,:) = [ResultsSheepDistances(i,2,:)];
    binId(i,:) = [ResultsSheepDistances(i,3,:)];
    distToFlockBoundary(i,:) = [ResultsSheepDistances(i,4,:)];
    
    % ResultsSheepHeadings
    sheepHeading(i,:) = [ResultsSheepHeadings(i,1,:)];
    sheepHeadingChange(i,:) = [ResultsSheepHeadings(i,2,:)];
    
    % ResultsSheepPositions
    kNNmatrix(i,:) = [ResultsSheepPositions(i,3,:)];
end


%% dimension reduction for NetTE and TotalTE
shepherdLocalTransferEntropy = squeeze(sum(shepherdLocalTransferEntropy,1));
shepherdLocalTransferEntropy = shepherdLocalTransferEntropy'; 


summaryTotalTEvalue = squeeze(sum(valueOfTotalTEexternalSync,1));

%% Net (internal influence) vs GCM Distance 

sourceSummaryNetTEvalue = sum(summaryNetTEvalue,2); % NetTE for source
sourceSummaryNetTEvalue = squeeze(sourceSummaryNetTEvalue (3:end-1,1,:));
sourceSummaryNetTEvalue = sourceSummaryNetTEvalue'; 

sorted_SummaryNetTEvalue = sort(sourceSummaryNetTEvalue);

figure(4)
for i = 1:size(distancesToGCM,2)
    scatter(sourceSummaryNetTEvalue(:,i), distancesToGCM(:,i), 'filled')
    hold on 
end
alpha(0.35)

averageSheepHeadingChange = yline(mean(nanmean(distancesToGCM)), '--');
ci95 = xline(nanmean(sorted_SummaryNetTEvalue(round(size(sorted_SummaryNetTEvalue,1)*0.95),:)));  
ci05 = xline(nanmean(sorted_SummaryNetTEvalue(round(size(sorted_SummaryNetTEvalue,1)*0.05),:))); 
title('Internal Swarm Net Transfer Entropy vs Distance to GCM')
xlabel('Net Transfer Entropy')
ylabel('Swarm Distance from GCM')
legend([averageSheepHeadingChange ci95 ci05], 'Average Distance from GCM', '95 CI', '5 CI')
% aggregate total Net TE


%% TotalTE (external influence) vs Shepherd Distance 
summaryTotalTEvalue = summaryTotalTEvalue(3:end-1,:);
summaryTotalTEvalue = summaryTotalTEvalue';

nanSummaryTotalTEvalue = summaryTotalTEvalue;
nanSummaryTotalTEvalue(nanSummaryTotalTEvalue == 0) = NaN;

sorted_SummaryTotalTEvalue = sort(nanSummaryTotalTEvalue);

% plot 
figure(5)
for i = 1:size(distancesToShepherd,2)
    scatter(nanSummaryTotalTEvalue(:,i), distancesToShepherd(:,i), 'filled')
    hold on 
end
alpha(0.35)

avgDistShepherd = yline(mean(nanmean(distancesToShepherd)), '--');
%ci95 = xline(mean(sorted_SummaryTotalTEvalue(round(size(sorted_SummaryTotalTEvalue,1)*0.95),:))); % need to rework  
%ci05 = xline(mean(sorted_SummaryTotalTEvalue(round(size(sorted_SummaryTotalTEvalue,1)*0.05),:))); % need to rework 
title('Total Transfer Entropy from Shepherd to Swarm Agents')
xlabel('Total Transfer Entropy (Shepherd --> Swarm Agent-k for all agents, k)')
ylabel('Swarm Distance from Shepherd')
%legend([avgDistShepherd ci95 ci05], 'Average Distance from Shepherd', '95 CI', '5 CI')
legend([avgDistShepherd], 'Average Distance from Shepherd')



%% NetTE GCM to agents 

% ***********************
% *** [SYNCHRONICITY] ***
% ***********************

%% Shepherd Synchronicity 

% imagesc plot 
imagesc(summaryTotalTEvalue)
colormap(bluewhitered(256))
xlabel('Shoid Agents')
ylabel('Time')

shepherdteDirectionTotTE = influencePeriod(summaryTotalTEvalue',1);

data = shepherdteDirectionTotTE;
figure; hAxes = gca;
imagesc( hAxes, data );
colormap( hAxes , [1 1 1; 0 0 0 ] )
xlabel('Shoid Agents')
xlabel('Time')


% influence period bar plot 
bar(sum(shepherdteDirectionTotTE'))


%% GCM Synchronicity 
netTEgcmSync = squeeze(sum(GCMnetTE,1));
netTEgcmSync = netTEgcmSync';

% This is the stacked plot! 
s = stackedplot(netTEgcmSync(:,3:22)); s.LineProperties(1).Color = 'r';

teDirectionNetTEgcm = teDirection(netTEgcmSync(:,2:32));
[netTEgcmInfluencePeriod,bGCM] = hist(teDirectionNetTEgcm,unique(teDirectionNetTEgcm));

totTEgcmSync = squeeze(sum(GCMtotalTE,1));
totTEgcmSync = totTEgcmSync';

%stackedplot(totTEgcmSync)

teDirectionTotTEgcm = teDirection(totTEgcmSync(:,2:32));
[totTEgcmInfluencePeriod,b2] = hist(teDirectionTotTEgcm,unique(teDirectionTotTEgcm));

netTEgcmInfluencePeriod = influencePeriod(netTEgcmSync,1);
totTEgcmInfluencePeriod = influencePeriod(totTEgcmSync,1);

% influence period for NetTE and TotTE
figure(1)
bar(sum(netTEgcmInfluencePeriod))
figure(2)
bar(sum(totTEgcmInfluencePeriod))

% imagesc plot 
imagesc(abs(netTEgcmSync(:,3:32))')
imagesc(netTEgcmSync(:,3:32)')
colormap(bluewhitered(256))
ylabel('Shoid Agents')
xlabel('Time')

imagesc(teDirectionNetTEgcm')
ylabel('Shoid Agents')
xlabel('Time')

data = bGCM';
figure; hAxes = gca;
imagesc( hAxes, data );
colormap( hAxes , [1 1 1; 0 0 0 ] )
ylabel('Shoid Agents')
xlabel('Time')

% Proportion of time in contact with the GCM 
bGCM = netTEgcmInfluencePeriod(:,3:end);
bar(sum(bGCM))
bar(mean(bGCM), 'b')
hold on 
bar(mean(bGCM(:,1)), 'r')
alpha(0.8)
ylabel('Influence Period Proportion w/ GCM')
xlabel('Shoid Agent')


%% TotalTE vs Distance to GCM vs Distance to Shepherd 
% *****************************************
% *** [SITUATION AWARENESS POSITIONING] ***
% *****************************************

leaderSheep = 1; 

figure(10)
for i = 1:size(distancesToShepherd,2)
    scatter3(abs(nanSummaryTotalTEvalue(:,i)), distancesToGCM(:,i), distToFlockBoundary(:,i), 'filled', 'MarkerFaceColor', 'b')
    hold on 
end
alpha(0.25)
scatter3(abs(nanSummaryTotalTEvalue(:,leaderSheep), distancesToGCM(:,leaderSheep), distToFlockBoundary(:,leaderSheep), 'filled', 'MarkerFaceColor', 'r')

xlabel('Total Transfer Entropy')
ylabel('Distance To GCM')
zlabel('Distance To Flock Boundary')


figure(11)
for i = 1:size(distancesToShepherd,2)
    scatter3(abs(nanSummaryTotalTEvalue(:,i)), distancesToGCM(:,i), binId(:,i), 'filled', 'MarkerFaceColor', 'b')
    hold on 
end
alpha(0.25)
scatter3(abs(nanSummaryTotalTEvalue(:,leaderSheep)), distancesToGCM(:,leaderSheep), binId(:,leaderSheep), 'filled', 'MarkerFaceColor', 'r')

xlabel('Total Transfer Entropy')
ylabel('Distance from GCM')
zlabel('Bin ID')
set(gca,'ZTick',[1:4])


%%  Predation Response
% ****************************
% *** [PREDATION RESPONSE] ***
% ****************************
figure(17)
for i = 3:size(distancesToShepherd,2)
    scatter3(distToFlockBoundary(:,i), distancesToGCM(:,i), kNNmatrix(:,i), 'filled', 'MarkerFaceColor', 'b')
    hold on 
end
alpha(0.4)
%scatter3(distToFlockBoundary(:,2), distancesToGCM(:,2), kNNmatrix(:,2), 'filled', 'MarkerFaceColor', 'r')

xlabel('Distance to Flock Boundary')
ylabel('Distance To GCM')
zlabel('kNN')














%% NetTE vs Distance to GCM vs Distance to Shepherd 

figure(11)
for i = 1:size(distancesToShepherd,1)
    scatter3(sourceSummaryNetTEvalue(:,i), distancesToGCM(:,i), distancesToShepherd(:,i), 'filled')
    %scatter3(sourceSummaryNetTEvalue(i,1:30), distancesToGCM(i,:), distancesToShepherd(i,:), 'filled')
    %scatter(distancesToGCM(a:b,i), distancesToShepherd(:,i), 'filled')
    hold on
    pause(0.2)
end
%sheep1 = scatter3(sourceSummaryNetTEvalue(:,2), distancesToGCM(:,2), distancesToShepherd(:,2), 'filled');
alpha(0.35)
%hold off

title('Net TE vs Distance to GCM vs Distance to Shepherd')
xlabel('Net Transfer Entropy')
ylabel('Distance To GCM')
zlabel('Distance To Shepherd')
%legend(sheep1,'Sheep 1')


%% Sheep Heading Change vs Distance to GCM vs Distance to Shepherd 

figure(12)
for i = 1:size(distancesToShepherd,2)
    scatter3(sheepHeadingChange(:,i), distancesToGCM(:,i), distancesToShepherd(:,i), 'filled')
    hold on 
end
alpha(0.35)

title('Sheep Heading Change vs Distance to GCM vs Distance to Shepherd')
xlabel('Net Transfer Entropy')
ylabel('Distance To GCM')
zlabel('Distance To Shepherd')


%% Distance from agents to GCM/Shepherd

[p1, x1] = hist(distancesToGCM);

figure(13)
plot(x1,p1/sum(p1))
hold on 

[p2, x2] = hist(distancesToShepherd);
plot(x2,p2/sum(p2))

%% Net TE filtered over X time-periods 

% classify top X 
threshold = 1/10; 
filteredInternalInfluenceRank = nan(TimeTicks-1, size(internalInfluenceRank,2));
for i = 1:TimeTicks-1
    maxRank = max(internalInfluenceRank(i,:));
    minRank = min(internalInfluenceRank(i,:));
    thresholdRank = maxRank-((range(minRank:maxRank)+1)*threshold);
    for j = 1:size(internalInfluenceRank,2)
        if internalInfluenceRank(i,j) >= thresholdRank
            filteredInternalInfluenceRank(i,j) = 1;
        else
            filteredInternalInfluenceRank(i,j) = 0;
        end
    end
end

figure(14)
heatmap(filteredInternalInfluenceRank(100:150,:))

figure(15)
sum(filteredInternalInfluenceRank)

figure(16)
bar(sum(filteredInternalInfluenceRank))


%% internal influence rank range

for i = 1:TimeTicks-1
    rngInternal(i) = range(min(internalInfluenceRank(i,:)):max(internalInfluenceRank(i,:)));
    rngExternal(i) = range(min(externalInfluenceRank(i,:)):max(externalInfluenceRank(i,:)));
end


%% Average Ranked Leadership over a time window
windowSize = 5;
for i = windowSize+1:TimeTicks-1
    averageRankedLd(i,:) = nanmean(internalInfluenceRank(i,:),1);
end

figure(17)
heatmap(averageRankedLd(1:30,:))

figure(18)
bar(sum(averageRankedLd))



%% GCM Net TE vs xSheepPos vs ySheepPos

figure(20)
for i = 2:size(xSheepPos,2)
    scatter3(gcmAsSourceNetTE(1:TimeTicks-1,i), xSheepPos(1:TimeTicks-1,i), ySheepPos(1:TimeTicks-1,i), 'filled', 'MarkerFaceColor', 'b')
    hold on 
end
alpha(0.1)
scatter3(gcmAsSourceNetTE(1:TimeTicks-1,1), xSheepPos(1:TimeTicks-1,1), ySheepPos(1:TimeTicks-1,1), 'filled', 'MarkerFaceColor', 'r')


xlabel('Net Transfer Entropy')
ylabel('Shoid x-position')
zlabel('Shoid y-position')

%% NetTE (internal influence) vs Sheep Heading Change

% plot 
figure(6)
for i = 1:size(sheepHeadingChange,2)
    scatter(sourceSummaryNetTEvalue(:,i), distancesToShepherd(:,i), 'filled')
    hold on 
end
alpha(0.35)

averageSheepHeadingChange = yline(mean(nanmean(sheepHeadingChange)), '--');
ci95 = xline(nanmean(sorted_SummaryNetTEvalue(round(size(sorted_SummaryNetTEvalue,1)*0.95),:)));  
ci05 = xline(nanmean(sorted_SummaryNetTEvalue(round(size(sorted_SummaryNetTEvalue,1)*0.05),:))); 
title('Internal Swarm Net Transfer Entropy vs Heading Change')
xlabel('Net Transfer Entropy')
ylabel('Agent Average Heading Change')
legend([averageSheepHeadingChange ci95 ci05], 'Average Heading Change Angle', '95 CI', '5 CI')


%% Proportion of time spent in the Top X ranked position (Net TE - internal)
figure(7)
freqInternal = hist(internalInfluenceRank,1:30);
boxplot(freqInternal)


%% Proportion of time spent in the Top Y ranked position (Total TE - external)
figure(8)
freqExternal = hist(externalInfluenceRank,1:30);
boxplot(freqExternal)


%% Total TE (external influence) vs Bin ID

% plot 
figure(9)
for i = 1:size(distancesToShepherd,2)
    boxplot(nanSummaryTotalTEvalue(:,i), binId(:,i))
    hold on 
end
alpha(0.35)


%% calculate the deviation from flock heading to individual agent heading
flockHeading = mean(sheepHeading');
flockHeadingChange = mean(sheepHeadingChange');

for observation = 1:TimeTicks-1
    for agent = 1:30
        flockHeadingDifference(observation,agent) = flockHeading(1,observation) - sheepHeading(observation,agent);
        flockHeadingChangeDifference(observation,agent) = flockHeadingChange(1,observation) - sheepHeadingChange(observation,agent); 
    end
end



%% Density plots - Distance to GCM 
for i = 1:size(distancesToGCM,2)
    f = [];
    xi = [];
    [f,xi] = ksdensity(distancesToGCM(:,i));
    plot(xi, f, 'color', [0.85 0.85 0.85], 'LineWidth', 1)
    hold on
end
[fFlock,xiFlock] = ksdensity(mean(distancesToGCM,1));
pFlock = plot(xiFlock, fFlock, 'b', 'LineWidth', 2)
[fLeader,xiLeader] = ksdensity(distancesToGCM(:,leaderSheep));
pLead = plot(xiLeader, fLeader, 'r', 'LineWidth', 2)
hold off 
legend([pLead, pFlock], 'Leader', 'Flock Average') 
xlabel('distance to GCM')
ylabel('probability density')
title('Probability Density (Distance to GCM')


%% Density plots - Distance to Shepherd
for i = 1:size(distancesToShepherd,2)
    f = [];
    xi = [];
    [f,xi] = ksdensity(distancesToShepherd(:,i));
    plot(xi, f, 'color', [0.85 0.85 0.85], 'LineWidth', 1)
    hold on
end
[fFlock,xiFlock] = ksdensity(mean(distancesToShepherd,2));
pFlock = plot(xiFlock, fFlock, 'b', 'LineWidth', 2)
[fLeader,xiLeader] = ksdensity(distancesToShepherd(:,leaderSheep));
pLead = plot(xiLeader, fLeader, 'r', 'LineWidth', 2)
hold off 
legend([pLead, pFlock], 'Leader', 'Flock Average') 
xlabel('distance to shepherd')
ylabel('probability density')
title('Probability Density (Distance to Shepherd')



%% Density plots - BinID
for i = 1:size(binId,2)
    f = [];
    xi = [];
    [f,xi] = ksdensity(binId(:,i));
    plot(xi, f, 'color', [0.85 0.85 0.85], 'LineWidth', 1)
    hold on
end
[fFlock,xiFlock] = ksdensity(mean(binId,1)); 
pFlock = plot(xiFlock, fFlock, 'b', 'LineWidth', 2)
[fLeader,xiLeader] = ksdensity(binId(:,leaderSheep));
pLead = plot(xiLeader, fLeader, 'r', 'LineWidth', 2)
hold off 
legend([pLead, pFlock], 'Leader', 'Flock Average') 
xlabel('distance to shepherd')
ylabel('probability density')
title('Probability Density (Distance to Shepherd')


%% Convex Hull size and area calculations 
for i = 1:TimeTicks-1
    [~,chullArea(i,:)] = convhull(xSheepPos(i,:), ySheepPos(i,:));
end

plot(chullArea, 'b', 'LineWidth', 2)

semilogy(chullArea, 'b', 'LineWidth', 2)

loglog(chullArea, 'b', 'LineWidth', 2)