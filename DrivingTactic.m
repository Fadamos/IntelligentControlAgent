function Target = DrivingTactic(DrivingTacticIndex,parameters)
% Author: Daniel Baxter, Adam J. Hepworth
% LastModified: 21-July-2022
% Explanation: This function allocates the minimum percent of the sheep not
% in the goal as per the driving tactic

    switch DrivingTacticIndex  
        case 'DOAT' % Drive one sheep at a time 
            MinPercentToDrive = eps; 
            DrivingTacticNumber = 1;

        case 'DQH' % Drive a quarter of the flock at a time
            MinPercentToDrive = 0.25;
            DrivingTacticNumber = 2;

        case 'DHH' % Drive half of the flock at a time
            MinPercentToDrive = 0.5;
            DrivingTacticNumber = 3;
        
        case 'DTQH' % Drive three-quarters of the flock at a time
            MinPercentToDrive = 0.75;
            DrivingTacticNumber = 4;
        
        case 'DAH' % Drive the whole flock at the same time
            MinPercentToDrive = 1;
            DrivingTacticNumber = 5;

    end 
 
    Target = [MinPercentToDrive, DrivingTacticNumber];
end 