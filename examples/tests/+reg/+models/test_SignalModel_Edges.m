classdef test_SignalModel_Edges < matlab.unittest.TestCase
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
        function boundary_values_unimplemented(testCase)
            try
                reg.models.SignalModel.plan(1,0);
                testCase.assertIncomplete("Clean-room: NotImplemented expected");
            catch ME
                testCase.verifyMatches(ME.identifier, "^reg:model:NotImplemented$");
            end
        end
    end
end
