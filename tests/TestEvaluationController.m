classdef TestEvaluationController < RegTestCase
    % Test the EvaluationController utility methods.

    methods (Test)
        function retrieval_metrics(tc)
            G = reg.load_gold('gold');
            C = config(); C.labels = G.labels;
            E = reg.precompute_embeddings(G.chunks.text, C);
            posSets = cell(height(G.chunks),1);
            for i = 1:height(G.chunks)
                labs = G.Y(i,:);
                pos = find(any(G.Y(:,labs),2)); pos(pos==i) = [];
                posSets{i} = pos;
            end
            ctrl = reg.controller.EvaluationController();
            metrics = ctrl.retrievalMetrics(E, posSets, 10);
            tc.verifyTrue(isfield(metrics, 'RecallAtK'));
            tc.verifyTrue(isfield(metrics, 'mAP'));
            tc.verifyTrue(isfield(metrics, 'nDCG'));
        end

        function gold_pack(tc)
            ctrl = reg.controller.EvaluationController();
            res = ctrl.evaluateGoldPack('gold');
            tc.verifyTrue(isfield(res, 'overall'));
            tc.verifyTrue(isfield(res, 'perLabel'));
        end

        function plotting(tc)
            ctrl = reg.controller.EvaluationController();
            % Trend plot
            csv = fullfile(tempdir, 'metrics.csv');
            T = table((1:3)', rand(3,1), 'VariableNames', {'Epoch','RecallAt10'});
            writetable(T, csv);
            png = fullfile(tempdir, 'trends.png');
            ctrl.plotTrends(csv, png);
            tc.verifyTrue(isfile(png));
            % Co-retrieval heatmap
            E = rand(5,4);
            Y = eye(5) > 0;
            png2 = fullfile(tempdir, 'heatmap.png');
            ctrl.plotCoRetrievalHeatmap(E, Y, png2, "A"+(0:4));
            tc.verifyTrue(isfile(png2));
        end
    end
end
