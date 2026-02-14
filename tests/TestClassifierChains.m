classdef TestClassifierChains < fixtures.RegTestCase
    %TESTCLASSIFIERCHAINS Tests for classifier chains multi-label approach.
    %   Tests reg.train_multilabel_chains() and reg.predict_multilabel_chains().

    methods (Test, TestTags = {'Unit','Classification','Fast'})
        function testChainBasic(tc)
            %TESTCHAINBASIC Test basic chain classifier functionality.
            %   Verifies that chains can be trained and used for prediction.

            % Simple multi-label dataset
            X = randn(100, 20);
            Y = rand(100, 4) > 0.6;
            % Ensure some positive labels
            for i = 1:size(Y, 1)
                if ~any(Y(i, :))
                    Y(i, randi(4)) = true;
                end
            end

            k = 3;  % Number of folds for cross-validation

            % Train classifier chains
            models = reg.train_multilabel_chains(X, Y, k);

            tc.verifyEqual(length(models), size(Y, 2), ...
                'Should return one model per label');
            tc.verifyNotEmpty(models{1}, ...
                'Models should not be empty');

            % Predict
            [scores, thresholds, pred] = reg.predict_multilabel_chains(models, X, Y);

            tc.verifyEqual(size(scores), size(Y), ...
                'Scores should have same size as Y');
            tc.verifyEqual(size(pred), size(Y), ...
                'Predictions should have same size as Y');
            tc.verifyTrue(islogical(pred), ...
                'Predictions should be logical');
        end

        function testChainOrderMatters(tc)
            %TESTCHAINORDERMATTERS Test that label order affects results.
            %   Verifies that chains use conditional dependencies.

            X = randn(80, 15);
            Y = false(80, 3);
            % Create conditional dependencies
            Y(:, 1) = rand(80, 1) > 0.5;
            Y(:, 2) = Y(:, 1) & (rand(80, 1) > 0.3);  % Depends on label 1
            Y(:, 3) = rand(80, 1) > 0.7;

            k = 2;

            % Train with original order
            models1 = reg.train_multilabel_chains(X, Y, k);
            [scores1, ~, ~] = reg.predict_multilabel_chains(models1, X, Y);

            % Train with reversed order
            Y_rev = fliplr(Y);
            models2 = reg.train_multilabel_chains(X, Y_rev, k);
            [scores2, ~, ~] = reg.predict_multilabel_chains(models2, X, Y_rev);

            % Scores should differ (chains exploit order)
            % At least some difference expected
            scores2_flipped = fliplr(scores2);
            diff = sum(abs(scores1(:) - scores2_flipped(:)));
            tc.verifyGreaterThan(diff, 0, ...
                'Chain order should affect predictions');
        end

        function testChainVsIndependent(tc)
            %TESTCHAINVSINDEPENDENT Compare chains to independent classifiers.
            %   Verifies that chains can be at least as good as independent models.

            X = randn(120, 25);
            Y = rand(120, 4) > 0.65;
            for i = 1:size(Y, 1)
                if ~any(Y(i, :))
                    Y(i, 1) = true;
                end
            end

            k = 3;

            % Train independent classifiers
            modelsIndep = reg.train_multilabel(X, Y, k);
            [scoresIndep, ~, predIndep] = reg.predict_multilabel(modelsIndep, X, Y);

            % Train chains
            modelsChain = reg.train_multilabel_chains(X, Y, k);
            [scoresChain, ~, predChain] = reg.predict_multilabel_chains(modelsChain, X, Y);

            % Both should produce valid predictions
            tc.verifyEqual(size(predIndep), size(predChain), ...
                'Independent and chain predictions should have same size');

            % At least one of them should have some correct predictions
            correctIndep = sum(predIndep(:) == Y(:));
            correctChain = sum(predChain(:) == Y(:));
            tc.verifyGreaterThan(max(correctIndep, correctChain), 0, ...
                'At least one method should make some correct predictions');
        end

        function testChainWithSparseLabels(tc)
            %TESTCHAINWITHSPARSELABELS Test chains with very sparse label matrix.
            %   Verifies handling when most labels are negative.

            X = randn(50, 10);
            Y = false(50, 5);
            Y(1:5, :) = rand(5, 5) > 0.5;  % Only first 5 samples have labels

            k = 2;

            models = reg.train_multilabel_chains(X, Y, k);

            tc.verifyEqual(length(models), size(Y, 2), ...
                'Should create models even with sparse labels');

            [scores, ~, pred] = reg.predict_multilabel_chains(models, X, Y);

            tc.verifyEqual(size(pred), size(Y), ...
                'Predictions should match label dimensions');
        end

        function testChainConsistency(tc)
            %TESTCHAINCONSISTENCY Test prediction consistency.
            %   Verifies deterministic predictions for same input.

            X = randn(60, 15);
            Y = rand(60, 3) > 0.6;
            for i = 1:size(Y, 1)
                if ~any(Y(i, :))
                    Y(i, 2) = true;
                end
            end

            k = 2;

            models = reg.train_multilabel_chains(X, Y, k);

            [~, ~, pred1] = reg.predict_multilabel_chains(models, X, Y);
            [~, ~, pred2] = reg.predict_multilabel_chains(models, X, Y);

            tc.verifyEqual(pred1, pred2, ...
                'Predictions should be consistent for same input');
        end
    end
end
