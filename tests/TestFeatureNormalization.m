classdef TestFeatureNormalization < fixtures.RegTestCase
    %TESTFEATURENORMALIZATION Tests for feature normalization.
    %   Tests reg.normalize_features() for various normalization methods.

    methods (Test, TestTags = {'Unit','Features','Fast'})
        function testZScoreNormalization(tc)
            %TESTZSC ORENORMALIZATION Test z-score normalization (mean=0, std=1).
            %   Verifies that normalized features have zero mean and unit variance.

            X = randn(100, 50) * 5 + 10;  % Random features with non-zero mean

            Xnorm = reg.normalize_features(X, 'Method', 'zscore');

            % Verify size preserved
            tc.verifyEqual(size(Xnorm), size(X), ...
                'Normalized features should have same size as input');

            % Verify mean ≈ 0
            colMeans = mean(Xnorm, 1);
            tc.verifyLessThan(max(abs(colMeans)), 1e-10, ...
                'Z-score normalized features should have zero mean');

            % Verify std ≈ 1
            colStds = std(Xnorm, 0, 1);
            tc.verifyLessThan(max(abs(colStds - 1)), 1e-10, ...
                'Z-score normalized features should have unit std');
        end

        function testMinMaxNormalization(tc)
            %TESTMINMAXNORMALIZATION Test min-max normalization to [0,1].
            %   Verifies that normalized features are in range [0, 1].

            X = randn(100, 50) * 10 + 5;

            Xnorm = reg.normalize_features(X, 'Method', 'minmax');

            % Verify size preserved
            tc.verifyEqual(size(Xnorm), size(X), ...
                'Normalized features should have same size as input');

            % Verify range [0, 1]
            tc.verifyGreaterThanOrEqual(min(Xnorm(:)), 0, ...
                'Min-max normalized features should have min >= 0');
            tc.verifyLessThanOrEqual(max(Xnorm(:)), 1, ...
                'Min-max normalized features should have max <= 1');

            % Verify each column has min=0 and max=1
            colMins = min(Xnorm, [], 1);
            colMaxs = max(Xnorm, [], 1);
            tc.verifyLessThan(max(abs(colMins)), 1e-10, ...
                'Each column should have min ≈ 0');
            tc.verifyLessThan(max(abs(colMaxs - 1)), 1e-10, ...
                'Each column should have max ≈ 1');
        end

        function testL2Normalization(tc)
            %TESTL2NORMALIZATION Test L2 row normalization.
            %   Verifies that each row has unit L2 norm.

            X = randn(100, 50);

            Xnorm = reg.normalize_features(X, 'Method', 'l2');

            % Verify size preserved
            tc.verifyEqual(size(Xnorm), size(X), ...
                'Normalized features should have same size as input');

            % Verify each row has L2 norm = 1
            rowNorms = vecnorm(Xnorm, 2, 2);
            tc.verifyLessThan(max(abs(rowNorms - 1)), 1e-10, ...
                'L2 normalized rows should have unit norm');
        end

        function testConstantFeatureHandling(tc)
            %TESTCONSTANTFEATUREHANDLING Test handling of constant features.
            %   Verifies that constant columns don't cause division by zero.

            X = randn(100, 10);
            X(:, 3) = 5;  % Constant column
            X(:, 7) = -2;  % Another constant column

            % Z-score should handle constant features
            Xnorm = reg.normalize_features(X, 'Method', 'zscore');
            tc.verifyTrue(~any(isnan(Xnorm(:))), ...
                'Z-score should not produce NaN for constant features');
            tc.verifyTrue(~any(isinf(Xnorm(:))), ...
                'Z-score should not produce Inf for constant features');

            % Min-max should handle constant features
            Xnorm = reg.normalize_features(X, 'Method', 'minmax');
            tc.verifyTrue(~any(isnan(Xnorm(:))), ...
                'Min-max should not produce NaN for constant features');
            tc.verifyTrue(~any(isinf(Xnorm(:))), ...
                'Min-max should not produce Inf for constant features');
        end

        function testNaNHandling(tc)
            %TESTNANHANDLING Test handling of NaN values.
            %   Verifies graceful handling of missing data.

            X = randn(100, 10);
            X(5, 3) = NaN;
            X(20, 7) = NaN;

            try
                Xnorm = reg.normalize_features(X, 'Method', 'zscore', 'OmitNaN', true);
                % Should either remove NaNs or propagate them consistently
                tc.verifyEqual(size(Xnorm), size(X), ...
                    'Size should be preserved with NaN handling');
            catch ME
                % Should throw informative error
                tc.verifyTrue(contains(ME.message, {'NaN', 'missing', 'invalid'}), ...
                    'Error message should mention NaN/missing data');
            end
        end

        function testInfHandling(tc)
            %TESTINFHANDLING Test handling of Inf values.
            %   Verifies graceful handling of extreme values.

            X = randn(100, 10);
            X(10, 4) = Inf;
            X(30, 8) = -Inf;

            try
                Xnorm = reg.normalize_features(X, 'Method', 'zscore');
                % Should either handle or reject Inf values
                tc.verifyTrue(ismatrix(Xnorm), ...
                    'Should return a matrix');
            catch ME
                % Should throw informative error
                tc.verifyTrue(contains(ME.message, {'Inf', 'infinite', 'invalid'}), ...
                    'Error message should mention Inf values');
            end
        end

        function testEmptyInput(tc)
            %TESTEMPTYINPUT Test handling of empty input.
            %   Verifies graceful handling of empty matrices.

            X = zeros(0, 10);  % Empty matrix

            Xnorm = reg.normalize_features(X, 'Method', 'zscore');
            tc.verifyEqual(size(Xnorm), size(X), ...
                'Empty input should produce empty output');

            X = zeros(100, 0);  % No features
            Xnorm = reg.normalize_features(X, 'Method', 'zscore');
            tc.verifyEqual(size(Xnorm), size(X), ...
                'Zero features should be handled');
        end

        function testSingleSample(tc)
            %TESTSINGLESAMPLE Test normalization with single sample.
            %   Verifies handling when N=1.

            X = randn(1, 50);

            % Z-score with single sample is undefined (std=0)
            try
                Xnorm = reg.normalize_features(X, 'Method', 'zscore');
                % Should either handle gracefully or throw error
                tc.verifyEqual(size(Xnorm, 1), 1, ...
                    'Should have one row');
            catch ME
                tc.verifyTrue(contains(ME.message, {'sample', 'insufficient', 'std'}), ...
                    'Error should mention insufficient samples');
            end

            % Min-max with single sample is also undefined (range=0)
            Xnorm = reg.normalize_features(X, 'Method', 'minmax');
            tc.verifyEqual(size(Xnorm), size(X), ...
                'Min-max should handle single sample');
        end

        function testNormalizationReversible(tc)
            %TESTNORMALIZATIONREVERSIBLE Test that normalization can be reversed.
            %   Verifies that statistics can be saved and applied to test data.

            Xtrain = randn(100, 20) * 5 + 10;
            Xtest = randn(50, 20) * 5 + 10;

            % Normalize train and get statistics
            [XtrainNorm, stats] = reg.normalize_features(Xtrain, 'Method', 'zscore');

            % Apply same statistics to test set
            XtestNorm = reg.normalize_features(Xtest, 'Method', 'zscore', 'Stats', stats);

            % Test set should have similar (but not exact) properties
            testMean = mean(XtestNorm, 1);
            testStd = std(XtestNorm, 0, 1);

            % Test mean should be close to 0 (within reasonable tolerance)
            tc.verifyLessThan(max(abs(testMean)), 0.5, ...
                'Test set mean should be reasonably close to 0');
            % Test std should be close to 1
            tc.verifyLessThan(max(abs(testStd - 1)), 0.5, ...
                'Test set std should be reasonably close to 1');
        end

        function testSparseMatrixSupport(tc)
            %TESTSPARSEMATRIXSUPPORT Test normalization of sparse matrices.
            %   Verifies that sparse matrices are handled efficiently.

            X = sprand(1000, 100, 0.1);  % 10% density sparse matrix

            try
                Xnorm = reg.normalize_features(X, 'Method', 'zscore');
                tc.verifyEqual(size(Xnorm), size(X), ...
                    'Sparse matrix size should be preserved');
                % Check if still sparse (optional, depends on implementation)
            catch ME
                % If sparse not supported, error should be informative
                tc.verifyTrue(contains(ME.message, {'sparse', 'full', 'dense'}), ...
                    'Error should mention sparse matrix limitation');
            end
        end
    end
end
