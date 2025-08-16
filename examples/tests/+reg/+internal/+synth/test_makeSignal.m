classdef test_makeSignal < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'unit','synthetic','io-free'};
    end
    methods (TestMethodSetup)
        function setup(testCase)
            rng(0,'twister');
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
        end
    end
    methods (Test)
        function stub_unimplemented(testCase)
            try
                reg.internal.synth.makeSignal(16);
                testCase.assertIncomplete("Clean-room: NotImplemented expected");
            catch ME
                testCase.verifyEqual(ME.identifier, "reg:model:NotImplemented");
            end
        end
    end
end
