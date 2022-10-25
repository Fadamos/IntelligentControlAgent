function output = lilUCB(parameters, RewardsMat, NewReward, MABiter, n, delta, epsilon, lambda, beta)

    % Author: Adam J Hepworth
    % LastModified: 2022-10-24
    % Explanaton: lilUCB function 
    
    % Implementation of "lil' UCB: An Optimal Exploration Algorithm for Multi-Armed Bandits"
    % 2014 JMLR Workshop and Conference Proceedings, vol 35:1-17
    % Kevin Jamieson, Matthew Malloy, Robert Nowak, and Sebastien Bubeck 
    
    % values as indicated from on pg.5 "For improved performance, we recommend applying footnote 2 and setting (as follows)
    
    if ~exist('delta', 'var')
        delta = 0.1; % delta > 0 --> confidence 
    end 
    if ~exist('epsilon', 'var')
        epsilon = 0.01; % epsilson > 0 --> algo param
    end 
    if ~exist('n', 'var')
        n = 11; % n = number of arms in the system (i.e. number of scenario probabilities we are including, n=11 in most cases here)
    end 
    if ~exist('lambda', 'var')
        lambda = 1 + 10/n; % lambda > 0 --> algo param
    end 
    
    
    
    
    %% Initialise 
    
    % Sample each of the n arms once 
    reward      = [RewardsMat; NewReward]; % combine previous and current observations

    % Set T_{(i)}(t) = 1 for all i 
    MABiter     = [MABiter; MABiter+1]; % counter for each of the  
    
    % Set t = n
    
    %% Loop (not a loop in our setting) 
    
    % Nomenclature 
    %   T_{(i)}(t) denotes the number of times arm i has been sampled upt to time t 
    %   X_{i,s}, s = 1,2,.. denotes independent samples from arm i 
    
    % While T_{(i)}(t) < 1 + lambda sum(j ~= i) T_{(j)}(t) for all i 
    
        % Sample arm I_t = 
        %   argmax(i in 1,..,n) mu_{i,T_{(i)}(t)} + (1 + beta) * (1 + sqrt(epsilon)) 
        %   sqrt({2 * sigma^2 (1 + epsilon) log ({log({(1 + epsilon) T_{(i)}(t)})}/{delta}}/{T_{(i)}(t)})
    
        % mu_{i,T_{(i)}(t)} = {1}/{T_{(i)}(t)} sum{s=1}{T_{(i)}(t)} X_{i,s} 
        %   as the empircal mean of the T_{(i)}(t) samples from arm i up to time t 
    
        % Set T_{(i)}(t+1) = T_{(i)}(t) + 1 if I_t = i 
    
        % Else set T_{(i)}(t+1) = T_{(i)}(t) 
    
    % Else stop and output argmax(i in 1,..,n)T_{(i)}(t)

    % while condition is our 'exit' for a particular scenario 

    if 

end