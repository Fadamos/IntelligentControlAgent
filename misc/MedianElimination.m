function [EstimatedBestArm, NbrSteps, SampleComplexity] = MedianElimination(arms, epsilon, delta)
  %  addpath(genpath('../Modules/'))
    %% Initialization
    S = median(arms); epsilon = epsilon/4; delta = delta/2; NbrSteps = 1; SampleComplexity = 0;
    %% Learning 
    while length(S) > 1; 
        K = length(S);
        NbrSamples = size(arms,1);
        SampleComplexity = SampleComplexity + NbrSamples;
        rewards = (arms < repmat(S, NbrSamples, 1))*1; % Sampling
        rewards
        ExpectedMeans = mean(rewards, 1);
        ArmToRemove = ExpectedMeans < median(ExpectedMeans);
        S(ArmToRemove) = [];
        epsilon = 3/4*epsilon; delta= delta/2; NbrSteps = NbrSteps+1;
    end
    
    if length(S) == 1;
        I = find(median(arms) == S);
        EstimatedBestArm  = I(1+floor(length(I)*rand));
    end



%     arms(:,1) = normrnd(0.3, 0.2, [20,1])
%     arms(:,2) = normrnd(0.7, 0.2, [20,1])
%     arms(:,3) = normrnd(1, 0.2, [20,1])
%     arms(:,4) = normrnd(0, 0.2, [20,1])
%     arms(:,5) = normrnd(0.4, 0.2, [20,1])
%     arms(:,6) = normrnd(0.8, 0.2, [20,1])
%     arms(:,7) = normrnd(0.65, 0.2, [20,1])