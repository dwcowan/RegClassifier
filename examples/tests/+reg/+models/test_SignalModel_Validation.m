classdef test_SignalModel_Validation < matlab.unittest.TestCase
    properties (Constant)
        TestTags = {'unit','io-free','validation'};
    end
    methods (TestMethodSetup)
        function setup(testCase)
            rng(0,'twister');
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
        end
    end
    methods (Test)
        function rejects_nonpositive_rate(testCase)
            testCase.verifyError(@() reg.models.SignalModel.plan(0,1), 'MATLAB:validators:mustBePositive');
        end
        function rejects_negative_duration(testCase)
            testCase.verifyError(@() reg.models.SignalModel.plan(1,-1), 'MATLAB:validators:mustBeGreaterThanOrEqual');
        end
    end
end
