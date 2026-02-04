classdef TestUtilityFunctions < fixtures.RegTestCase
    %TESTUTILITYFUNCTIONS Tests for utility functions in +reg package.
    %   Tests set_seeds, validate_knobs, log_metrics, and other utility
    %   functions for correct behavior, error handling, and edge cases.

    methods (TestMethodSetup)
        function setupCleanup(tc)
            % Cleanup generated files
            tc.addTeardown(@() deleteFolderIfExists('runs'));
        end
    end

    methods (Test)
        function testSetSeedsStub(tc)
            %TESTSETSEEDSSTUB Test set_seeds stub function.
            %   Verifies that set_seeds accepts a seed and returns a struct.
            seed = 42;
            S = reg.set_seeds(seed);
            tc.verifyClass(S, 'struct', ...
                'set_seeds should return a struct');
            % Note: Current implementation is a stub, so just verify it doesn't crash
        end

        function testSetSeedsWithDifferentSeeds(tc)
            %TESTSETSEEDSWITHDIFFERENTSEEDS Test set_seeds with various inputs.
            %   Verifies function handles different seed values.
            seeds = [0, 1, 42, 12345, 999999];
            for s = seeds
                S = reg.set_seeds(s);
                tc.verifyClass(S, 'struct', ...
                    sprintf('set_seeds should handle seed=%d', s));
            end
        end

        function testValidateKnobsStub(tc)
            %TESTVALIDATEKNOBSSTUB Test validate_knobs stub function.
            %   Verifies that validate_knobs accepts a knobs struct without error.
            K = struct('BERT', struct('MiniBatchSize', 96, 'MaxSeqLength', 256));
            % Should not throw error
            reg.validate_knobs(K);
            tc.verifyTrue(true, 'validate_knobs should complete without error');
        end

        function testValidateKnobsWithComplexStruct(tc)
            %TESTVALIDATEKNOBSWITHCOMPLEXSTRUCT Test validate_knobs with full knobs.
            %   Verifies function handles complete knobs structure.
            K = struct(...
                'BERT', struct('MiniBatchSize', 96, 'MaxSeqLength', 256), ...
                'Projection', struct('ProjDim', 384, 'Epochs', 50, 'BatchSize', 768), ...
                'FineTune', struct('Loss', 'triplet', 'BatchSize', 32, 'Epochs', 5), ...
                'Chunk', struct('SizeTokens', 300, 'Overlap', 80));
            reg.validate_knobs(K);
            tc.verifyTrue(true, 'validate_knobs should handle complex knobs struct');
        end

        function testLogMetricsBasic(tc)
            %TESTLOGMETRICSBASIC Test basic metrics logging.
            %   Verifies that log_metrics creates CSV file and logs metrics correctly.
            runId = "test_run_001";
            variant = "baseline";
            metrics = struct('recallAt10', 0.85, 'mAP', 0.72, 'ndcg', 0.68);

            reg.log_metrics(runId, variant, metrics);

            % Verify file was created
            csvPath = fullfile("runs", "metrics.csv");
            tc.verifyTrue(isfile(csvPath), ...
                'log_metrics should create metrics.csv file');

            % Verify file contents
            content = fileread(csvPath);
            tc.verifyTrue(contains(content, 'timestamp'), ...
                'CSV should contain timestamp header');
            tc.verifyTrue(contains(content, 'run_id'), ...
                'CSV should contain run_id header');
            tc.verifyTrue(contains(content, runId), ...
                'CSV should contain the logged run ID');
            tc.verifyTrue(contains(content, variant), ...
                'CSV should contain the logged variant');
            tc.verifyTrue(contains(content, 'recallAt10'), ...
                'CSV should contain the metric name');
        end

        function testLogMetricsMultipleEntries(tc)
            %TESTLOGMETRICSMULTIPLEENTRIES Test logging multiple metrics runs.
            %   Verifies that multiple log_metrics calls append to CSV.
            runId1 = "test_run_001";
            metrics1 = struct('recallAt10', 0.80);

            runId2 = "test_run_002";
            metrics2 = struct('recallAt10', 0.85, 'mAP', 0.75);

            reg.log_metrics(runId1, "baseline", metrics1);
            reg.log_metrics(runId2, "projection", metrics2);

            % Verify both runs are in the file
            csvPath = fullfile("runs", "metrics.csv");
            content = fileread(csvPath);
            tc.verifyTrue(contains(content, runId1), ...
                'CSV should contain first run ID');
            tc.verifyTrue(contains(content, runId2), ...
                'CSV should contain second run ID');
            tc.verifyTrue(contains(content, "baseline"), ...
                'CSV should contain baseline variant');
            tc.verifyTrue(contains(content, "projection"), ...
                'CSV should contain projection variant');

            % Count lines to verify appending
            lines = splitlines(content);
            % Should have header + at least 3 metric rows (1 from run1, 2 from run2)
            tc.verifyGreaterThanOrEqual(numel(lines), 4, ...
                'CSV should have header plus metric rows');
        end

        function testLogMetricsWithEpoch(tc)
            %TESTLOGMETRICSWITHEPOCH Test logging metrics with epoch parameter.
            %   Verifies that optional Epoch parameter is logged correctly.
            runId = "test_run_003";
            variant = "finetuned";
            metrics = struct('loss', 0.15);

            reg.log_metrics(runId, variant, metrics, 'Epoch', 10);

            csvPath = fullfile("runs", "metrics.csv");
            content = fileread(csvPath);
            tc.verifyTrue(contains(content, "10"), ...
                'CSV should contain epoch number');
        end

        function testLogMetricsCreatesDirectory(tc)
            %TESTLOGMETRICSCREATESDIRECTORY Test that log_metrics creates runs dir.
            %   Verifies directory creation when it doesn't exist.
            % Ensure directory doesn't exist
            if isfolder('runs')
                rmdir('runs', 's');
            end

            runId = "test_run_004";
            metrics = struct('accuracy', 0.92);

            reg.log_metrics(runId, "baseline", metrics);

            tc.verifyTrue(isfolder('runs'), ...
                'log_metrics should create runs directory if it doesn''t exist');
        end

        function testLogMetricsWithEmptyMetrics(tc)
            %TESTLOGMETRICSWITHEMPTYMETRICS Test logging with empty metrics struct.
            %   Verifies graceful handling of empty metrics.
            runId = "test_run_005";
            metrics = struct();

            % Should handle empty struct without crashing
            reg.log_metrics(runId, "baseline", metrics);

            csvPath = fullfile("runs", "metrics.csv");
            tc.verifyTrue(isfile(csvPath), ...
                'log_metrics should create file even with empty metrics');
        end

        function testLogMetricsWithSpecialCharacters(tc)
            %TESTLOGMETRICSWITHSPECIALCHARACTERS Test logging with special chars.
            %   Verifies handling of special characters in run IDs and variants.
            runId = "test-run_2025-01-15";
            variant = "baseline-v2";
            metrics = struct('metric1', 0.5);

            reg.log_metrics(runId, variant, metrics);

            csvPath = fullfile("runs", "metrics.csv");
            content = fileread(csvPath);
            tc.verifyTrue(contains(content, runId), ...
                'CSV should handle run IDs with hyphens and underscores');
            tc.verifyTrue(contains(content, variant), ...
                'CSV should handle variants with hyphens');
        end

        function testLogMetricsWithMultipleMetricFields(tc)
            %TESTLOGMETRICSWITHMULTIPLEMETRICFIELDS Test logging many metrics.
            %   Verifies that all metric fields are logged as separate rows.
            runId = "test_run_006";
            variant = "comprehensive";
            metrics = struct(...
                'recallAt10', 0.85, ...
                'recallAt50', 0.92, ...
                'mAP', 0.78, ...
                'ndcg', 0.81, ...
                'f1', 0.73);

            reg.log_metrics(runId, variant, metrics);

            csvPath = fullfile("runs", "metrics.csv");
            content = fileread(csvPath);

            % Verify all metric names appear
            metricNames = {'recallAt10', 'recallAt50', 'mAP', 'ndcg', 'f1'};
            for i = 1:numel(metricNames)
                tc.verifyTrue(contains(content, metricNames{i}), ...
                    sprintf('CSV should contain metric %s', metricNames{i}));
            end

            % Count metric rows (should be 5 + header)
            lines = splitlines(content);
            nonEmptyLines = lines(strlength(lines) > 0);
            tc.verifyGreaterThanOrEqual(numel(nonEmptyLines), 6, ...
                'CSV should have header + 5 metric rows');
        end
    end
end

function deleteFolderIfExists(folderpath)
    if isfolder(folderpath)
        rmdir(folderpath, 's');
    end
end
