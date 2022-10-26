function [activeInfoStorage, netTEshepherd, totalTEshepherd, totalTEGCM, netTEGCM, cte, agentSpecifications, internalSyncNetTE, internalSyncPeriod, internalSyncSummary, externalSyncTotalTE, externalSyncPeriod, externalSyncSummary] = transferEntropyModule(xPositionMatrix,yPositionMatrix,shepherdAgent,windowSize)
%{
    Implementation: 
        The transferEntropyModule is the primary script for transfer
        entropy calculations 

    Inputs: 
            xMat = ordered matrix of n observations for m agents
            yMat = ordered matrix of n observations for m agents
        shepherd = column representing the shepherd's location within xMat
                    and yMat

    Outputs: 
        intSync = upper triangular ordered matrix of (n,m) NetTE
        calculations at time t 
        extSync = ordered vector of 1 x m of TotTE calculations at time t
        
        activeInformationStorage
        internalSyncNetTE 
        internalSyncPeriod 
        internalSyncSummary 
        externalSyncTotalTE 
        externalSyncPeriod
        externalSyncSummary
        agentSpec
        netTEshepherd
        totalTEshepherd
        totalTEGCM
        netTEGCM

    Private Functions: 
        loadData(xPos, yPos)
        internalSync(cte, swarmAgentId)
        externalSync(cte, focusAgent)

    Public Functions: 
        teDirection.m - teDirection(mat)
        runAnalysis.m - runAnalysis(properties)        
        netTE.m - netTE(combinedTE, focusAgent)
        totalTE.m - totalTE(combinedTE, focusAgent)
        influencePeriod.m - influencePeriod(mat, verbose)
        
        
%}

Verbose = false; % sys print statements

% 1 --- Import positions and save as a txt  file 
    if Verbose     
        fprintf('loadData\n')
    end
    loadData(xPositionMatrix, yPositionMatrix);
    if Verbose     
        fprintf('Complete...\n')
    end 
    
    systemAgents = 1:size(xPositionMatrix,2);
    if Verbose     
        fprintf('There are %d unique system agents\n', length(systemAgents))
    end
    
    swarmAgents = systemAgents(systemAgents ~= shepherdAgent);
    if Verbose     
        fprintf('There are %d unique swarm agents\n', length(swarmAgents))
        fprintf('There are %d unique shepherd agents\n', length(systemAgents)-length(swarmAgents))
    end
    
