classdef test_Example_Regression < matlab.unittest.TestCase
    % Tagged, parameterized regression test template.
    % This class is clean-room friendly: it marks behavior assertions as Incomplete.
    % When you switch to build mode, uncomment the checks and implement synthetic data.

    properties (Constant)
        TestTags = {'regression','synthetic','io-free'};
    end

    properties (TestParameter)
        nObs = {128, 1024}
        noiseStd = {0.0, 0.05}
    end

    methods (TestMethodSetup)
        function setupDeterminismAndFixtures(testCase)
            rng(0,'twister'); % deterministic
            import matlab.unittest.fixtures.TemporaryFolderFixture
            testCase.applyFixture(TemporaryFolderFixture);
        end
    end

    methods (Test)
        function synthetic_pipeline_template(testCase, nObs, noiseStd)
            % Template: once in build mode, generate synthetic data and assert properties.
            % Clean-room behavior: mark as Incomplete with guidance.

            % Pseudocode / intended steps (build mode):
            % x = reg.internal.synth.makeSignal(nObs, 'NoiseStd', noiseStd);
            % obj = reg.Example('SamplingRateHz', 1000, 'IsEnabled', true);
            % nEst = obj.estimateObservationCount(nObs/1000); % durationSec placeholder
            % testCase.verifyClass(x, 'double');
            % testCase.verifySize(x, [nObs, 1]);
            % testCase.verifyGreaterThanOrEqual(nEst, 0);
            % testCase.verifyLessThanOrEqual(nEst, nObs*2);

            testCase.assertIncomplete("Clean-room: enable this regression test in build mode after implementing synthetic generation and behavior.");
        end
    end
end
