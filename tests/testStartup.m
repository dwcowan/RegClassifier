classdef testStartup < matlab.unittest.TestCase
    % NAME-REGISTRY:TEST testStartup

    properties
        repoRoot (1,1) string
        originalPath (1,1) string
    end

    methods(TestMethodSetup)
        function storePath(tc)
            tc.repoRoot = string(fileparts(fileparts(mfilename('fullpath'))));
            tc.originalPath = string(path);
            mustBeFolder(tc.repoRoot);
            mustBeNonempty(tc.originalPath);
        end
    end

    methods(TestMethodTeardown)
        function restorePath(tc)
            path(tc.originalPath);
        end
    end

    methods(Test, TestTags={"Unit","Smoke"})
        function testAddsRepoToPath(tc)
            startup();
            paths = split(string(path), pathsep);
            tc.verifyTrue(any(paths == tc.repoRoot));
        end
    end

    methods(Test, TestTags={"Unit","Regression"})
        function testStartupWithProjectStruct(tc)
            project.RootFolder = char(tc.repoRoot);
            startup(project);
            paths = split(string(path), pathsep);
            tc.verifyTrue(any(paths == tc.repoRoot));
        end
    end
end
