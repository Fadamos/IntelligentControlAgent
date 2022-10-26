function [Weights,SheepVehicleSpeedLimit] = SheepBehaviourLibrary(parameters,SheepBehaviourCase)
% Author: Adam J Hepworth
% LastModified: 2022-06-07
% Explanaton: Sheep behaviour library

    SheepBehaviourIndex = SheepBehaviourCase;
    
    %% Sheep Agent Type Behaviours
    switch SheepBehaviourIndex
        case 4 % Hussein's initial case 
            MotionType = 'flocking';
        
        case 'A1' % Scout 
            Weights = [parameters.WeightCohesion(1), parameters.WeightCollision(1), parameters.WeightAlignment, parameters.InfluenceOfDogWeight(1), parameters.WeightOfInertia]; 
            SheepVehicleSpeedLimit = parameters.SheepStepSize(1);
        
        case 'A2' % Control Detractor 
            Weights = [parameters.WeightCohesion(2), parameters.WeightCollision(2), parameters.WeightAlignment, parameters.InfluenceOfDogWeight(2), parameters.WeightOfInertia]; 
            SheepVehicleSpeedLimit = parameters.SheepStepSize(2);
        
        case 'A3' % Swarm Detractor 
            Weights = [parameters.WeightCohesion(3), parameters.WeightCollision(3), parameters.WeightAlignment, parameters.InfluenceOfDogWeight(3), parameters.WeightOfInertia];  
            SheepVehicleSpeedLimit = parameters.SheepStepSize(3);
        
        case 'A4' % Nomad
            Weights = [parameters.WeightCohesion(4), parameters.WeightCollision(4), parameters.WeightAlignment, parameters.InfluenceOfDogWeight(4), parameters.WeightOfInertia]; 
            SheepVehicleSpeedLimit = parameters.SheepStepSize(4);
        
        case 'A5' % Dispersed Swarmer
            Weights = [parameters.WeightCohesion(5), parameters.WeightCollision(5), parameters.WeightAlignment, parameters.InfluenceOfDogWeight(5), parameters.WeightOfInertia]; 
            SheepVehicleSpeedLimit = parameters.SheepStepSize(5);
        
        case 'A6' % Unwilling            
            Weights = [parameters.WeightCohesion(6), parameters.WeightCollision(6), parameters.WeightAlignment, parameters.InfluenceOfDogWeight(6), parameters.WeightOfInertia]; 
            SheepVehicleSpeedLimit = parameters.SheepStepSize(6);
        
        case 'A7' % Strombom
            Weights = [parameters.WeightCohesion(7), parameters.WeightCollision(7), parameters.WeightAlignment, parameters.InfluenceOfDogWeight(7), parameters.WeightOfInertia];
            SheepVehicleSpeedLimit = parameters.SheepStepSize(7); 
    end
end