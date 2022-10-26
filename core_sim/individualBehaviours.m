function Output = individualBehaviours(BehaviourNumber)
% Author: Daniel Baxter
% LastModified: 18-Jun-2022
% Explanation: This function determines the individual behaviour of the
% sheepdog (Driving, Collecting, Wandering)

DogsIndividualBehaviour = "unknown";

   if BehaviourNumber == 1
       DogsIndividualBehaviour = "Driving";
   end
   if BehaviourNumber == 2
       DogsIndividualBehaviour = "Collecting";
   end
   if BehaviourNumber == 3
       DogsIndividualBehaviour = "Wandering";
   end

Output = [DogsIndividualBehaviour];