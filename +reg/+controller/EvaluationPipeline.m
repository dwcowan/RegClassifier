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
            %   The implementation is intentionally minimal and serves as a
            %   usage example for how the visualization model would be wired
            %   into a pipeline.
            %   Step 1  - evaluate a gold pack via the controller
            %   Step 2  - render historical trend plots
            %   Step 3  - create a co‑retrieval heatmap
            %   Step 4  - display aggregated results via the view

            % Step 1: evaluate gold pack (legacy `reg_eval_gold`)
            results = obj.Controller.evaluateGoldPack(goldDir);

            % Step 2: plot historical trends (legacy `plot_trends`)
            trendsPNG = obj.Controller.VisualizationModel.plotTrends(
                metricsCSV, fullfile(tempdir(), 'trends.png'));

            % Step 3: plot co‑retrieval heatmap (legacy
            % `plot_coretrieval_heatmap`)
            embeddings = [];
            labelMatrix = [];
            labels = [];
            if isstruct(results)
                if isfield(results, 'embeddings'), embeddings = results.embeddings; end
                if isfield(results, 'labelMatrix'), labelMatrix = results.labelMatrix; end
                if isfield(results, 'labels'), labels = results.labels; end
            end
            heatPNG = obj.Controller.VisualizationModel.plotCoRetrievalHeatmap(
                embeddings, labelMatrix, fullfile(tempdir(), 'heatmap.png'), labels);

            % Step 4: hand off to view for rendering
            obj.View.display(struct( ...
                'Evaluation', results, ...
                'TrendsPNG', trendsPNG, ...
                'HeatmapPNG', heatPNG));
        end
    end
end
