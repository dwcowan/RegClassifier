classdef test_Example_Edges < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'unit','io-free','edges'};
    end
    methods (TestMethodSetup)
        function setup(testCase)
            rng(0,'twister');
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
        end
    end
    methods (Test)
        function zero_duration_allowed_but_unimplemented(testCase)
            obj = reg.Example();
            try
                obj.estimateObservationCount(0);
                testCase.assertIncomplete("Clean-room: NotImplemented expected");
            catch ME
                testCase.verifyMatches(ME.identifier, "^reg:(model|controller|view):NotImplemented$");
            end
        end
    end
end
