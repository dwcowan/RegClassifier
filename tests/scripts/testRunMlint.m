classdef testRunMlint < matlab.unittest.TestCase
    % NAME-REGISTRY:TEST testRunMlint

    properties
        repoRoot (1,1) string
        originalFailOn (1,1) string
    end

    methods(TestMethodSetup)
        function setup(tc)
            tc.repoRoot = string(fileparts(fileparts(mfilename('fullpath'))));
            tc.originalFailOn = string(getenv('MLINT_FAIL_ON'));
            setenv('MLINT_FAIL_ON','none');
            mustBeFolder(tc.repoRoot);
            mustBeTextScalar(tc.originalFailOn);
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            setenv('MLINT_FAIL_ON', tc.originalFailOn);
            lintDir = fullfile(tc.repoRoot, "lint");
            if isfolder(lintDir)
                rmdir(lintDir, 's');
            end
        end
    end

    methods(Test, TestTags={"Unit","Smoke"})
        function testRun(tc)
            run_mlint;
            txtPath = fullfile(tc.repoRoot, "lint", "mlint.txt");
            tc.verifyTrue(isfile(txtPath));
        end
    end
end
