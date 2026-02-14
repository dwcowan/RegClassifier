% STARTUP.M - MATLAB startup script for RegClassifier
% This file is automatically run when MATLAB starts.
% It ensures test fixtures and other required directories are on the path.

% Add test fixtures to path (required for RegTestCase superclass)
if exist('tests/fixtures', 'dir')
    addpath(genpath('tests/fixtures'));
end

% Display confirmation
fprintf('RegClassifier paths configured\n');
