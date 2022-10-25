function output = DecisionModel(parameters, ProbMat, NewObs)
    % Author: Adam J Hepworth
    % LastModified: 2022-10-24
    % Explanaton: Intelligent control agent decision module

    ProbMat = [ProbMat; NewObs']; 

    mu = mean(ProbMat(:,3:end),1); % remove He and Ho columns 
    sigma = var(ProbMat(:,3:end),1); 

    output = find(max(mu - sigma) == (mu - sigma)); 
    
end


%% Only return a result if statistically significant, else reutrn output as 'false'