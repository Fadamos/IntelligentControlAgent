function SheepDogVehicleSpeedLimit = DogSpeedLibrary(DogSpeedDifferentialIndex)
% Author: Daniel Baxter
% Last Modified: 20-June-2022
% Explanaton: This is the dog-sheep speed differential library

    switch DogSpeedDifferentialIndex
        case 'Dog1.25' % speed differential of 1.25 times that of the sheep
            SheepDogVehicleSpeedLimit = 1.25; 
       
        case 'Dog1.5' % speed differential of 1.5 times that of the sheep
            SheepDogVehicleSpeedLimit = 1.5; 
        
        case 'Dog1.75' % speed differential of 1.75 times that of the sheep
            SheepDogVehicleSpeedLimit = 1.75; 
       
        case 'Dog2.0' % speed differential of 2.0 times that of the sheep
            SheepDogVehicleSpeedLimit = 2.0; 
    end 
end
