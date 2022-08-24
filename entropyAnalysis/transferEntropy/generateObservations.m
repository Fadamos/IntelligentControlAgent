function [D, Dpast, S, RelSourcePos, maxSourceSamplesForATarget] = generateObservations(properties)
% This function generates the observations from which
% we can then compute information dynamics with JIDT.
% This will work for either 2D or 3D samples (as specified by the properties)
%
% Author: Emanuele Crosato, Joseph T. Lizier, 2019
% Modified: Adam J. Hepworth, 2019-2022 
%
% Inputs:
% - properties (required) - object with properties for the calculations,
%   with sub-members as specificied in the loadProperties.m file.
%
% Outputs:
% - D - target samples (may be multivariate as per below)
% - Dpast - target past samples (multivariate, and embedded up to k previous samples)
% - S - source relative headings samples (may be multivariate as per below)
% - RelSourcePos - relative source position (may be multivariate as below)
% - maxSourceSamplesForATarget - maximum number of sources in range for a specific target sample. Used for dynamic correlation exclusion externally for TE calculations.
% If no outputs are requested, these are saved to properties.resultsFile

%%
%%  Java Information Dynamics Toolkit (JIDT)
%%  Copyright (C) 2019, Joseph T. Lizier et al.
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

Verbose = false; % print function

% Call internal utility to put filename lists in a common format
files = processFilenames(properties.files);

% initialize series for storing the samples:
S = []; % initialise source observations
D = []; % initialise destination observations
Dpast = []; % initialise destination past observations
% only S and D are necessary for lagged mutual information
% all S, D and Dpast are necessary for transfer entropy
fileTimeAndPair = []; % to save time and pair
RelSourcePos = []; % initialise relative source positions
sample = 1; % initialise the current sample number
maxSourceSamplesForATarget = 0; % Track the maximum number of in range sources for a given target sample

