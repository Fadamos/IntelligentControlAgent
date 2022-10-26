function [x,y] = closestAgent(currentPosition, positionMatrix)
    %{
        Inputs: 
           currentPosition = [horizontal, vertical]
           positionMatrix = m x 2 matrix of [x,y] coordinate pairs

        Outputs: 
            [x,y] coordinates of the closest agent
    %}

    m = size(positionMatrix,1); 
    distVec = zeros(m,1);
    
    for agent = 1:m
        distVec(agent) = sqrt((positionMatrix(agent,1)-currentPosition(1))^2 + (positionMatrix(agent,2)-currentPosition(2))^2);
    end
   
    nearestAgent = find(distVec == min(distVec)); 
    
    x = positionMatrix(nearestAgent,1); 
    y = positionMatrix(nearestAgent,2);
   
end
