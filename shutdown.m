function shutdown(project)
%SHUTDOWN  RegClassifier project cleanup.
%
% Executed automatically when the MATLAB Project closes.
% Removes project folders from the MATLAB path and restores session defaults.

    % 1. Remove repository folders from the path
    repoRoot = project.RootFolder;
    projectPaths = genpath(repoRoot);
    pathCells = regexp(projectPaths, pathsep, 'split');
    rmpath(pathCells{:});

    % 2. Optional: revert session settings
    warning('on','all');
    format loose;

    fprintf('RegClassifier project cleanup complete. Paths removed: %s\n', repoRoot);
end