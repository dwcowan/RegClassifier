classdef TestTrainRewardModel < fixtures.RegTestCase
%TESTTRAINREWARDMODEL Tests for reg.rl.train_reward_model (Bradley-Terry pairwise API).

    methods(Test)
        function testBasicTraining(tc)
            %TESTBASICTRAINING Verify pairwise reward model trains and returns valid outputs.
            tc.assumeTrue(exist('trainnet','file') == 2 || exist('dlnetwork','file') == 2, ...
                'Requires Deep Learning Toolbox');

            rng(42);
            N = 60; D = 10;
            features_preferred = randn(N, D);
            features_rejected  = randn(N, D) - 0.5;  % slightly worse

            [model, stats] = reg.rl.train_reward_model(features_preferred, features_rejected, ...
                'HiddenSizes', [32, 16], ...
                'Epochs', 5, ...
                'MiniBatchSize', 16, ...
                'Verbose', false);

            tc.verifyTrue(isa(model, 'dlnetwork'), ...
                'Trained model should be a dlnetwork');
            tc.verifyEqual(stats.num_pairs, N);
            tc.verifyEqual(stats.num_features, D);
            tc.verifyTrue(isfield(stats, 'train_losses'), ...
                'Stats should include train_losses');
            tc.verifyEqual(stats.epochs_trained, 5);
        end

        function testPairwiseAccuracy(tc)
            %TESTPAIRWISEACCURACY Verify pairwise accuracy is computed on validation set.
            tc.assumeTrue(exist('trainnet','file') == 2 || exist('dlnetwork','file') == 2, ...
                'Requires Deep Learning Toolbox');

            rng(42);
            N = 60; D = 10;
            features_preferred = randn(N, D) + 1;  % clearly better
            features_rejected  = randn(N, D) - 1;  % clearly worse

            [~, stats] = reg.rl.train_reward_model(features_preferred, features_rejected, ...
                'HiddenSizes', [32, 16], ...
                'Epochs', 10, ...
                'MiniBatchSize', 16, ...
                'ValidationFraction', 0.2, ...
                'Verbose', false);

            tc.verifyTrue(isfield(stats, 'pairwise_accuracy'), ...
                'Stats should include pairwise_accuracy when validation is used');
            tc.verifyTrue(isfield(stats, 'best_val_loss'), ...
                'Stats should include best_val_loss when validation is used');
        end

        function testNoValidation(tc)
            %TESTNOVALIDATION Verify training without validation split.
            tc.assumeTrue(exist('trainnet','file') == 2 || exist('dlnetwork','file') == 2, ...
                'Requires Deep Learning Toolbox');

            rng(42);
            N = 30; D = 5;
            features_preferred = randn(N, D);
            features_rejected  = randn(N, D);

            [model, stats] = reg.rl.train_reward_model(features_preferred, features_rejected, ...
                'HiddenSizes', [16], ...
                'Epochs', 3, ...
                'ValidationFraction', 0, ...
                'Verbose', false);

            tc.verifyTrue(isa(model, 'dlnetwork'));
            tc.verifyFalse(isfield(stats, 'pairwise_accuracy'), ...
                'Stats should have no pairwise_accuracy when validation is disabled');
        end

        function testSizeMismatchErrors(tc)
            %TESTSIZEMISMATCHERRORS Verify error on mismatched input sizes.
            X_pref = randn(10, 5);
            X_rej  = randn(8, 5);  % wrong number of rows

            tc.verifyError(@() reg.rl.train_reward_model(X_pref, X_rej, 'Verbose', false), ...
                'reg:rl:train_reward_model:SizeMismatch');
        end
    end
end
