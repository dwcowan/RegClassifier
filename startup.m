function startup(project)
%STARTUP  RegClassifier project initialization.
%
% Executed automatically when the MATLAB Project opens.
% Adds all project folders to the path and enables common defaults
% so helpers like reg.ftBuildContrastiveDataset are discoverable.

    % 1. Add entire repository (packages, tests, scripts) to path
    repoRoot = project.RootFolder;
    addpath(genpath(repoRoot));

    % 2. Optional: persist path for non‑project sessions
    % Comment out if you prefer path isolation.
    savepath;

    % 3. Recommended session settings
    rng('default');                 % deterministic randomness
    warning('on', 'all');           % surface warnings
    format compact;                 % compact console output

    fprintf('RegClassifier project ready. Path added: %s\n', repoRoot);
end
