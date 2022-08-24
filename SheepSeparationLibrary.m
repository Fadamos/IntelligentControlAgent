function CollisionRange = SheepSeparationLibrary(SheepSheepSeparationIndex)
% Author: Daniel Baxter
% Last Modified: 20-June-2022
% Explanaton: This is the sheep-sheep separation library

    switch SheepSheepSeparationIndex
        case 'L1' % level 1 - This is base strombom
            CollisionRange = 2; 
        
        case 'L2' % level 2
            CollisionRange = 4; 
        
        case 'L3' % level 3
            CollisionRange = 6; 
        
        case 'L4' % level 4
            CollisionRange = 8; 
    end 
end
