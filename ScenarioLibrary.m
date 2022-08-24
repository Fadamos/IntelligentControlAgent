function Scenario = ScenarioLibrary(parameters, ScenarioIndex)
% Author: Adam J Hepworth
% LastModified: 2022-06-19
% Explanaton: Scenario library

    usr = parameters.usr;

    switch ScenarioIndex
        case 'S0' % custom scenario 
            Scenario = usr; 
        
        case 'S1' % Find and Guide
            Scenario = [0.20 0    0    0    0    0    0.80]; 
        
        case 'S2' % Disrupted
            Scenario = [0    0.20 0.20 0    0    0.20 0.40]; 
        
        case 'S3' % Separated
            Scenario = [0    0    0    0.80 0    0    0.20]; 
        
        case 'S4' % Dispersed Search
            Scenario = [0.20 0    0    0    0.20 0    0.60]; 
        
        case 'S5' % Classic Strombom
            Scenario = [0    0    0    0    0    0    1.00]; 
        
        case 'S6' % Homogeneous A1
            Scenario = [1.00 0    0    0    0    0       0]; 
        
        case 'S7' % Homogeneous A2
            Scenario = [0    1.00 0    0    0    0       0];
        
        case 'S8' % Homogeneous A3
            Scenario = [0    0    1.00 0    0    0       0];
        
        case 'S9' % Homogeneous A4
            Scenario = [0    0    0    1.00 0    0       0];
        
        case 'S10' % Homogeneous A5
            Scenario = [0    0    0    0    1.00 0       0];
        
        case 'S11' % Homogeneous A6
            Scenario = [0    0    0    0    0    1.00    0];
    end 

end
