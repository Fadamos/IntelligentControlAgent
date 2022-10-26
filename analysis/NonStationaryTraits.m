function output = NonStationaryTraits(MarkerState, AttentionThreshold)
    % Author: Adam J Hepworth
    % LastModified: 22-08-09
    % Explanaton: Non stationary traits analysis (agent and swarm)

    % summarise 
     InteractionData = MarkerState([15,23,24,31,33,35,37,39],:); 

    % proportions 
    InteractionFraction = nan(size(InteractionData,1),size(InteractionData,2)); 
    for MARKER = 1:size(InteractionData,1)
        SumTmp = sum(abs(InteractionData(MARKER,:)),'omitnan'); 
        for AGENT = 1:size(InteractionData,2) 
            InteractionFraction(MARKER,AGENT) = (abs(InteractionData(MARKER, AGENT))/SumTmp); 
        end
        clear SumTmp
    end

    % AGENT 
    % Need agent value for their interaction 
    % INTERPRETATION: 
    % agent value - L1 Norm of agent
    InteractionAgent = sum(InteractionFraction,1);

    % SWARM 
    % 'Attention Point' - threshold 
    % Then return a rank 
    % proportional value across all agents
    SumTmp = sum(abs(InteractionAgent),'omitnan'); 
    for AGENT = 1:size(InteractionAgent,2) 
        ProportionFraction(AGENT) = (abs(InteractionAgent(AGENT))/SumTmp); 
    end
    clear SumTmp 
    
    % swarm attention points
    if ~exist('AttentionThreshold', 'var')
        AttentionThreshold = 0.5; % default, for now 
    end
    
    [B,I] = sort(ProportionFraction, 'descend');
    idx = find(cumsum(B) > AttentionThreshold);
    AttentionAgentIdx = I(1:idx(1));
    AttentionPoints = zeros(1,size(MarkerState,2));
    for i = 1:length(AttentionAgentIdx)
        AttentionPoints(AttentionAgentIdx(i)) = 1;
    end
    
    output.AttentionThreshold = AttentionThreshold; % threshold for agent interaction
    output.InteractionFraction = B;  % agent interaction state vectors
    output.InteractionAgent = InteractionAgent; % agent interaction value  
    output.AttentionAgentIdx = AttentionAgentIdx; % index of agent attention points
    output.AttentionPoints = AttentionPoints; % binary Y/N if an agent is an attention point  
        
end 
