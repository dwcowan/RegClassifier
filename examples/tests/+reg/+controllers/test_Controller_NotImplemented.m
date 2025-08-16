classdef test_Controller_NotImplemented < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'unit','io-free'};
    end
    methods (TestMethodSetup)
        function setup(testCase)
            rng(0,'twister');
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
        end
    end
    methods (Test)
        function controller_stub(testCase)
            import reg.controllers.Controller
            try
                Controller.runPipeline(struct('samplingRateHz',1000,'durationSec',1));
                testCase.assertIncomplete("Clean-room: NotImplemented expected");
            catch ME
                testCase.verifyEqual(ME.identifier, "reg:controller:NotImplemented");
            end
        end
    end
end
