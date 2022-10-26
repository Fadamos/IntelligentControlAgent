function Segments = WindowSegments(df,WindowSize,Overlap,Verbose,Online)
% Author: Adam J Hepworth
% LastModified: 2022-07-22
% Explanaton: Data segmentation and windowing script

    if ~exist('WindowSize', 'var')
        WindowSize=20; % number of observarions per window
    end
    if ~exist('Overlap', 'var')
        Overlap=0.5; % proportion of overlap between windows
    end
    if ~exist('Verbose', 'var')
        Verbose=0; % true = sys print; false = no sys print
    end
    if ~exist('Online', 'var')
        Online=0; % default to offline calculations
    end
    
    StepSize=WindowSize*Overlap;

    if Online
        DataSize=length(df);
    else
        DataSize=size(df.t,1);
    end

    if Verbose
        fprintf("Calculating windows for n=%i observations\n", DataSize)
        fprintf("Theoretical maximum number of windows is %i\n", ceil(DataSize/StepSize))
    end

    cnt=[0,0]; % initial count for each window case 

    Segments = [-1,-1]; % capture start and finish times for each segment 

    for i = 1:StepSize:DataSize % gives 10 steps 
        if i+WindowSize <= DataSize % ensures we have 20 observations 
            if i+WindowSize > DataSize-StepSize % allows window up to WindowSize+StepSize-1 for final data segment
                if Verbose
                    fprintf("Case 2: %i = [%i, %i]\n",i, i, DataSize) % [WindowStart, WindowEnd]
                end 
                cnt(2)=cnt(2)+1; 
                Segments(sum(cnt),:) = [i, DataSize];
                if cnt(2) > 1
                    fprintf("Error: Case 2 has been used > 1 (current = %i)\n", cnt(2))
                    break
                end
            else 
                if Verbose
                    fprintf("Case 1: %i = [%i, %i]\n",i, i, i+WindowSize-1) % [WindowStart, WindowEnd]
                end
                cnt(1)=cnt(1)+1; 
                Segments(sum(cnt),:) = [i, i+WindowSize-1];
            end       
        end
    end
    if sum(cnt) <= ceil(DataSize/StepSize)
        if Verbose 
            fprintf("Ok: number of calculated windows < theoretical maximum\n")
        end
    else
        fprintf("Error: number of calculated windows > theoretical maximum\n")
    end
    if Verbose 
        fprintf("Number of calculated windows in scenario = %i (C1 = %i; C2 = %i)\n", sum(cnt), cnt(1), cnt(2))
    end

end
%