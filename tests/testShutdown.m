
classdef testShutdown < matlab.unittest.TestCase
    % NAME-REGISTRY:TEST testShutdown

    properties
        repoRoot
        originalPath
    end

    methods(TestMethodSetup)
        function setup(tc)
            tc.repoRoot = string(fileparts(fileparts(mfilename('fullpath'))));
            tc.originalPath = path;
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            path(tc.originalPath);
        end
    end

    methods(Test, TestTags={"Unit","Regression","Smoke"})
        function testRemovesRepoFromPath(tc)
            startup();
            project.RootFolder = char(tc.repoRoot);
            shutdown(project);
            paths = split(string(path), pathsep);
            tc.verifyFalse(any(paths == tc.repoRoot));
        end
    end
end
