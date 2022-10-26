function [listOfFolderNames, listOfFileNames, numberOfFolders, allFileInfo, thisFolder, totalNumberOfFiles, baseNameNoExt] = RecurseFolderStructure(topLevelFolder)
    
    % Start with a folder and get a list of all subfolders.  Use with R2016b and later.
    % It's done differently with R2016a and earlier, with genpath().
    % Finds and prints names of all files in that folder and all of its subfolders.
    % Similar to imageSet() function in the Computer Vision System Toolbox: http://www.mathworks.com/help/vision/ref/imageset-class.html
    
    % Initialization steps:
    clc;    % Clear the command window.
    workspace;  % Make sure the workspace panel is showing.
    format long g;
    format compact;
    
    % Specify the file pattern.
    filePattern = sprintf('%s/**/*.mat', topLevelFolder);
    allFileInfo = dir(filePattern);
    
    % Throw out any folders.  We want files only, not folders.
    isFolder = [allFileInfo.isdir]; % Logical list of what item is a folder or not.
    % Now set those folder entries to null, essentially deleting/removing them from the list.
    allFileInfo(isFolder) = [];
    % Get a cell array of strings.  We don't really use it.  I'm just showing you how to get it in case you want it.
    listOfFolderNames = unique({allFileInfo.folder});
    numberOfFolders = length(listOfFolderNames);
    fprintf('The total number of folders to look in is %d.\n', numberOfFolders);
    
    % Get a cell array of base filename strings.  We don't really use it.  I'm just showing you how to get it in case you want it.
    listOfFileNames = {allFileInfo.name};
    totalNumberOfFiles = length(listOfFileNames);
    fprintf('The total number of files in those %d folders is %d.\n', numberOfFolders, totalNumberOfFiles);
    
    % Process all files in those folders.
    totalNumberOfFiles = length(allFileInfo);
    % Now we have a list of all files, matching the pattern, in the top level folder and its subfolders.
    if totalNumberOfFiles >= 1
	    for k = 1 : totalNumberOfFiles
		    % Go through all those files.
		    thisFolder = allFileInfo(k).folder;
		    thisBaseFileName = allFileInfo(k).name;
		    fullFileName = fullfile(thisFolder, thisBaseFileName);
    % 		fprintf('     Processing file %d of %d : "%s".\n', k, totalNumberOfFiles, fullFileName);
    
		    [~, baseNameNoExt, ~] = fileparts(thisBaseFileName);
		    fprintf('%s\n', baseNameNoExt);
	    end
    else
	    fprintf('     Folder %s has no files in it.\n', thisFolder);
    end
    fprintf('\nDone looking in all %d folders!\nFound %d files in the %d folders.\n', numberOfFolders, totalNumberOfFiles, numberOfFolders);

end