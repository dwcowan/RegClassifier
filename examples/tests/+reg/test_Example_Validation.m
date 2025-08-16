classdef test_Example_Validation < matlab.unittest.TestCase
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
        function constructor_rejects_bad_nv(testCase)
            testCase.verifyError(@() reg.Example('SamplingRateHz', -1), 'MATLAB:validators:mustBePositive');
        end
        function estimate_rejects_negative_duration(testCase)
            obj = reg.Example();
            testCase.verifyError(@() obj.estimateObservationCount(-1), 'MATLAB:validators:mustBeGreaterThanOrEqual');
        end
    end
end
