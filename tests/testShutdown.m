function tests = testShutdown
% NAME-REGISTRY:TEST testShutdown
% Test project cleanup removes repo root from path.

tests = functiontests(localfunctions);
end

function testRemovesRepoRootFromPath(~)
    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    originalPath = path;
    cleanupObj = onCleanup(@() path(originalPath));
    project = struct('RootFolder', repoRoot);

    startup(project);
    assert(contains(path, repoRoot), 'Startup failed to add repo root to path');

    shutdown(project);
    assert(~contains(path, repoRoot), 'Shutdown did not remove repo root from path');
end
