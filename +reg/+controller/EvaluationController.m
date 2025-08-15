classdef EvaluationController < reg.mvc.BaseController
    %EVALUATIONCONTROLLER Orchestrate evaluation, reporting and plotting.
    %   Combines the responsibilities of the former EvalController and
    %   EvaluationPipeline into a single controller.  It wires evaluation
    %   and report models to views and provides helpers to produce
    %   diagnostic plots.

    properties
        % Model computing evaluation metrics (stored in BaseController.Model)
        ReportModel
        PlotView
        VisualizationModel reg.model.VisualizationModel = reg.model.VisualizationModel();
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

            if nargin < 3 || isempty(view)
                view = reg.view.ReportView();
            end
            obj@reg.mvc.BaseController(evalModel, view);
            obj.ReportModel = reportModel;
            if nargin >= 4 && ~isempty(vizModel)
                obj.VisualizationModel = vizModel;
            end
            if nargin >= 5 && ~isempty(plotView)
                obj.PlotView = plotView;
            else
                obj.PlotView = reg.view.PlotView();
            end
            if nargin >= 6 && ~isempty(metricsView)
                obj.MetricsView = metricsView;
            end
        end

        function run(obj, goldDir, metricsCSV)
            %RUN Execute end-to-end evaluation workflow.
            %   RUN(obj, goldDir, metricsCSV) evaluates the contents of
            %   goldDir, logs metrics, renders reports and produces trend and
            %   co-retrieval plots.  This method subsumes the responsibilities
            %   of the legacy EvalController.run and EvaluationPipeline.run.

            % Step 1: evaluate gold pack and compute metrics
            results = obj.evaluateGoldPack(goldDir);

            % Step 2: generate report from metrics and display
            repRaw = obj.ReportModel.load(results.Metrics);
            reportData = obj.ReportModel.process(repRaw);
            if ~isempty(obj.View)
                obj.View.display(reportData);
            end

            % Step 3: create diagnostic plots
            trendsPNG = obj.VisualizationModel.plotTrends(
                metricsCSV, fullfile(tempdir(), 'trends.png'));

            coMatrix = [];
            labels = [];
            if isstruct(results)
                if isfield(results, 'embeddings') && isfield(results, 'labelMatrix')
                    try
                        [coMatrix, ~] = obj.Model.coRetrievalMatrix(
                            results.embeddings, results.labelMatrix, 10);
                    catch
                        coMatrix = [];
                    end
                end
                if isfield(results, 'labels'), labels = results.labels; end
            end
            heatPNG = obj.VisualizationModel.plotCoRetrievalHeatmap(
                coMatrix, fullfile(tempdir(), 'heatmap.png'), labels);

            % Step 4: hand off plots to plot view
            if ~isempty(obj.PlotView)
                obj.PlotView.display(struct(
                    'TrendsPNG', trendsPNG, ...
                    'HeatmapPNG', heatPNG));
            end
        end
        function metrics = retrievalMetrics(~, embeddings, posSets, k) %#ok<INUSD>
            %RETRIEVALMETRICS Compute retrieval metrics at K.
            %   METRICS = RETRIEVALMETRICS(embeddings, posSets, k) should
            %   produce Recall@K, mAP and nDCG scores for a set of embeddings
            %   and positive index sets.
            %   Legacy Reference
            %       Equivalent to `reg.eval_retrieval` and `reg.metrics_ndcg`.
            %   Pseudocode:
            %       1. For each query embedding compute similarity scores
            %       2. Derive recall, mAP and nDCG at K
            %       3. Return metrics struct
            error("reg:controller:NotImplemented", ...
                "EvaluationController.retrievalMetrics is not implemented.");
        end

        function results = evaluateGoldPack(obj, goldDir, opts) %#ok<INUSD>
            %EVALUATEGOLDPACK Run evaluation and assemble metrics.
            %   RESULTS = EVALUATEGOLDPACK(goldDir) loads evaluation inputs,
            %   computes metrics (overall, per-label and clustering) and logs
            %   them.  The returned struct combines evaluation outputs and a
            %   ``Metrics`` field for downstream processing.
            %
            %   Legacy mapping:
            %       Step 1  ↔ `eval_retrieval`
            %       Step 1a ↔ `eval_per_label`
            %       Step 1b ↔ `eval_clustering`
            %       Step 2  ↔ `log_metrics`

            % Step 1: load evaluation inputs and compute core metrics
            evalRaw = obj.Model.load(goldDir);
            evalResult = obj.Model.process(evalRaw);
            metrics = evalResult.Metrics;

            % Per-label evaluation via consolidated model
            try
                metrics.perLabel = obj.Model.perLabelMetrics(
                    evalResult.embeddings, evalResult.labelMatrix, 10);
            catch
                metrics.perLabel = [];
            end

            % Clustering evaluation via consolidated model
            try
                metrics.clustering = obj.Model.clusteringMetrics(
                    evalResult.embeddings, evalResult.labelMatrix, 10);
            catch
                metrics.clustering = [];
            end

            % Step 2: persist metrics using metrics view
            obj.MetricsView.log(metrics);

            % Return combined results including metrics for further reporting
            results = evalResult;
            results.Metrics = metrics;
        end
    end
end
