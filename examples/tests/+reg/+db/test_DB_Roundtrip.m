classdef test_DB_Roundtrip < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'integration','db','roundtrip','io-required'};
    end

    methods (TestMethodSetup)
        function setupFixtures(testCase)
            rng(0,'twister');
            import reg.testfixtures.DBConnectionFixture
            try
                testCase.applyFixture(DBConnectionFixture);
            catch ME
                % In clean-room, we expect NotImplemented
                testCase.verifyEqual(ME.identifier, "reg:controller:NotImplemented");
                testCase.assumeFail("DB fixture unavailable in clean-room; enable in build mode with Database Toolbox & config.");
            end
        end
    end

    methods (Test)
        function roundtrip_placeholder(testCase)
            % Clean-room: do not perform I/O. Provide guidance instead.
            testCase.assertIncomplete("Clean-room: add DB roundtrip checks in build mode (insert/read/verify).");
        end
    end
end
