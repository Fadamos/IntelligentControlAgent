function [EstimatedBestArm, SampleComplexity] = SuccessiveElimination(arms, delta)
    addpath(genpath('../Modules/'))
    
    %% Initialization
    S = arms; t = 1; SampleComplexity = 0;
    K = size(arms,2);
    p_hat = (mean(arms) < arms)*1;
    SampleComplexity = SampleComplexity + K;
    %% Learning
    while (size(S,2) > 1)
        p_max = max(p_hat);
        alpha = sqrt(log(K*t^2/delta)/t);
        for arm = size(S,2):-1:1;
            if(p_max - p_hat(end,arm) > 2*alpha)
                S(:,arm) = [];
                p_hat(:,arm) = [];
            end
        end
        for arm = size(S,2):-1:1;
            p_hat(arm) = (t*p_hat(arm)+ (arms(end,arm) < S(end,arm)))/(t+1);
            SampleComplexity = SampleComplexity +1;
        end
        t = t+1;
    end
    if size(S,2) == 1;
        I = find(arms == S);
        EstimatedBestArm  = I(1+floor(length(I)*rand));
    end
              

% arms(:,1) = normrnd(0.3, 0.2, [20,1])
% arms(:,2) = normrnd(0.7, 0.2, [20,1])
% arms(:,3) = normrnd(1, 0.2, [20,1])
% arms(:,4) = normrnd(0, 0.2, [20,1])
% arms(:,5) = normrnd(0.4, 0.2, [20,1])
% arms(:,6) = normrnd(0.8, 0.2, [20,1])
% arms(:,7) = normrnd(0.65, 0.2, [20,1])
% delta = 0.01