function influence = influencePeriod(mat, verbose)
    %%% Input %%%
    %            mat = matrix of raw transfer entropy calcuations, for a
    %                  given agent 
    %        verbose = flag where
    %              1 = output is all non-zero TE as the influence period
    %              2 = output is all positive TE as the influence period
    %              3 = output is all negative TE as the influence period
    % 
    %%% Output %%%
    %     contactMat = matrix of m-observation x n-agent where 
    %              1 = influence between agent-n and the mat agent
    %              0 = no influence between agent-n and the mat agent
    
    % iterate over observations 
    for agent = 1:size(mat,2)
        % iterate over agents 
        for timePeriod = 1:size(mat,1)
            % assess if the TE value is 0
            if mat(timePeriod,agent) == 0
                % if yes, set to 0 
                influence(timePeriod,agent) = 0;
            elseif verbose == 1
                % all influence 
                influence(timePeriod,agent) = 1;
            elseif verbose == 2
                % positive only influence 
                if mat(timePeriod,agent) > 0
                    influence(timePeriod,agent) = 1;
                end
            elseif verbose == 3
                % negative only influence 
                if mat(timePeriod,agent) < 0
                    influence(timePeriod,agent) = 1;
                end
            end
        end
    end
end
