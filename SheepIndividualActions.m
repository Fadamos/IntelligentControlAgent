function Output = SheepIndividualActions(ActionNumbers)
% Author: Daniel Baxter
% LastModified: 18-Jun-2022
% Explanation: This function determines the individual actions of the
% sheep (Standing, Walking, Running)

if ActionNumbers == 1
    SheepIndividualAction = "Standing"; % no movement
end
if ActionNumbers == 2
    SheepIndividualAction = "Walking"; % random movement for graze
end
if ActionNumbers == 3
    SheepIndividualAction = "Running"; % running from sheepdog
end

Output = SheepIndividualAction;