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
            %   Evaluates a gold pack, plots historical trends and generates
            %   a co-retrieval heatmap before displaying a summary report.
            %
            %   Preconditions
            %       * goldDir contains gold chunk/label artefacts
            %   Side Effects
            %       * Temporary PNGs written to system temp directory
            %       * Report struct dispatched to view
            %
            %   Legacy mapping:
            %       Step 1 ↔ `reg_eval_gold`
            %       Step 2 ↔ `plot_trends`
            %       Step 3 ↔ `plot_coretrieval_heatmap`

            if nargin < 2, goldDir = 'gold'; end

            % Step 1: evaluate gold pack and compute retrieval metrics,
            %   per-label recall and optional clustering quality.
            %   Controller should validate goldDir contents and report
            %   missing files.
            goldRes = obj.Controller.evaluateGoldPack(goldDir);
            metrics = goldRes.overall;

            % Step 2: plot metric trends if history provided
            %   Trend plotting should ignore malformed CSVs with warnings.
            trendsPNG = '';
            if nargin >= 3 && ~isempty(metricsCSV) && isfile(metricsCSV)
                trendsPNG = fullfile(tempdir, 'trends.png');
                obj.Controller.VisualizationModel.plotTrends(metricsCSV, trendsPNG);
            end

            % Step 3: generate co-retrieval heatmap using gold embeddings
            %   Any embedding errors should bubble up for visibility.
            G = reg.load_gold(goldDir);
            C = config(); C.labels = G.labels;
            E = reg.precompute_embeddings(G.chunks.text, C);
            heatPNG = fullfile(tempdir, 'coretrieval_heatmap.png');
            obj.Controller.VisualizationModel.plotCoRetrievalHeatmap(E, G.Y, heatPNG, G.labels);

            % Step 4: assemble report struct and forward to view
            irbSubset = goldRes.perLabel;  % placeholder for IRB-specific slice
            report = struct('summaryTables', metrics, ...
                            'irbSubset', irbSubset, ...
                            'trendCharts', trendsPNG, ...
                            'heatmap', heatPNG, ...
                            'gold', goldRes);
            obj.View.display(report);
        end
    end
end
