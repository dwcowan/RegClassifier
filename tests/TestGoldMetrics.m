classdef TestGoldMetrics < fixtures.RegTestCase
    %TESTGOLDMETRICS Regression test against gold mini-pack.
    %   Tests that retrieval metrics on the gold mini-pack meet minimum
    %   thresholds. Uses caching to avoid recomputing embeddings.

    properties (ClassSetupParameter)
    end

    properties
        % Cached data to avoid recomputing embeddings for each test
        GoldData
        GoldEmbeddings
        GoldPositiveSets
    end

    methods (TestClassSetup)
        function loadAndCacheGoldData(tc)
            %LOADANDCACHEGOLDDATA Load gold pack and precompute embeddings once.
            %   This setup runs once per test class, caching expensive operations.
            G = reg.load_gold("gold");
            C = config();
            C.labels = G.labels;

            % Cache gold data
            tc.GoldData = G;

            % Compute and cache embeddings (expensive operation)
            tc.GoldEmbeddings = reg.precompute_embeddings(G.chunks.text, C);

            % Compute and cache positive sets
            posSets = cell(height(G.chunks), 1);
            for i = 1:height(G.chunks)
                labs = G.Y(i,:);
                pos = find(any(G.Y(:,labs), 2));
                pos(pos == i) = [];
                posSets{i} = pos;
            end
            tc.GoldPositiveSets = posSets;
        end
    end

    methods (Test)
        function goldMeetsThresholds(tc)
            %GOLDMEETSTHRESHOLDS Test that gold pack metrics meet thresholds.
            %   Uses cached embeddings and positive sets for performance.
            G = tc.GoldData;
            E = tc.GoldEmbeddings;
            posSets = tc.GoldPositiveSets;

            % Compute overall metrics
            [recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
            ndcg10 = reg.metrics_ndcg(E*E.', posSets, 10);

            % Verify overall metrics meet thresholds
            tol = G.expect.overall.tolerance;
            tc.verifyGreaterThan(recall10 + tol, G.expect.overall.RecallAt10_min, ...
                sprintf('Recall@10 (%.3f) should exceed threshold (%.3f)', ...
                recall10, G.expect.overall.RecallAt10_min));
            tc.verifyGreaterThan(mAP + tol, G.expect.overall.mAP_min, ...
                sprintf('mAP (%.3f) should exceed threshold (%.3f)', ...
                mAP, G.expect.overall.mAP_min));
            tc.verifyGreaterThan(ndcg10 + tol, G.expect.overall.("nDCG@10_min"), ...
                sprintf('nDCG@10 (%.3f) should exceed threshold (%.3f)', ...
                ndcg10, G.expect.overall.("nDCG@10_min")));

            % Compute and verify per-label metrics
            per = reg.eval_per_label(E, G.Y, 10);
            labs = G.labels;
            for i = 1:numel(labs)
                lab = labs(i);
                if isfield(G.expect.per_label, lab)
                    tc.verifyGreaterThan(per.RecallAtK(i) + tol, G.expect.per_label.(lab), ...
                        sprintf('%s Recall@10 (%.3f) should exceed threshold (%.3f)', ...
                        lab, per.RecallAtK(i), G.expect.per_label.(lab)));
                end
            end
        end

        function goldDataStructure(tc)
            %GOLDDATASTRUCTURE Test gold pack data structure.
            %   Verifies that gold pack has required fields and correct structure.
            G = tc.GoldData;

            tc.verifyTrue(isfield(G, 'chunks'), ...
                'Gold pack should have chunks field');
            tc.verifyTrue(isfield(G, 'labels'), ...
                'Gold pack should have labels field');
            tc.verifyTrue(isfield(G, 'Y'), ...
                'Gold pack should have Y (label matrix) field');
            tc.verifyTrue(isfield(G, 'expect'), ...
                'Gold pack should have expect (expectations) field');

            % Verify data consistency
            tc.verifyEqual(size(G.Y, 1), height(G.chunks), ...
                'Label matrix rows should match number of chunks');
            tc.verifyEqual(size(G.Y, 2), numel(G.labels), ...
                'Label matrix columns should match number of labels');
        end

        function goldEmbeddingsQuality(tc)
            %GOLDEMBEDDINGSQUALITY Test quality of cached embeddings.
            %   Verifies that embeddings have expected properties.
            E = tc.GoldEmbeddings;
            G = tc.GoldData;

            tc.verifyEqual(size(E, 1), height(G.chunks), ...
                'Should have one embedding per chunk');
            tc.verifyGreaterThan(size(E, 2), 0, ...
                'Embeddings should have positive dimensionality');

            % Verify embeddings are not all zeros
            tc.verifyGreaterThan(norm(E, 'fro'), 0, ...
                'Embeddings should be non-zero');

            % Verify embeddings have reasonable magnitude
            norms = vecnorm(E, 2, 2);
            tc.verifyTrue(all(norms > 0), ...
                'All embedding vectors should have positive norm');
        end
    end
end
