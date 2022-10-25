function output = DecisionModel(parameters, ProbMat, NewObs, TwoClass)
    % Author: Adam J Hepworth
    % LastModified: 2022-10-24
    % Explanaton: Intelligent control agent decision module

    Scenario2Class = string(TwoClass); 
    
    % subcube takes the form [5 5 5] = [drive collect result]
    if strcmp("Homogeneous", scenario)
        fprintf('Assessed Scenario type is Homogeneous\n')
        subCube = squeeze(datacube(:, :, parameters.intent, 3, :)); 
    elseif strcmp("Heterogeneous", scenario)
        subCube = squeeze(datacube(:, :, parameters.intent, 2, :)); 
        fprintf('Assessed Scenario type is Heterogeneous\n')
    else
        subCube = squeeze(datacube(:, :, parameters.intent, 1, :)); 
        fprintf('Assessed Scenario type is Default\n')
    end 

    ProbMat = [ProbMat; NewObs']; 

    mu = mean(ProbMat(:,3:end),1); % remove He and Ho columns 
    sigma = var(ProbMat(:,3:end),1); 

    output = find(max(mu - sigma) == (mu - sigma)); 
    
end


%% Only return a result if statistically significant, else reutrn output as 'false'