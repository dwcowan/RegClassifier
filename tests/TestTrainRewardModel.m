classdef TestTrainRewardModel < fixtures.RegTestCase
%TESTTRAINREWARDMODEL Tests for reg.rl.train_reward_model (R2025b trainnet API).

    methods(Test)
        function testRegressionMode(tc)
            %TESTREGRESSIONMODE Verify regression reward model trains and predicts.
            tc.assumeTrue(exist('trainnet','file') == 2, ...
                'Requires Deep Learning Toolbox with trainnet');

            rng(42);
            N = 60; D = 10;
            X = randn(N, D);
            y = rand(N, 1);  % continuous quality scores

            [model, stats] = reg.rl.train_reward_model(X, y, ...
                'ModelType', 'regression', ...
                'HiddenSizes', [32, 16], ...
                'Epochs', 5, ...
                'MiniBatchSize', 16, ...
                'Verbose', false);

            tc.verifyTrue(isa(model, 'dlnetwork'), ...
                'Trained model should be a dlnetwork (not SeriesNetwork)');
            tc.verifyEqual(stats.model_type, 'regression');
            tc.verifyEqual(stats.num_samples, N);
            tc.verifyEqual(stats.num_features, D);
            tc.verifyTrue(isfield(stats, 'mse'), ...
                'Regression stats should include MSE');
        end

        function testBinaryMode(tc)
            %TESTBINARYMODE Verify binary classification reward model trains.
            tc.assumeTrue(exist('trainnet','file') == 2, ...
                'Requires Deep Learning Toolbox with trainnet');

            rng(42);
            N = 60; D = 10;
            X = randn(N, D);
            y = double(rand(N, 1) > 0.5);  % binary preferences

            [model, stats] = reg.rl.train_reward_model(X, y, ...
                'ModelType', 'binary', ...
                'HiddenSizes', [32, 16], ...
                'Epochs', 5, ...
                'MiniBatchSize', 16, ...
                'Verbose', false);

            tc.verifyTrue(isa(model, 'dlnetwork'), ...
                'Trained model should be a dlnetwork (not DAGNetwork)');
            tc.verifyEqual(stats.model_type, 'binary');
            tc.verifyTrue(isfield(stats, 'accuracy'), ...
                'Binary stats should include accuracy');
        end

        function testNoValidation(tc)
            %TESTNOVALIDATION Verify training without validation split.
            tc.assumeTrue(exist('trainnet','file') == 2, ...
                'Requires Deep Learning Toolbox with trainnet');

            rng(42);
            N = 30; D = 5;
            X = randn(N, D);
            y = rand(N, 1);

            [model, stats] = reg.rl.train_reward_model(X, y, ...
                'HiddenSizes', [16], ...
                'Epochs', 3, ...
                'ValidationFraction', 0, ...
                'Verbose', false);

            tc.verifyTrue(isa(model, 'dlnetwork'));
            tc.verifyFalse(isfield(stats, 'mse'), ...
                'Stats should have no validation metrics when validation is disabled');
        end

        function testSizeMismatchErrors(tc)
            %TESTSIZEMISMATCHERRORS Verify error on mismatched input sizes.
            X = randn(10, 5);
            y = rand(8, 1);  % wrong size

            tc.verifyError(@() reg.rl.train_reward_model(X, y, 'Verbose', false), ...
                'reg:rl:train_reward_model:SizeMismatch');
        end
    end
end