% 2 --- loadProperties.m
    if Verbose         
        fprintf('loadProperties\n')
    end
    %loadProperties
            %
            % Author: Joseph T. Lizier, 2019
            % Modified: Adam J. Hepworth, 2019, 2020

            %%
            %%  Java Information Dynamics Toolkit (JIDT)
            %%  Copyright (C) 2019, Joseph T. Lizier
            %%  
            %%  This program is free software: you can redistribute it and/or modify
            %%  it under the terms of the GNU General Public License as published by
            %%  the Free Software Foundation, either version 3 of the License, or
            %%  (at your option) any later version.
            %%  
            %%  This program is distributed in the hope that it will be useful,
            %%  but WITHOUT ANY WARRANTY; without even the implied warranty of
            %%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            %%  GNU General Public License for more details.
            %%  
            %%  You should have received a copy of the GNU General Public License
            %%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
            %%
            % This script loads the default properties for the transfer entropy processing:
            clear('properties');

            %%%%%%%%%
            % FILENAMES
            %%%%%%%%%

            % Input data files:
            % properties.files can be:
            % a. a cell array of file names, e.g.: {'file1.xlsx', 'file2.xlsx'}
            % b. a call to ls or ls with an argument, e.g. ls('*.xlsx')
            % c. a space or tab separated character row vector of file names
            % d. a character matrix of filenames (each filename on a separate row)
            properties.files = {'transferEntropyModuleX.txt', 'transferEntropyModuleY.txt'};
            % Note: ensure that there are now row or column names remaining from any R file
            % import! 

            % Function to read in the data files:
            % loadScript must point to a function .m file that accepts two arguments
            %  (the name of a file, and properties object) and returns [x,y,z] (z optional, only when 3D)
            %  data where each is an array, e.g. x(time, agentIndex) indexed first by time and second by agent index.
            % Use the name of the .m file after an "@" character:
            properties.loadScript = @loadseparatexy;

            % Is the data returned by the loadScript 3D (true) or 2D (false)?
            properties.data3d = false;

            % Results file - will hold the parsed velocities / relative positions, plus the
            %  local transfer entropy results
            properties.resultsFile = 'results.mat';

            %%%%%%%%%
            % PARAMETERS
            %%%%%%%%%

            % Distance within which to consider a pair for the info theoretic analysis (units are as per what is used in the data files)
            properties.pairRange = 4; % These ones have a causal range of 3

            %%%%%%%%%
            % INFORMATION THEORETIC Parameters
            % Only lag is used for computing lagged mutual information
            % All lag, k and tau are used for transfer entropy
            % k - embedding dimension of the past of the destination array.
            % tau - embedding delay: time cycles separating each element in the past of the destination.
            % lag - time delay between the source and target in cycles

            % You can set kRange, tauRange and lagRange to ask that these are optimised by runAnalysis:
            % properties.kRange = 1:3;   % 1:10
            % properties.tauRange = 1:4; % 1:4
            % properties.lagRange = 1:3; % 1:10
            % You can also set k, tau and lag to values that generateObservations should use
            %  (although note that if this is called via runAnalysis then it will overwrite them):
            properties.k = 1;
            properties.tau = 1;
            properties.lag = 1;

            % Do we include the relative source position in the transfer entropy calculation (true), or
            %  only the relative source heading (false)
            properties.includeSourcePositionInTransfer = false;

            % Do we take relative source heading and position with respect to dest heading at that same
            %  time point (true, this is what we did for Crosato paper) or with respect
            %  to dest heading just previous to state update (false)?
            properties.sourceWrtSameDestTime = true;

            % JIDT location:
            % Adam 
            %properties.jidtJarLocation = '/Users/fadamos/GitHub/SkyShepherds/centreOfInfluence/transferEntropy/infodynamics.jar'; 
            properties.jidtJarLocation = '/Users/ajh/GitHub/IntelligentControlAgent/markers/entropyAnalysis/transferEntropy/infodynamics.jar';
            % Kate
            % properties.jidtJarLocation = 'C:\Users\K8\Documents\MATLAB\LeaderFollower Code\SSCI Analysis\Sensitivity Analysis Phase\centreOfInfluence\transferEntropy\infodynamics.jar'; 
            % Daniel 
            %  properties.jidtJarLocation = 'C:\Users\danie\Documents\ADFA\PhD\Papers\SSCI CBR\Code\Sensitivity\SkyShepherds-master\SkyShepherds-master\centreOfInfluence\transferEntropy\infodynamics.jar';

            % Inverse Z Transform: 
            % Default = false: returned Transfer Entropy is of the agents within the system
            % True: returned Transfer Entropy is of the semantic change within the
            % underlying model itself 
            properties.zTransform = false; 

            % Which estimator to use.
            % Valid values are 'gaussian' (linear) or 'kraskov' (non-linear)
            % properties.estimator = 'gaussian';
            properties.estimator = 'kraskov';

            % Properties for JIDT estimators:
            properties.jidt.kNNs = 4; % Number of nearest neighbours for Kraskov algorithm: just use 4 (default)
            properties.jidt.autoDynamicCorrelationExclusion = true; % Exclude nearest neighbours from at least the same target transition from being included in counts for TE

            properties.aisNumSurrogates = 0; % Number of surrogate calculations to run for AIS (just to see the noise floor. 0 means skip)
            properties.teNumSurrogates = 0; % Number of surrogate calculations to run for TE (just to see the noise floor. 0 means skip)
    if Verbose
        fprintf('Complete...\n')
    end

