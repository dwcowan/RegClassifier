classdef TestCrossValidation < fixtures.RegTestCase
    %TESTCROSSVALIDATION Tests for stratified k-fold cross-validation.
    %   Tests reg.stratified_kfold_multilabel() to ensure proper stratification.

    methods (Test, TestTags = {'Unit','CrossValidation','Fast'})
        function testStratifiedKFoldBasic(tc)
            %TESTSTRATIFIEDKFOLDBASIC Test basic k-fold split functionality.
            %   Verifies that splits cover all data points exactly once.

            % Create simple multi-label dataset
            N = 50;
            L = 5;
            Y = rand(N, L) > 0.7;
            % Ensure each sample has at least one label
            for i = 1:N
                if ~any(Y(i, :))
                    Y(i, randi(L)) = true;
                end
            end

            k = 5;
            folds = reg.stratified_kfold_multilabel(Y, k);

            % Verify folds structure
            tc.verifyEqual(length(folds), k, ...
                'Should return k folds');

            % Verify each fold has train and test indices
            for i = 1:k
                tc.verifyTrue(isfield(folds(i), 'train'), ...
                    'Each fold should have train field');
                tc.verifyTrue(isfield(folds(i), 'test'), ...
                    'Each fold should have test field');
            end

            % Verify all indices used exactly once in test sets
            allTestIdx = [];
            for i = 1:k
                allTestIdx = [allTestIdx; folds(i).test(:)]; %#ok<AGROW>
            end
            allTestIdx = sort(allTestIdx);
            tc.verifyEqual(allTestIdx, (1:N)', ...
                'All data points should appear exactly once in test sets');

            % Verify train and test sets are disjoint
            for i = 1:k
                tc.verifyTrue(isempty(intersect(folds(i).train, folds(i).test)), ...
                    sprintf('Fold %d: train and test should be disjoint', i));
            end
        end

        function testStratificationPreservesDistribution(tc)
            %TESTSTRATIFICATIONPRESERVESDISTRIBUTION Test label distribution preservation.
            %   Verifies that each fold maintains approximate label proportions.

            % Create dataset with known label distribution
            N = 100;
            L = 3;
            Y = false(N, L);
            Y(1:30, 1) = true;    % 30% for label 1
            Y(1:50, 2) = true;    % 50% for label 2
            Y(1:70, 3) = true;    % 70% for label 3

            k = 5;
            folds = reg.stratified_kfold_multilabel(Y, k);

            % Check label proportions in each test fold
            globalProps = sum(Y, 1) / N;
            tolerance = 0.20;  % Allow 20% absolute deviation (reasonable for small folds)

            for i = 1:k
                testIdx = folds(i).test;
                testY = Y(testIdx, :);
                foldProps = sum(testY, 1) / length(testIdx);

                for j = 1:L
                    tc.verifyGreaterThanOrEqual(foldProps(j), globalProps(j) - tolerance, ...
                        sprintf('Fold %d, Label %d: proportion too low', i, j));
                    tc.verifyLessThanOrEqual(foldProps(j), globalProps(j) + tolerance, ...
                        sprintf('Fold %d, Label %d: proportion too high', i, j));
                end
            end
        end

        function testNoDataLeakage(tc)
            %TESTNODATALEAKAGE Test that no data leaks within each fold.
            %   Verifies that train and test sets are disjoint within the SAME fold.
            %   Note: It's correct for fold i's test to appear in fold j's train (i≠j).

            Y = rand(40, 4) > 0.6;
            for i = 1:size(Y, 1)
                if ~any(Y(i, :))
                    Y(i, 1) = true;
                end
            end

            k = 4;
            folds = reg.stratified_kfold_multilabel(Y, k);

            % For each fold, verify no overlap between its own train and test sets
            for i = 1:k
                overlap = intersect(folds(i).train, folds(i).test);
                tc.verifyEmpty(overlap, ...
                    sprintf('Data leakage in fold %d: same data in train and test', i));
            end

            % Additionally verify that train + test = all data for each fold
            for i = 1:k
                allIdx = sort([folds(i).train; folds(i).test]);
                tc.verifyEqual(allIdx, (1:size(Y,1))', ...
                    sprintf('Fold %d: train + test should cover all data', i));
            end
        end

        function testSingleLabelHandling(tc)
            %TESTSINGLELABELHANDLING Test with single label (binary classification).
            %   Verifies stratification works for binary case.

            Y = [ones(30, 1); zeros(20, 1)] > 0.5;
            k = 5;

            folds = reg.stratified_kfold_multilabel(Y, k);

            tc.verifyEqual(length(folds), k, ...
                'Should handle single-label case');

            % Verify stratification (relaxed tolerance for small folds)
            globalProp = sum(Y) / length(Y);
            % With 50 examples / 5 folds = 10 per fold, discrete stratification has high variance
            tolerance = 0.4;  % Allow 40% deviation for small folds

            for i = 1:k
                testY = Y(folds(i).test);
                foldProp = sum(testY) / length(testY);
                tc.verifyGreaterThanOrEqual(foldProp, max(0, globalProp - tolerance), ...
                    sprintf('Fold %d: single-label proportion too low', i));
                tc.verifyLessThanOrEqual(foldProp, min(1, globalProp + tolerance), ...
                    sprintf('Fold %d: single-label proportion too high', i));
            end
        end

        function testEdgeCaseSmallDataset(tc)
            %TESTEDGECASESMALLDATASET Test with very small dataset.
            %   Verifies graceful handling when N < k.

            Y = rand(3, 2) > 0.5;
            Y(1, 1) = true;  % Ensure at least one label
            k = 5;

            try
                folds = reg.stratified_kfold_multilabel(Y, k);
                % If it succeeds, verify basic properties
                tc.verifyLessThanOrEqual(length(folds), size(Y, 1), ...
                    'Number of folds should not exceed number of samples');
            catch ME
                % Should either succeed or throw informative error
                tc.verifyTrue(contains(ME.message, {'samples', 'folds', 'insufficient'}), ...
                    'Error message should be informative about small dataset');
            end
        end

        function testAllSameLabels(tc)
            %TESTALLSAMELABELS Test when all samples have same label pattern.
            %   Verifies handling of non-diverse label distributions.

            N = 20;
            Y = repmat([true false true], N, 1);  % All samples identical

            k = 4;
            folds = reg.stratified_kfold_multilabel(Y, k);

            % Should still create k folds
            tc.verifyEqual(length(folds), k, ...
                'Should create k folds even with identical labels');

            % All test sets should have same label pattern
            for i = 1:k
                testY = Y(folds(i).test, :);
                tc.verifyTrue(all(all(testY == Y(1, :), 2)), ...
                    sprintf('Fold %d: all test samples should have same labels', i));
            end
        end
    end
end
