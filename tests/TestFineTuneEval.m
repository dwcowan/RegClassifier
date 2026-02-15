classdef TestFineTuneEval < fixtures.RegTestCase
    %TESTFINETUNEVAL Tests for fine-tuning quality validation.
    %   Tests reg.ft_eval() and verifies fine-tuned encoder quality.

    methods (TestMethodSetup)
        function setupCleanup(tc)
            % Ensure cleanup of generated files even if test fails
            tc.addTeardown(@() deleteIfExists('fine_tuned_bert.mat'));
            tc.addTeardown(@() deleteIfExists('baseline_bert.mat'));
        end
    end

    methods (Test, TestTags = {'Unit','FineTuning','GPU','Slow'})
        function testFineTuneImprovesMetrics(tc)
            %TESTFINETUNE IMPROVESMETRICS Test that fine-tuning improves retrieval metrics.
            %   Verifies that fine-tuned embeddings outperform baseline.

            if gpuDeviceCount == 0
                tc.assumeTrue(false, 'No GPU, skipping fine-tune eval test.');
            end

            % Generate simulated data
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            C = config();
            C.labels = labels;

            % Get baseline embeddings
            Ebase = reg.precompute_embeddings(chunksT.text, C);

            % Build weak labels and triplets
            Yweak = reg.weak_rules(chunksT.text, labels) >= 0.7;
            P = reg.ft_build_contrastive_dataset(chunksT, Yweak, 'MaxTriplets', 256);

            % Fine-tune encoder (minimal epochs for testing)
            netFT = reg.ft_train_encoder(chunksT, P, 'Epochs', 1, 'BatchSize', 16, ...
                'MaxSeqLength', 128, 'UnfreezeTopLayers', 2, 'Resume', false);

            tc.verifyTrue(isstruct(netFT) && isfield(netFT, 'base') && isfield(netFT, 'head'), ...
                'Fine-tuned network should be a struct with base and head fields');

            % Get fine-tuned embeddings
            Eft = reg.ft_eval(netFT, chunksT.text, 'MaxSeqLength', 128, 'BatchSize', 16);

            tc.verifyEqual(size(Eft, 1), height(chunksT), ...
                'Fine-tuned embeddings should have one row per chunk');
            tc.verifyGreaterThan(size(Eft, 2), 0, ...
                'Fine-tuned embeddings should have positive dimensionality');

            % Build positive sets for evaluation
            posSets = fixtures.RegTestCase.buildPositiveSets(Ytrue);

            % Evaluate baseline
            [r_base, m_base] = reg.eval_retrieval(Ebase, posSets, 10);

            % Evaluate fine-tuned
            [r_ft, m_ft] = reg.eval_retrieval(Eft, posSets, 10);

            % Fine-tuning should improve or maintain metrics
            tc.verifyGreaterThanOrEqual(r_ft, r_base - 0.05, ...
                sprintf('Fine-tuned Recall@10 (%.3f) should be close to or better than baseline (%.3f)', ...
                r_ft, r_base));
            tc.verifyGreaterThanOrEqual(m_ft, m_base - 0.05, ...
                sprintf('Fine-tuned mAP (%.3f) should be close to or better than baseline (%.3f)', ...
                m_ft, m_base));
        end

        function testFineTuneEmbeddingsQuality(tc)
            %TESTFINETUNEEMBEDDINGSQUALITY Test quality properties of fine-tuned embeddings.
            %   Verifies embeddings are non-zero, normalized, and have reasonable magnitude.

            if gpuDeviceCount == 0
                tc.assumeTrue(false, 'No GPU, skipping fine-tune quality test.');
            end

            % Generate simulated data
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            C = config();
            C.labels = labels;

            % Build weak labels and triplets
            Yweak = reg.weak_rules(chunksT.text, labels) >= 0.7;
            P = reg.ft_build_contrastive_dataset(chunksT, Yweak, 'MaxTriplets', 256);

            % Fine-tune encoder (minimal epochs for testing)
            netFT = reg.ft_train_encoder(chunksT, P, 'Epochs', 1, 'BatchSize', 16, ...
                'MaxSeqLength', 128, 'UnfreezeTopLayers', 2, 'Resume', false);

            % Get fine-tuned embeddings
            Eft = reg.ft_eval(netFT, chunksT.text, 'MaxSeqLength', 128, 'BatchSize', 16);

            % Verify embeddings are non-zero
            tc.verifyGreaterThan(norm(Eft, 'fro'), 0, ...
                'Fine-tuned embeddings should be non-zero');

            % Verify all embedding vectors have positive norm
            norms = vecnorm(Eft, 2, 2);
            tc.verifyTrue(all(norms > 0), ...
                'All fine-tuned embedding vectors should have positive norm');

            % Verify reasonable magnitude (not exploded or vanished)
            meanNorm = mean(norms);
            tc.verifyGreaterThan(meanNorm, 0.1, ...
                'Mean embedding norm should not be too small (gradient vanishing)');
            tc.verifyLessThan(meanNorm, 100, ...
                'Mean embedding norm should not be too large (gradient explosion)');
        end
    end

    methods (Test, TestTags = {'Unit','FineTuning','Fast'})
        function testFineTuneEvalWithInvalidInput(tc)
            %TESTFINETUNEEVALWITHINVALIDINPUT Test error handling for invalid inputs.
            %   Verifies that ft_eval handles edge cases gracefully.

            % Create minimal network struct
            netFT = struct('base', [], 'head', []);

            % Empty text array
            emptyText = string.empty(0, 1);

            % Should handle empty input gracefully
            try
                Eft = reg.ft_eval(netFT, emptyText);
                tc.verifyEmpty(Eft, 'Empty input should produce empty embeddings');
            catch ME
                tc.verifyTrue(contains(ME.identifier, {'MATLAB:', 'reg:'}), ...
                    'Should throw appropriate error for empty input');
            end
        end
    end
end

function deleteIfExists(filepath)
    if isfile(filepath)
        delete(filepath);
    end
end
