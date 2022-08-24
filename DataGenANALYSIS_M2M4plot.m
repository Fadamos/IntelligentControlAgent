%% M2 
c = jet(15);

M220_025 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="20" & MasterKey(:,3)=="0.25"),:); 
M220_050 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="20" & MasterKey(:,3)=="0.50"),:); 
M220_075 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="20" & MasterKey(:,3)=="0.75"),:); 
M240_025 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="40" & MasterKey(:,3)=="0.25"),:); 
M240_050 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="40" & MasterKey(:,3)=="0.50"),:); 
M240_075 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="40" & MasterKey(:,3)=="0.75"),:); 
M260_025 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="60" & MasterKey(:,3)=="0.25"),:); 
M260_050 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="60" & MasterKey(:,3)=="0.50"),:); 
M260_075 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="60" & MasterKey(:,3)=="0.75"),:); 
M280_025 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="80" & MasterKey(:,3)=="0.25"),:); 
M280_050 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="80" & MasterKey(:,3)=="0.50"),:); 
M280_075 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="80" & MasterKey(:,3)=="0.75"),:); 
M2100_025 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="100" & MasterKey(:,3)=="0.25"),:); 
M2100_050 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="100" & MasterKey(:,3)=="0.50"),:); 
M2100_075 = M2(find(MasterKey(:,1)=="S11" & MasterKey(:,2)=="100" & MasterKey(:,3)=="0.75"),:);

stdshade(M220_025,0.1,[c(1,:)]);
hold on 
stdshade(M220_050,0.1,[c(2,:)]);
hold on 
stdshade(M220_075,0.1,[c(3,:)]);
hold on 
stdshade(M240_025,0.1,[c(4,:)]);
hold on 
stdshade(M240_050,0.1,[c(5,:)]);
hold on 
stdshade(M240_075,0.1,[c(6,:)]);
hold on 
stdshade(M260_025,0.1,[c(7,:)]);
hold on 
stdshade(M260_050,0.1,[c(8,:)]);
hold on 
stdshade(M260_075,0.1,[c(9,:)]);
hold on 
stdshade(M280_025,0.1,[c(10,:)]);
hold on 
stdshade(M280_050,0.1,[c(11,:)]);
hold on 
stdshade(M280_075,0.1,[c(12,:)]);
hold on 
stdshade(M2100_025,0.1,[c(13,:)]);
hold on 
stdshade(M2100_050,0.1,[c(14,:)]);
hold on 
stdshade(M2100_075,0.1,[c(15,:)]);
hold off

title('Agent interaction distribution for $S_{1,\dots,11}$','interpreter','latex','FontSize',16)
xlabel('Agent ($\pi_{1,\dots 20} $)','interpreter','latex','FontSize', 16) 
ylabel('Proportion of $\Pi$ interactions','interpreter','latex','FontSize', 16) 
legend({'','w=20, o=0.25','','w=20, o=0.50','','w=20, o=0.75','', ...
    'w=40, o=0.25','','w=40, o=0.50','','w=40, o=0.75','', ...
    'w=60, o=0.25','','w=60, o=0.50','','w=60, o=0.75','', ...
    'w=80, o=0.25','','w=80, o=0.50','','w=80, o=0.75','', ...
    'w=100, o=0.25','','w=100, o=0.50','','w=100, o=0.75'})

% Swarms 
S1 = M2(find(MasterKey(:,1)=="S1"),:);
S2 = M2(find(MasterKey(:,1)=="S2"),:);
S3 = M2(find(MasterKey(:,1)=="S3"),:);
S4 = M2(find(MasterKey(:,1)=="S4"),:);
S5 = M2(find(MasterKey(:,1)=="S5"),:);
S6 = M2(find(MasterKey(:,1)=="S6"),:);
S7 = M2(find(MasterKey(:,1)=="S7"),:);
S8 = M2(find(MasterKey(:,1)=="S8"),:);
S9 = M2(find(MasterKey(:,1)=="S9"),:);
S10 = M2(find(MasterKey(:,1)=="S10"),:);
S11 = M2(find(MasterKey(:,1)=="S11"),:);

varM2(1,:) = mean(S1);
varM2(2,:) = mean(S2);
varM2(3,:) = mean(S3);
varM2(4,:) = mean(S4);
varM2(5,:) = mean(S5);
varM2(6,:) = mean(S6);
varM2(7,:) = mean(S7);
varM2(8,:) = mean(S8);
varM2(9,:) = mean(S9);
varM2(10,:) = mean(S10);
varM2(11,:) = mean(S11);

