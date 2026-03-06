classdef TestSyncController < fixtures.RegTestCase
    %TESTSYNCCONTROLLER Verify sync orchestrator returns paths.

    properties
        WorkFolder
    end

    methods(TestMethodSetup)
        function setup(tc)
            tc.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
            tc.WorkFolder = pwd;
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.WorkFolder = [];
        end
    end

    methods(Test)
        function returnsArtifactPaths(tc)
            % Skip if no network connectivity (CI/offline environments)
            try
                webread('https://eur-lex.europa.eu', weboptions('Timeout', 5));
            catch
                tc.assumeTrue(false, 'No network connectivity, skipping sync test');
            end
            out = reg_crr_sync('Date','20200101');
            tc.verifyTrue(isfolder(out.eba_dir));
            tc.verifyEqual(out.eba_index, fullfile(out.eba_dir,'index.csv'));
        end
    end
end
