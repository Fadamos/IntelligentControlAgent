function swarm = generateSwarm(NumberOfSheep,SheepBehaviourType,Scenario)
    % Author: Adam J. Hepworth
    % LastModified: 2022-06-06
    % Explanation: This function generates the vector of agent types for the
    % swarm
    
    SwarmAgentTypes = round(NumberOfSheep * Scenario);
    swarm = repelem(SheepBehaviourType, SwarmAgentTypes);
end