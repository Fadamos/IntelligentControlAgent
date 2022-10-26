function output = contactPeriod(x, y, focusAgent, contactRange, verbose)
    %%% Input %%%
    %              x = matrix of m-observation x n-agent x-coordinates
    %              y = matrix of m-observation x n-agent y-coordinates
    %     focusAgent = agent of interest
    %   contactRange = detection range for focusAgent 
    %        verbose = flag where
    %              1 = output only the individual contact periods as a 
    %                  m x n matrix  
    %              2 = output only the aggregate of all contact periods as
    %                  a m x 1 vector 
    %              3 = output individual and aggregate contact periods as
    %                  a m x n+1 matrix 
    % 
    %%% Output %%%
    %     contactMat = matrix of m-observation x n-agent where 
    %              1 = contact between agent-n and focusAgent at 
    %                  observation-m
    %              0 = no contact between agent-n and focusAgent at
    %                  observation-m
    
    % temporary calculation matrix 
    contactMat = nan(size(x));
    for agent = 1:size(contactMat,2)
        for timePeriod = 1:size(contactMat,1)
            if sqrt((x(timePeriod,focusAgent)-x(timePeriod,agent))^2 + (y(timePeriod,focusAgent)-y(timePeriod,agent))^2) <= contactRange
                contactMat(timePeriod,agent) = 1;
            else 
                contactMat(timePeriod,agent) = 0;
            end 
        end
    end
    
    % set focusAgent 
    contactMat(:,focusAgent) = 0;
    
    if verbose == 1
        output = contactMat; 
    elseif verbose == 2
        output = max(contactMat,[],2);
    elseif verbose == 3
        aggVec = max(contactMat,[],2);
        output = [contactMat, aggVec];
    end
    
end
