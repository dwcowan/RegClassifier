classdef TestMetricsExpectedJSON < RegTestCase
    methods (Test)
        function metrics_meet_expected(tc)
            testDir = fileparts(mfilename("fullpath"));
            fixturesDir = fullfile(testDir, "fixtures");
            tc.applyFixture(matlab.unittest.fixtures.PathFixture(fixturesDir));
            K = jsondecode(fileread(fullfile(fixturesDir, "expected_metrics.json")));
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            C = config(); C.labels = labels;
            E = reg.precompute_embeddings(chunksT.text, C);
            posSets = cell(height(chunksT),1);
            for i=1:height(chunksT)
                labs = Ytrue(i,:);
                pos = find(any(Ytrue(:,labs),2)); pos(pos==i) = [];
                posSets{i} = pos;
            end
            [recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
            ndcg10 = reg.metrics_ndcg(E*E.', posSets, 10);
            tc.verifyGreaterThan(recall10 + K.tolerance, K.RecallAt10_min);
            tc.verifyGreaterThan(mAP + K.tolerance, K.mAP_min);
            tc.verifyGreaterThan(ndcg10 + K.tolerance, K.("nDCG@10_min"));
        end
    end
end
