classdef EvaluationPipeline < handle
    %EVALUATIONPIPELINE Orchestrate evaluation steps using EvaluationController.

    properties
        Controller
        View
    end

    methods
        function obj = EvaluationPipeline(controller, view)
            %EVALUATIONPIPELINE Construct pipeline with controller and view.
            %   OBJ = EVALUATIONPIPELINE(controller, view) wraps an
            %   EvaluationController and a view. Equivalent to setup in
            %   `reg_eval_and_report`.
            obj.Controller = controller;
            obj.View = view;
        end

        function run(obj, goldDir, metricsCSV)
            %RUN Execute evaluation workflow and render report.
            %   RUN(obj, goldDir, metricsCSV) evaluates a gold pack, plots
            %   trends and heatmaps, then displays a report. Equivalent to
            %   `reg_eval_and_report`.
            if nargin < 2, goldDir = 'gold'; end

            % Gold pack evaluation and retrieval metrics
            goldRes = obj.Controller.evaluateGoldPack(goldDir);
            metrics = goldRes.overall;

            % Trend plotting if history provided
            trendsPNG = '';
            if nargin >= 3 && ~isempty(metricsCSV) && isfile(metricsCSV)
                trendsPNG = fullfile(tempdir, 'trends.png');
                obj.Controller.plotTrends(metricsCSV, trendsPNG);
            end

            % Co-retrieval heatmap using gold embeddings
            G = reg.load_gold(goldDir);
            C = config(); C.labels = G.labels;
            E = reg.precompute_embeddings(G.chunks.text, C);
            heatPNG = fullfile(tempdir, 'coretrieval_heatmap.png');
            obj.Controller.plotCoRetrievalHeatmap(E, G.Y, heatPNG, G.labels);

            report = struct('summaryTables', metrics, ...
                            'irbSubset', [], ...
                            'trendCharts', trendsPNG, ...
                            'heatmap', heatPNG, ...
                            'gold', goldRes);
            obj.View.display(report);
        end
    end
end