% Agents 
A1 = [varM2(1,[1:4])'; varM2(4,[1:4])'; varM2(6,:)']; % S1 = 1:4; S4 = 1:4; S6 = 1:20;
A2 = [varM2(2,[1:4])'; varM2(7,:)']; % S2 = 1:4; S7 = 1:20;
A3 = [varM2(2,[5:8])'; varM2(8,:)']; % S2 = 5:8; S8 = 1:20;
A4 = [varM2(3,[1:16])'; varM2(9,:)']; % S3 = 1:16; S9 = 1:20;
A5 = [varM2(4,[5:8])'; varM2(10,:)']; % S4 = 5:8; S10 = 1:20;
A6 = [varM2(2,[9:12])'; varM2(11,:)']; % S2 = 9:12; S11 = 1:20;
A7 = [varM2(1,[5:20])'; varM2(2,[13:20])'; varM2(3,[17:20])'; varM2(4,[5:20])'; varM2(5,:)']; % S1 = 5:20; S2 = 13:20; S3 = 17:20; S4 = 5:20; S5 = 1:20;  


% cell array of different lengths 
C = {A1, A2, A3, A4, A5, A6, A7}; 

% Pad each vector with NaN values to equate lengths
maxNumEl = max(cellfun(@numel,C));
Cpad = cellfun(@(x){padarray(x(:),[maxNumEl-numel(x),0],NaN,'post')}, C);

% Convert cell array to matrix and run boxplot
Cmat = cell2mat(Cpad); 

boxplot(Cmat)

%% M4

varM4(1,:) = mean(M4S1);
varM4(2,:) = mean(M4S2);
varM4(3,:) = mean(M4S3);
varM4(4,:) = mean(M4S4);
varM4(5,:) = mean(M4S5);
varM4(6,:) = mean(M4S6);
varM4(7,:) = mean(M4S7);
varM4(8,:) = mean(M4S8);
varM4(9,:) = mean(M4S9);
varM4(10,:) = mean(M4S10);
varM4(11,:) = mean(M4S11);

varM4(1,:) = (sum(M4S1)./size(M4S1,1)*100)
varM4(2,:) = (sum(M4S2)./size(M4S2,1)*100)
varM4(3,:) = (sum(M4S3)./size(M4S3,1)*100)
varM4(4,:) = (sum(M4S4)./size(M4S4,1)*100)
varM4(5,:) = (sum(M4S5)./size(M4S5,1)*100)
varM4(6,:) = (sum(M4S6)./size(M4S6,1)*100)
varM4(7,:) = (sum(M4S7)./size(M4S7,1)*100)
varM4(8,:) = (sum(M4S8)./size(M4S8,1)*100)
varM4(9,:) = (sum(M4S9)./size(M4S9,1)*100)
varM4(10,:) = (sum(M4S10)./size(M4S10,1)*100)
varM4(11,:) = (sum(M4S11)./size(M4S11,1)*100)

boxplot(varM4')
title('Attention point distribution for $S_{1,\dots ,11}$','interpreter','latex','FontSize',16)
xlabel('Scenario $S_{1,\dots ,11}$','interpreter','latex','FontSize', 16) 
ylabel('Distribution (percetnage of time)','interpreter','latex','FontSize', 16) 

A1 = [varM4(1,[1:4])'; varM4(4,[1:4])'; varM4(6,:)']; % S1 = 1:4; S4 = 1:4; S6 = 1:20;
A2 = [varM4(2,[1:4])'; varM4(7,:)']; % S2 = 1:4; S7 = 1:20;
A3 = [varM4(2,[5:8])'; varM4(8,:)']; % S2 = 5:8; S8 = 1:20;
A4 = [varM4(3,[1:16])'; varM4(9,:)']; % S3 = 1:16; S9 = 1:20;
A5 = [varM4(4,[5:8])'; varM4(10,:)']; % S4 = 5:8; S10 = 1:20;
A6 = [varM4(2,[9:12])'; varM4(11,:)']; % S2 = 9:12; S11 = 1:20;
A7 = [varM4(1,[5:20])'; varM4(2,[13:20])'; varM4(3,[17:20])'; varM4(4,[5:20])'; varM4(5,:)']; % S1 = 5:20; S2 = 13:20; S3 = 17:20; S4 = 5:20; S5 = 1:20;  

% cell array of different lengths 
C = {A1, A2, A3, A4, A5, A6, A7}; 

% Pad each vector with NaN values to equate lengths
maxNumEl = max(cellfun(@numel,C));
Cpad = cellfun(@(x){padarray(x(:),[maxNumEl-numel(x),0],NaN,'post')}, C);

% Convert cell array to matrix and run boxplot
Cmat = cell2mat(Cpad); 

boxplot(Cmat)
title('Attention point distribution for $A_{1,\dots ,7}$','interpreter','latex','FontSize',16)
xlabel('Agent type $A_{1,\dots ,7}$','interpreter','latex','FontSize', 16) 
ylabel('Distribution (percetnage of time)','interpreter','latex','FontSize', 16) 