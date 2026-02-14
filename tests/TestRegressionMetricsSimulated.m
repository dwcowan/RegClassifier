classdef TestRegressionMetricsSimulated < fixtures.RegTestCase
    methods (Test)
        function regression_metrics(tc)
            [chunksT, labels, Ytrue] = testutil.generate_simulated_crr();
            C = config(); C.labels = labels;
            E = reg.precompute_embeddings(chunksT.text, C);
            % Build posSets from Ytrue
            posSets = cell(height(chunksT),1);
            for i=1:height(chunksT)
                labs = Ytrue(i,:);
                pos = find(any(Ytrue(:,labs),2)); pos(pos==i) = [];
                posSets{i} = pos;
            end
            [recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
            ndcg10 = reg.metrics_ndcg(E*E.', posSets, 10);
            % Lower thresholds for fastText on synthetic data (BERT achieves higher)
            tc.verifyGreaterThan(recall10, 0.3);
            tc.verifyGreaterThan(mAP, 0.2);
            tc.verifyGreaterThan(ndcg10, 0.2);
        end
    end
end
