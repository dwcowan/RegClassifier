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

        function run(obj, goldDir, metricsCSV) %#ok<INUSD>
            %RUN Execute evaluation workflow and render report.
            %   Should evaluate a gold pack, plot historical trends, generate
            %   a co-retrieval heatmap and display a summary report.
            %   Legacy mapping:
            %       Step 1 ↔ `reg_eval_gold`
            %       Step 2 ↔ `plot_trends`
            %       Step 3 ↔ `plot_coretrieval_heatmap`
            %   Pseudocode:
            %       1. results = Controller.evaluateGoldPack(goldDir)
            %       2. trendsPNG = VisualizationModel.plotTrends(metricsCSV)
            %       3. heatPNG = VisualizationModel.plotCoRetrievalHeatmap(...)
            %       4. View.display(struct(...))
            error("reg:controller:NotImplemented", ...
                "EvaluationPipeline.run is not implemented.");
        end
    end
end
