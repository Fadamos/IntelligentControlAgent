function output = MarkerClassPreProcess(Markers, parameters)
    % Author: Adam J Hepworth
    % LastModified: 2022-07-23
    % Explanaton: Pre-Processing for Information Markers classification

    %% 1- Add agent and scenario state columns 
    Scenario = parameters.ScenarioIndex;
    SwarmAgentTypeDistribution = parameters.SwarmAgentTypeDistribution; 
    
    parameters.Class.Scenario = convertCharsToStrings(Scenario);
    parameters.Class.Scenario = repelem(parameters.Class.Scenario, parameters.NumberOfSheep); 
    
    %% 2- flatten marker state 

    
    

end