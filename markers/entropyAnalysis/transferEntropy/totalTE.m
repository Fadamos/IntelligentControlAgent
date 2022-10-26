function totalTransferEntropy = totalTE(combinedTE, focusAgent)
    % structure of combinedTE must be:
    % [fileIndex | timeIndex | targetIndex | sourceIndex | localTranEntropy]

    % subset and split incoming / outgoing TE data
    agentIsTarget = combinedTE(combinedTE(:,3) == focusAgent,:);
    agentIsSource = combinedTE(combinedTE(:,4) == focusAgent,:);
    
    % determine total number of agents in the system 
    numAgents = max(max(combinedTE(:,3)), max(combinedTE(:,4)));
    
    % set number of time periods in the system 
    timePeriods = 1:max(combinedTE(:,2));
    
    % init netTE matrix 
    totalTransferEntropy = zeros(length(timePeriods), numAgents+1);
    
    % init time steps 
    totalTransferEntropy(:,numAgents+1) = timePeriods;
    
    % iterate over all time steps 
    for timeIter = timePeriods
    
        % init subset data for focusAgent at timeIter
        subsetTarget = agentIsTarget(find(agentIsTarget(:,2) == timeIter),:);
        subsetSource = agentIsSource(find(agentIsSource(:,2) == timeIter),:);
    
        % iterate of external agents at timeIter 
        externalAgent = union(subsetSource(:,3), subsetTarget(:,4));
        for externalAgentIndex = 1:length(externalAgent)
            % average TE vcalues for any double entries 
            meanOutgoingTE = mean(subsetSource((subsetSource(:,3) == externalAgent(externalAgentIndex)),5));
            meanIncomingTE = mean(subsetTarget((subsetTarget(:,4) == externalAgent(externalAgentIndex)),5));
        
            % calculate totalTE as totalTE = TE(s-t) + TE(t-s) for all s,t pairs, s != t
            totalTransferEntropy(timeIter,externalAgent(externalAgentIndex)) = nansum([meanOutgoingTE, meanIncomingTE]);
        end
    end  
end