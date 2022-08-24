function direction = teDirection(mat)
    %%% Input %%%
    %            mat = matrix of raw transfer entropy calcuations, for a
    %                  given agent 
    % 
    %%% Output %%%
    %     contactMat = matrix of m-observation x n-agent where 
    %              1 = positive influence from agent-n to the mat agent
    %              0 = no influence between agent-n and the mat agent
    %             -1 = negative influence from agent-n to the mat agent
    
    % iterate over observations 
    for agent = 1:size(mat,2)
        % iterate over agents 
        for timePeriod = 1:size(mat,1)
            % assess if the TE value is 0
            if mat(timePeriod,agent) == 0
                % zero  
                direction(timePeriod,agent) = 0;
            elseif mat(timePeriod,agent) > 0
                % positive 
                direction(timePeriod,agent) = 1;
                % negative 
            elseif mat(timePeriod,agent) < 0
                    direction(timePeriod,agent) = -1;
            end
        end
    end
end
