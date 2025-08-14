classdef EvaluationController < handle
    %EVALUATIONCONTROLLER Provide utilities for evaluation and reporting.
    %   This controller bundles common evaluation routines used across the
    %   project such as retrieval metrics, gold-pack evaluation, trend
    %   plotting and co-retrieval heatmap generation.

    methods
        function metrics = retrievalMetrics(~, embeddings, posSets, k)
            %RETRIEVALMETRICS Compute retrieval metrics at K.
            %   metrics = retrievalMetrics(embeddings, posSets, k) returns a
            %   struct with RecallAtK, mAP and nDCG computed from the
            %   provided embeddings and positive sets. K defaults to 10.
            if nargin < 4, k = 10; end
            [recallAtK, mAP] = reg.eval_retrieval(embeddings, posSets, k);
            ndcgAtK = reg.metrics_ndcg(embeddings*embeddings.', posSets, k);
            metrics = struct('RecallAtK', recallAtK, 'mAP', mAP, 'nDCG', ndcgAtK);
        end

        function results = evaluateGoldPack(obj, goldDir)
            %EVALUATEGOLDPACK Run evaluation against a gold mini-pack.
            %   results = evaluateGoldPack(goldDir) loads the gold
            %   artefacts, embeds the chunks and computes retrieval metrics
            %   overall and per label.
            G = reg.load_gold(goldDir);
            C = config(); C.labels = G.labels;
            E = reg.precompute_embeddings(G.chunks.text, C);
            posSets = cell(height(G.chunks),1);
            for i = 1:height(G.chunks)
                labs = G.Y(i,:);
                pos = find(any(G.Y(:,labs),2)); pos(pos==i) = [];
                posSets{i} = pos;
            end
            overall = obj.retrievalMetrics(E, posSets, 10);
            per = reg.eval_per_label(E, G.Y, 10);
            perTbl = table(G.labels(:), per.RecallAtK, ...
                'VariableNames', {'Label','RecallAt10'});
            results = struct('overall', overall, 'perLabel', perTbl);
        end

        function plotTrends(~, csvPath, pngPath)
            %PLOTTRENDS Generate trend plots from a metrics CSV history.
            reg.plot_trends(csvPath, pngPath);
        end

        function plotCoRetrievalHeatmap(~, embeddings, labelMatrix, pngPath, labels)
            %PLOTCORETRIEVALHEATMAP Create a heatmap of label co-retrieval.
            [M, order] = reg.label_coretrieval_matrix(embeddings, labelMatrix, 10);
            reg.plot_coretrieval_heatmap(M(order,order), string(labels(order)), pngPath);
        end
    end
end