% Need to loop over fileIndex rather than for file = files (which doesn't work properly for cell array of length 1)
for fileIndex = 1:length(files)
	dataFileName = files{fileIndex};
	% load preprocessed data using the function specified in properties.loadScript
	if (properties.data3d)
		[x,y,z] = feval(properties.loadScript, dataFileName, properties);
		numMissing = sum(sum(isnan([x,y,z])));
	else
		[x,y] = feval(properties.loadScript, dataFileName, properties);
		numMissing = sum(sum(isnan([x,y])));
    end
	
    if Verbose 
        fprintf('Loading data in %s (%d missing values)\n', dataFileName, numMissing);
    end 
	samplesBeforeThisFile = sample;
    
	% Translate the raw positions into delta Positions
	velX = x(2:end,:) - x(1:end-1,:);
	velY = y(2:end,:) - y(1:end-1,:);
	if (properties.data3d)
		velZ = z(2:end,:) - z(1:end-1,:);
	end

	% Translate velocities into headings:
	if (properties.data3d)
		% Spherical polars:
		[headingXY,headingZ,speed] = cart2sph(velX,velY,velZ);
	else
		% Polar coordinates:
		[headingXY,speed] = cart2pol(velX, velY);
    end
	% Manual way is (can verify these are same except for Nans on x,y and z):
	% headingXY = atan(velY ./ velX) + (((velX < 0).*(velY>0)) .* pi) + ...
	%		(((velX < 0).*(velY<=0)) .* (- pi));
	% But the above fails if x and y are *both* zero leaving Nan:
	% velYOnVelX = velY ./ velX; % Don't replace all nans in headingXY as some mean missing values
	% headingXY(isnan(velYOnVelX(:))) = 0;
	% xyMagnitude = sqrt(velX.^2 + velY.^2);
	% Since xyMagnitude can only be positive, we can take the straight atan to
	% compute headingZ
	% headingZ = atan(velZ ./ xyMagnitude);

    % Z-Transform 
    if (properties.zTransform)
        zTransformBmatrix = []; 
        for zTransformIterator = 1:size(x,2)
            zTransformTmp = [];
            zTransformTmp = freqz(headingXY(:,zTransformIterator),1);
            zTransformBmatrix(:,zTransformIterator) = zTransformTmp;
        end
        headingXY = zTransformBmatrix; 
    end
    
    % get number of fish and update time cycles
	numCycles = size(velX,1);
	numFish = size(velX,2);

	% Initialising destPastSample is only important in terms of ensuring it is a row vector.
	%  If we have 3D data, the vector will get padded out to the appropriate length with the first sample below.
	destPastSample = zeros(1, properties.k);

	startTime = max(1+properties.lag, (properties.k-1)*properties.tau + 3); % Adding 3: one for target, one for first target past, one for taking differences
	for i = startTime : numCycles % cycle over time
	
		timePointForSourceHeading = i-properties.lag; % This is indexed into velX and headingXY, hence no extra +1 !
		timePointForSourcePosition = i+1-properties.lag; % This is indexed into x not velX, hence the extra +1 !

		% Compute relative position of source (at time timePointForSourcePosition) to
		%  target either at this same time step or the current time at which it is updating.
		%  Note this position difference is relative to absolute Cartesian coordinates
		%  (we'll convert to relative to source heading later):
		if (properties.sourceWrtSameDestTime)
			destPositionTimePointRef = timePointForSourcePosition;
		else
			destPositionTimePointRef = i;
		end

		% cycle over fish pairs
		for idxFD = 1 : numFish % Target/Destination
		
			% check destination variable
			if isnan(headingXY(i,idxFD)) || isnan(headingXY(i-1,idxFD))
				continue;
			end
			if properties.data3d && (isnan(headingZ(i,idxFD)) || isnan(headingZ(i-1,idxFD)))
				continue;
			end
			% check destination past vector
			missingFound = false;
			for h = 1 : properties.k
				idx = i-1-(h-1)*properties.tau;
				if isnan(headingXY(idx,idxFD)) || isnan(headingXY(idx-1,idxFD))
					missingFound = true;
					break;
				end
				if properties.data3d && (isnan(headingZ(idx,idxFD)) || isnan(headingZ(idx-1,idxFD)))
					missingFound = true;
					break;
				end
			end
			if missingFound
				continue;
			end
			% Postcondition: All destination variables are ok

			% We will create **source** observation as source headings relative to target headings at appropriate time point:
			if (properties.sourceWrtSameDestTime)
				% Take reference dest heading at same time as source:
				theta_FDXY_ref = headingXY(timePointForSourceHeading,idxFD);
			else
				% Take reference dest heading at prev time step:
				theta_FDXY_ref = headingXY(i-1,idxFD);
			end
			if properties.data3d
				if (properties.sourceWrtSameDestTime)
					theta_FDZ_ref = headingZ(timePointForSourceHeading,idxFD);
				else
					theta_FDZ_ref = headingZ(i-1,idxFD);
				end
			end
			
			% create **destination** observation as change in headings:
			theta_FDXY_curr = headingXY(i,idxFD);
			theta_FDXY_prev = headingXY(i-1,idxFD);
			if properties.data3d
				theta_FDZ_curr = headingZ(i,idxFD);
				theta_FDZ_prev = headingZ(i-1,idxFD);
				destSample = [angleDifference(theta_FDXY_curr, theta_FDXY_prev), ...
					angleDifference(theta_FDZ_curr, theta_FDZ_prev)];
			else
				destSample = angleDifference(theta_FDXY_curr, theta_FDXY_prev);
			end
			
			% create **destination past** observation as changes in headings at each step:
			% TODO: we could take differences to previous sample amongst the k rather than only
			%  one back from each sample: I'm not sure if this would be a more wholistic embedding or not
			%  (only makes a difference if tau>1)
			DpastColIndex = 1;
			for h = 1 : properties.k
				idx = i-1-(h-1)*properties.tau;
				theta_FDXY_curr = headingXY(idx,idxFD);
				theta_FDXY_prev = headingXY(idx-1,idxFD);
				destPastSample(DpastColIndex) = angleDifference(theta_FDXY_curr, theta_FDXY_prev);
				DpastColIndex = DpastColIndex + 1;
				if properties.data3d
					theta_FDZ_curr = headingZ(idx,idxFD);
					theta_FDZ_prev = headingZ(idx-1,idxFD);
					destPastSample(DpastColIndex) = angleDifference(theta_FDZ_curr, theta_FDZ_prev);
					DpastColIndex = DpastColIndex + 1;
				end
			end

			if (isfield(properties, 'destSamplesOnly'))
				if (properties.destSamplesOnly)
					% User has asked for [D,Dpast] samples only to be returned,
					%  so we can do these now (without looping over sources):
					
					% Fill in the destination and destination next samples now from above:
					D(sample, :) = destSample;
					Dpast(sample, :) = destPastSample;
					fileTimeAndPair(sample,:) = [fileIndex i idxFD nan];
					
					% increment sample number
					sample = sample + 1;

					continue; % skip looping over the sources
				end
			end
			
			numSourceSamplesForThisTarget = 0;
			for idxFS = 1 : numFish % Source
			
				% check not the same fish
				if (idxFD == idxFS)
					continue;
				end

				relXOfSource = x(timePointForSourcePosition,idxFS) - x(destPositionTimePointRef,idxFD);
				relYOfSource = y(timePointForSourcePosition,idxFS) - y(destPositionTimePointRef,idxFD);
				if (properties.data3d)
					relZOfSource = z(timePointForSourcePosition,idxFS) - z(destPositionTimePointRef,idxFD);
					[xyAbsoluteAngleOfSource,zAbsoluteAngleOfSource,distanceBetween] = ...
						cart2sph(relXOfSource,relYOfSource,relZOfSource);
				else
					[xyAbsoluteAngleOfSource,distanceBetween] = ...
						cart2pol(relXOfSource,relYOfSource);
				end
				% Manually: (verified this matches cart2sph):
				% xyAbsoluteAngleOfSource = atan(relYOfSource ./ relXOfSource) + ...
				%	(((relXOfSource < 0).*(relYOfSource>0)) .* pi) + ...
				%	(((relXOfSource < 0).*(relYOfSource<=0)) .* (- pi));
				% xyRelMagnitude = sqrt(relXOfSource.^2 + relYOfSource.^2);
				% zAbsoluteAngleOfSource = atan(relZOfSource ./ xyRelMagnitude);
				% distanceBetween = sqrt(relXOfSource.^2 + relYOfSource.^2 + ...
				% 					relZOfSource.^2);
			
				% check in range
				if (distanceBetween > properties.pairRange)
					continue;
				end
				
				% check source variable
				if isnan(headingXY(timePointForSourceHeading,idxFD)) || isnan(headingXY(timePointForSourceHeading,idxFS))
					continue;
				end
				if properties.data3d && (isnan(headingZ(timePointForSourceHeading,idxFD)) || isnan(headingZ(timePointForSourceHeading,idxFS)))
					continue;
				end
				% Postcondition: There are no missing headings so we can generate an observation.
				numSourceSamplesForThisTarget = numSourceSamplesForThisTarget + 1;
				
				% Now compose the data that will be saved for this sample:
				% fileTimeAndPair is [file_index, time_index, target_index, source_index]
				fileTimeAndPair(sample,:) = [fileIndex i idxFD idxFS];
				
				% create **source** observation as source headings relative to target headings at appropriate time point:
				theta_FSXY_lag = headingXY(timePointForSourceHeading,idxFS);
				% And convert the absolute angular positions into
				% relative angular positions compared to the target's
				% heading.
				xyRelativeAngleOfSource = angleDifference(...
							xyAbsoluteAngleOfSource, ...
							theta_FDXY_ref);
				if properties.data3d
					theta_FSZ_lag = headingZ(timePointForSourceHeading,idxFS);
					sourceSample = [angleDifference(theta_FDXY_ref, theta_FSXY_lag), ...
						angleDifference(theta_FDZ_ref, theta_FSZ_lag)];
					% Elevation angle differences need to be in -pi/2,pi/2 range
					zRelativeAngleOfSource = angleDifferencePiOn2(...
								zAbsoluteAngleOfSource, ...
								theta_FDZ_ref);
					% Store these relative polar coordinates of source at timePointForSourcePosition
					RelSourcePos(sample,:) = [distanceBetween, xyRelativeAngleOfSource, zRelativeAngleOfSource];
				else
					sourceSample = angleDifference(theta_FDXY_ref, theta_FSXY_lag);
					% Store these relative polar coordinates of source at timePointForSourcePosition
					RelSourcePos(sample,:) = [distanceBetween, xyRelativeAngleOfSource];
				end
				if properties.includeSourcePositionInTransfer
					S(sample,:) = [sourceSample, RelSourcePos];
				else
					S(sample,:) = sourceSample;
				end
				
				% Fill in the destination and destination next samples now from above:
				D(sample, :) = destSample;
				Dpast(sample, :) = destPastSample;
				
				% increment sample number
				sample = sample + 1;
			end
			
			if (numSourceSamplesForThisTarget > maxSourceSamplesForATarget)
				maxSourceSamplesForATarget = numSourceSamplesForThisTarget;
			end
		end
		% fprintf('Run time step %d\n', i);
    end
    if Verbose 
        fprintf('  added %d samples\n', sample - samplesBeforeThisFile);
    end
end

if (sample - 1 == 0)
	% We've added no samples
	warning('No samples added for the given parameters!');
end

if (nargout > 1)
	% Supply the samples back to the caller
	%  (the caller is probably trying to optimise parameters at the moment)
	% Nothing to do then actually...
else
	% We're going to save the samples instead
	% display to check
    if Verbose 
        fprintf('Displaying first 5 samples for source, target, target past and fileTimeAndPair as a check:');
        disp(S(1:5,:));
        disp(D(1:5,:));
        disp(Dpast(1:5,:));
        disp(fileTimeAndPair(1:5,:));
    end
	% input(prompt);

	% save series and properties
	save(properties.resultsFile, 'S', 'D', 'Dpast', 'files', 'fileTimeAndPair', 'RelSourcePos', ...
	   'maxSourceSamplesForATarget', 'properties');
    if Verbose 	
        fprintf('Series saved in %s (%d samples in total)\n', properties.resultsFile, sample - 1);
    end
end

end
% End function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% function for computing the difference between two angles.
% the differrence must be between pi and -pi

function [diff] = angleDifference(angleA, angleB)
	diff = angleA - angleB; % subtract angles
	if abs(diff) > pi % if absolute value is larger than pi
		% replace with the complementary angle and switch sign
		diff = (2*pi - abs(diff) ) * (-sign(diff));
	end
end

% function for computing the difference between two angles in [-pi/2,pi/2].
% the differrence must be returned between pi/2 and -pi/2.
% This is used for differences in elevation angles

function [diff] = angleDifferencePiOn2(angleA, angleB)
	diff = angleA - angleB; % subtract angles
	% Pre-condition: differences between angles which were in  range of 
	%  [-pi/2,pi/2] can only be in range [-pi,pi]
	if (diff > pi/2)
		diff = pi/2 - (diff - pi/2);
	elseif (diff < -pi/2)
		diff = -pi/2 + (-pi/2 - diff);
	end
end

% Turns the fileList into a cell array of file names. The fileList can be either:
% a. a cell array of file names, e.g.: {'file1.xlsx', 'file2.xlsx'}
% b. a call to ls or ls with an argument, e.g. ls('*.xlsx')
% c. a space or tab separated character row vector of file names
% d. a character matrix of filenames (each filename on a separate row)
function fileCellArray = processFilenames(fileList)
	if (iscell(fileList))
		% We're done already:
		fileCellArray = fileList;
	elseif (isvector(fileList))
		% We have a row vector of space/tab separate filenames:
		fileCellArray = strsplit(strtrim(fileList)); % extra strtrim to remove trailing \n's
	elseif (ismatrix(fileList))
		fileCellArray = {};
		for r = 1 : size(fileList, 1)
			fileCellArray{r} = strtrim(fileList(r,:));
		end
	else
		error('fileList appears to be of an incorrect format\n');
	end
end
