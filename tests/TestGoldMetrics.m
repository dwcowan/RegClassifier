classdef TestGoldMetrics < matlab.unittest.TestCase
    methods (Test)
        function gold_meets_thresholds(tc)
            G = reg.load_gold("gold");
            C = config(); C.labels = G.labels;
            E = reg.precompute_embeddings(G.chunks.text, C);
            % overall metrics
            posSets = cell(height(G.chunks),1);
            for i=1:height(G.chunks)
                labs = G.Y(i,:);
                pos = find(any(G.Y(:,labs),2)); pos(pos==i) = [];
                posSets{i} = pos;
            end
            [recall10, mAP] = reg.eval_retrieval(E, posSets, 10);
            ndcg10 = reg.metrics_ndcg(E*E.', posSets, 10);
            tol = G.expect.overall.tolerance;
            tc.verifyGreaterThan(recall10 + tol, G.expect.overall.RecallAt10_min);
            tc.verifyGreaterThan(mAP + tol, G.expect.overall.mAP_min);
            tc.verifyGreaterThan(ndcg10 + tol, G.expect.overall["nDCG@10_min"]);
            % per-label
            per = reg.eval_per_label(E, G.Y, 10);
            labs = G.labels;
            for i=1:numel(labs)
                lab = labs(i);
                if isfield(G.expect.per_label, lab)
                    tc.verifyGreaterThan(per.RecallAtK(i) + tol, G.expect.per_label.(lab));
                end
            end
        end
    end
end
