classdef (Abstract, SharedTestFixtures={ ...
    matlab.unittest.fixtures.PathFixture('..')}) ...
    RegTestCase < matlab.unittest.TestCase
    %REGTESTCASE Base class for RegClassifier test cases.
    %   Provides common setup, helper functions, and utilities for all tests.
    %   Uses SharedTestFixtures to add project root to path before test discovery.
    %
    %   The PathFixture adds '..' (project root) to MATLAB path so that +reg
    %   package and all dependencies are available during both test discovery
    %   and test execution phases.

    methods (Static)
        function ensureFixturePDF(targetDir, filename)
            %ENSUREFIXTUREPDF Copy fixture PDF to target directory.
            %   ENSUREFIXTUREPDF(targetDir, filename) copies the specified
            %   fixture PDF to the target directory, creating the directory
            %   if it doesn't exist.
            %
            %   Example:
            %       fixtures.RegTestCase.ensureFixturePDF('data/pdfs', 'sim_text.pdf');
            if nargin < 2
                filename = 'sim_text.pdf';
            end
            if ~isfolder(targetDir)
                mkdir(targetDir);
            end
            % Find fixture path relative to this class file's location
            classPath = fileparts(mfilename('fullpath', 'class'));
            % classPath is tests/+fixtures, so fixture PDFs are in same dir
            sourcePath = fullfile(classPath, filename);
            targetPath = fullfile(targetDir, filename);
            if ~isfile(targetPath)
                copyfile(sourcePath, targetPath);
            end
        end

        function posSets = buildPositiveSets(Ytrue)
            %BUILDPOSITIVESETS Build positive sets from label matrix.
            %   POSSETS = BUILDPOSITIVESETS(Ytrue) creates positive sets for
            %   retrieval evaluation. For each document i, posSets{i} contains
            %   indices of all documents that share at least one label with i,
            %   excluding i itself.
            %
            %   Input:
            %       Ytrue - NxL logical matrix of ground truth labels
            %
            %   Output:
            %       posSets - Cell array where posSets{i} = indices of positive examples
            %
            %   Example:
            %       Ytrue = [1 0 0; 1 1 0; 0 1 0; 0 0 1];
            %       posSets = fixtures.RegTestCase.buildPositiveSets(Ytrue);
            N = size(Ytrue, 1);
            posSets = cell(N, 1);
            for i = 1:N
                labs = find(Ytrue(i,:));  % Get indices of true labels
                if ~isempty(labs)
                    pos = find(any(Ytrue(:,labs), 2));
                    pos(pos == i) = [];
                    posSets{i} = pos;
                else
                    posSets{i} = [];  % No positive labels
                end
            end
        end

        function cleanupTestArtifacts(filePatterns)
            %CLEANUPTESTART IFACTS Delete test-generated files.
            %   CLEANUPTESTART IFACTS(filePatterns) deletes files matching
            %   the provided patterns. Useful for test cleanup.
            %
            %   Input:
            %       filePatterns - String array or cell array of file patterns
            %
            %   Example:
            %       fixtures.RegTestCase.cleanupTestArtifacts(["*.mat", "runs/"]);
            if nargin < 1
                filePatterns = ["fine_tuned_bert.mat", "projection_head.mat", ...
                    "classification_results.mat", "metrics.csv"];
            end
            for i = 1:numel(filePatterns)
                pattern = filePatterns(i);
                if endsWith(pattern, '/')
                    % Directory pattern
                    if isfolder(pattern)
                        rmdir(pattern, 's');
                    end
                else
                    % File pattern
                    files = dir(pattern);
                    for j = 1:numel(files)
                        if ~files(j).isdir
                            delete(fullfile(files(j).folder, files(j).name));
                        end
                    end
                end
            end
        end

        function [chunksT, labels, Ytrue] = generateSimulatedData(numChunks, numLabels)
            %GENERATESIMULATEDDATA Generate simulated chunks and labels for testing.
            %   [chunksT, labels, Ytrue] = GENERATESIMULATEDDATA(numChunks, numLabels)
            %   creates synthetic data for testing without requiring real PDFs.
            %
            %   Inputs:
            %       numChunks - Number of text chunks to generate (default: 20)
            %       numLabels - Number of labels (default: 5)
            %
            %   Outputs:
            %       chunksT - Table with chunk_id, doc_id, and text columns
            %       labels - String array of label names
            %       Ytrue - Logical matrix of ground truth labels
            %
            %   Example:
            %       [chunks, labels, Y] = fixtures.RegTestCase.generateSimulatedData(50, 8);
            if nargin < 1, numChunks = 20; end
            if nargin < 2, numLabels = 5; end

            % Generate chunk IDs and texts
            chunk_ids = "CHUNK_" + string(1:numChunks)';
            doc_ids = "DOC_" + string(ceil((1:numChunks) / 5))';  % 5 chunks per doc
            texts = "Simulated text chunk " + string(1:numChunks)';
            chunksT = table(chunk_ids, doc_ids, texts, ...
                'VariableNames', {'chunk_id', 'doc_id', 'text'});

            % Generate labels
            labelNames = ["Label" + string(1:numLabels)];
            labels = labelNames;

            % Generate random label matrix with some structure
            Ytrue = rand(numChunks, numLabels) > 0.7;  % ~30% positive rate
            % Ensure each chunk has at least one label
            for i = 1:numChunks
                if ~any(Ytrue(i,:))
                    Ytrue(i, randi(numLabels)) = true;
                end
            end
        end

        function cfg = getTestConfig()
            %GETTESTCONFIG Get configuration suitable for testing.
            %   CFG = GETTESTCONFIG() returns a configuration struct with
            %   test-friendly defaults (fast backends, small batch sizes).
            %
            %   Example:
            %       cfg = fixtures.RegTestCase.getTestConfig();
            cfg = config();
            % Override with test-friendly values
            if isfield(cfg, 'embeddings_backend')
                cfg.embeddings_backend = 'fasttext';  % Faster than BERT for tests
            end
            if isfield(cfg, 'BERT')
                cfg.BERT.MiniBatchSize = 16;  % Smaller for faster tests
            end
        end

        function assertMetricsInRange(tc, metrics, expectedRanges)
            %ASSERTMETRICSINRANGE Assert metrics fall within expected ranges.
            %   ASSERTMETRICSINRANGE(tc, metrics, expectedRanges) verifies
            %   that each metric in the metrics struct is within the bounds
            %   specified in expectedRanges.
            %
            %   Inputs:
            %       tc - Test case object
            %       metrics - Struct with metric fields (e.g., struct('recall', 0.85))
            %       expectedRanges - Struct with [min max] ranges for each metric
            %
            %   Example:
            %       metrics = struct('recall', 0.85, 'mAP', 0.72);
            %       ranges = struct('recall', [0.8 1.0], 'mAP', [0.6 1.0]);
            %       fixtures.RegTestCase.assertMetricsInRange(tc, metrics, ranges);
            metricNames = fieldnames(metrics);
            for i = 1:numel(metricNames)
                name = metricNames{i};
                if isfield(expectedRanges, name)
                    value = metrics.(name);
                    range = expectedRanges.(name);
                    tc.verifyGreaterThanOrEqual(value, range(1), ...
                        sprintf('%s should be >= %.3f', name, range(1)));
                    tc.verifyLessThanOrEqual(value, range(2), ...
                        sprintf('%s should be <= %.3f', name, range(2)));
                end
            end
        end
    end
end
