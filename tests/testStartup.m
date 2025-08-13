function tests = testStartup
% NAME-REGISTRY:TEST testStartup
% Test project initialization adds repo root to path.

tests = functiontests(localfunctions);
end

function testAddsRepoRootToPath(~)
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    originalPath = path;
    cleanupObj = onCleanup(@() path(originalPath));
    project = struct('RootFolder', repoRoot);

    startup(project);

    assert(contains(path, repoRoot), 'Startup did not add repo root to path');
end
