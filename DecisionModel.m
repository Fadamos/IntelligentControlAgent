function output = DecisionModel(parameters, ProbMat, NewObs, TwoClass)
    % Author: Adam J Hepworth
    % LastModified: 2022-10-24
    % Explanaton: Intelligent control agent decision module

    
    % subcube takes the form [5 5 5] = [drive collect result]

    %% (1) Calculate scenario statistics

    %% (2) Assess specific scenario 
    if ~isnan(AgentDecision) & size(ProbMat,1) > 4
        subCube = squeeze(datacube(:, :, parameters.intent, AgentDecision, :)); 
        fprintf('Assessed Scenario is S%i\n',AgentDecision)
    end

    %% (3) Assess Heterogeneous or Homogeneous if unable 
    ScenarioTwoClass = string(TwoClass); 
    if strcmp("Homogeneous", ScenarioTwoClass)
        fprintf('Assessed Scenario type is Homogeneous\n')
        subCube = squeeze(datacube(:, :, parameters.intent, 3, :)); 
    elseif strcmp("Heterogeneous", ScenarioTwoClass)
        subCube = squeeze(datacube(:, :, parameters.intent, 2, :)); 
        fprintf('Assessed Scenario type is Heterogeneous\n')
    else
        subCube = squeeze(datacube(:, :, parameters.intent, 1, :)); 
        fprintf('Assessed Scenario type is Default\n')
    end 

    %% (4) Output selected scenario and data 

    viableTP = (1 - subCube(:,:,1)) .* subCube(:,:,4);
    [output.row, output.col] = find(viableTP == max(max(viableTP)));
    
end
