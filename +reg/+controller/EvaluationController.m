classdef EvaluationController < reg.mvc.BaseController
    %EVALUATIONCONTROLLER Orchestrate evaluation, reporting and plotting.
    %   Combines the responsibilities of the former EvalController and
    %   EvaluationPipeline into a single controller.  It wires evaluation
    %   and report models to views and provides helpers to produce
    %   diagnostic plots. Designed to ingest runtime-labelled data via
    %   ``RuntimeLabelModel``.

    properties
        % ReportModel (reg.model.ReportModel): transforms metrics into
        %   report-ready structures.  Fields produced should align with
        %   ReportModel.load/process contracts (chunks, scores, labels).
        ReportModel reg.model.ReportModel

        % PlotView (reg.view.PlotView): handles visual artefact display.
        PlotView reg.view.PlotView

        % VisualizationModel: generates diagnostic figures such as trends
        %   and co-retrieval heatmaps.
        VisualizationModel reg.model.VisualizationModel = reg.model.VisualizationModel();

        % MetricsView: logs scalar metrics; expected to support ``log`` and
        %   ``display`` methods accepting structs.
        MetricsView reg.view.MetricsView = reg.view.MetricsView();
    end

    methods
        function obj = EvaluationController(evalModel, reportModel, view, vizModel, plotView, metricsView)
            %EVALUATIONCONTROLLER Construct controller wiring models and views.
            %   evalModel     - model producing evaluation metrics
            %   reportModel   - model transforming metrics into report data
            %   view          - view displaying reportData (defaults to ReportView)
            %   vizModel      - model generating plots (optional)
            %   plotView      - view used for visualisations (optional)
            %   metricsView   - view used for logging metrics (optional)

            arguments
                evalModel
                reportModel
                view = reg.view.ReportView()
                vizModel = reg.model.VisualizationModel()
                plotView = reg.view.PlotView()
                metricsView = reg.view.MetricsView()
            end
            arguments (Output)
                obj reg.controller.EvaluationController
            end

            % Pseudocode wiring for models and views
            %   obj@reg.mvc.BaseController(evalModel, view);
            %   obj.ReportModel = reportModel;
            %   obj.VisualizationModel = vizModel;
            %   obj.PlotView = plotView;
            %   obj.MetricsView = metricsView;

            error("reg:controller:NotImplemented", ...
                "EvaluationController constructor is not implemented.");
        end

        function metrics = run(obj, embeddings, labelMatrix)
            %RUN Execute end-to-end evaluation workflow.
            %   METRICS = RUN(obj, EMBEDDINGS, LABELMATRIX) evaluates the
            %   supplied ``embeddings`` and optional ``labelMatrix``,
            %   generates reports and diagnostic plots and returns the
            %   computed metrics.  This method subsumes the responsibilities
            %   of the legacy ``EvalController.run`` and
            %   ``EvaluationPipeline.run``.

            arguments
                obj
                embeddings double
                labelMatrix double = []
            end
            arguments (Output)
                metrics struct
            end
            % Step 1: ingest runtime labels
            %   rlm   = reg.model.RuntimeLabelModel();
            %   cfg   = rlm.load(labelMatrix);
            %   lbls  = rlm.process(cfg);

            % Step 2: call evaluation model to compute metrics
            %   raw   = obj.Model.load(embeddings, lbls);
            %   eval  = obj.Model.process(raw);
            %   metrics = eval.Metrics;

            % Step 3: generate reports and diagnostic plots
            %   rep   = obj.ReportModel.process(obj.ReportModel.load(metrics));
            %   trends = obj.VisualizationModel.plotTrendsData(metrics);
            %   heatmap = obj.VisualizationModel.plotCoRetrievalHeatmap(...);

            % Step 4: forward artefacts to views
            %   obj.View.display(rep);
            %   obj.PlotView.plotTrends(trends);
            %   obj.PlotView.display(struct('HeatmapPNG', heatmap));

            % Placeholder implementation
            error("reg:controller:NotImplemented", ...
                "EvaluationController.run is not implemented.");
        end
        function metrics = retrievalMetrics(~, embeddings, posSets, k) %#ok<INUSD>
            %RETRIEVALMETRICS Compute retrieval metrics at K.
            %   METRICS = RETRIEVALMETRICS(embeddings, posSets, k) should
            %   produce Recall@K, mAP and nDCG scores for a set of embeddings
            %   and positive index sets.
            arguments
                ~
                embeddings double
                posSets cell
                k (1,1) double
            end
            arguments (Output)
                metrics struct
            end
            %   Legacy Reference
            %       Equivalent to `reg.eval_retrieval` and `reg.metrics_ndcg`.
            %   Pseudocode/Validation stub:
            %       assert(size(embeddings,1) == numel(posSets))
            error("reg:controller:NotImplemented", ...
                "EvaluationController.retrievalMetrics is not implemented.");
        end

        function results = evaluateLabelledData(obj, embeddings, labelMatrix, opts) %#ok<INUSD>
            %EVALUATELABELLEDDATA Run evaluation on runtime-labelled data.
            %   Placeholder illustrating the intended evaluation workflow.
            %   Evaluation Flow (pseudocode):
            %       rlm  = reg.model.RuntimeLabelModel();
            %       cfg  = rlm.load(labelMatrix);
            %       lbls = rlm.process(cfg);
            %       raw  = obj.Model.load(embeddings, lbls);
            %       eval = obj.Model.process(raw);
            %       results = eval;
            arguments
                obj
                embeddings double
                labelMatrix double = []
                opts struct = struct()
            end
            arguments (Output)
                results struct
            end

            error("reg:controller:NotImplemented", ...
                "EvaluationController.evaluateLabelledData is not implemented.");
        end
    end
end