% 3 --- runAnalysis.m 
    if Verbose     
        fprintf('runAnalysis\n')
    end
    runAnalysis(properties);
    if Verbose         
        fprintf('Transfer Entropy analysis complete...\n')
    end
    load(properties.resultsFile)
    if Verbose         
        fprintf('Loading Transfer Entropy results...\n')
    end
    combinedTE = [fileTimeAndPair localTranEntropy];
    if Verbose         
        fprintf('combinedTE matrix generated...\n')
    end
    activeInfoStorage = ais; 

% 4 --- Internal Flock Synchronicity (NetTE)
    if Verbose         
        fprintf('Calculating - Internal Flock Synchronicity (NetTE)\n')
    end
    [internalSyncNetTE, internalSyncPeriod, internalSyncSummary] = internalSync(combinedTE, systemAgents);
    netTEGCM(:,:) = netTE(combinedTE, shepherdAgent+1);
    netTEshepherd(:,:) = totalTE(combinedTE, shepherdAgent);
    if Verbose
        fprintf('NetTE calculations complete...\n')
    end
    
% 5 --- External Flock Synchronicity (TotTE)
    if Verbose         
        fprintf('Calculating - External Flock Synchronicity (TotalTE)\n')
    end
    [externalSyncTotalTE, externalSyncPeriod, externalSyncSummary] = externalSync(combinedTE, shepherdAgent); 
    totalTEGCM(:,:) = totalTE(combinedTE, shepherdAgent+1);
    totalTEshepherd(:,:) = totalTE(combinedTE, shepherdAgent);
    if Verbose         
        fprintf('TotalTE  calculations complete...\n')
    end
    
% 6 --- Output 

    agentSpecifications = [length(systemAgents), length(swarmAgents), length(systemAgents)-length(swarmAgents)];
    cte = combinedTE; 
    
end

function loadData(xMat, yMat)
    
    Verbose = false; % sys print 

    % delete previous files, if they exist 
    delete('transferEntropyModuleX.txt');
    delete('transferEntropyModuleY.txt');
    try
        delete('results.mat');
    catch 
    end
        
    % export Transfer Entropy ready data
    save('transferEntropyModuleX.txt', 'xMat', '-ASCII','-append');
    save('transferEntropyModuleY.txt', 'yMat', '-ASCII','-append');
    
    % check files are created             
    if Verbose 
        while 1
            if isfile('transferEntropyModuleX.txt')
                fprintf('[x-pos] success: transferEntropyModuleX.txt\n')
                break
            end
        end

        while 1
            if isfile('transferEntropyModuleY.txt')
                fprintf('[y-pos] success: transferEntropyModuleY.txt\n')
                break
            end
        end
    end
    
end

function [internalSyncronicityNetTEmulti, internalSyncronicityPeriod, internalSynchronicitySummary] = internalSync(cte, agentId)
    
    internalSyncronicityNetTEmulti = [];
    internalSyncronicityPeriod = [];
    internalSynchronicitySummary = []; 
    internalSyncNetTEsummary = []; 
    
    for i = 1:size(agentId,2)
        %fprintf('starting with %d\n', i)
        internalSyncronicityNetTEmulti(:,:,i) = netTE(cte, agentId(i));
        
        % per time period calculations 
        internalSyncronicityPeriod(:,:,i) = teDirection(internalSyncronicityNetTEmulti(:,:,i));
        
        % summary claculations
        internalSynchronicitySummary(i,:) = sum(internalSyncronicityPeriod(:,:,i));
        
        %fprintf('%d complete\n', i)
    end
    
end

function [externalSynchronicityTotalTEmulti, externalSyncronicityPeriod, externalSynchronicitySummary] = externalSync(cte, swarmAgentId)
    
    % calculate TotTE (s = shepherd; t = flock agents)
    externalSynchronicityTotalTEmulti = totalTE(cte, swarmAgentId); 
    
    % calculate influence period 
    externalSyncronicityPeriod = influencePeriod(externalSynchronicityTotalTEmulti, swarmAgentId);
    
    % summary external influence 
    externalSynchronicitySummary = sum(externalSyncronicityPeriod);
end
%
