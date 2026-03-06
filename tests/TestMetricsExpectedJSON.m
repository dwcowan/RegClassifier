classdef TestMetricsExpectedJSON < fixtures.RegTestCase
    methods (Test)
        function metrics_meet_expected(tc)
            testDir = fileparts(mfilename("fullpath"));
            fixturesDir = fullfile(testDir, "+fixtures");
            tc.applyFixture(matlab.unittest.fixtures.PathFixture(fixturesDir));
            K = jsondecode(fileread(fullfile(fixturesDir, "expected_metrics.json")));
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            C = config(); C.labels = labels;
            E = reg.precompute_embeddings(chunksT.text, C);
            posSets = fixtures.RegTestCase.buildPositiveSets(Ytrue);
            [recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
            ndcg10 = reg.metrics_ndcg(E*E.', posSets, 10);
            tc.verifyGreaterThan(recall10 + K.tolerance, K.RecallAt10_min);
            tc.verifyGreaterThan(mAP + K.tolerance, K.mAP_min);
            % jsondecode converts "nDCG@10_min" to "nDCGx0x4010_min"
            fnames = fieldnames(K);
            ndcgFields = fnames(contains(fnames, 'nDCG'));
            tc.verifyNotEmpty(ndcgFields, ...
                'expected_metrics.json should contain an nDCG threshold field');
            tc.verifyGreaterThan(ndcg10 + K.tolerance, K.(ndcgFields{1}));
        end
    end
end
