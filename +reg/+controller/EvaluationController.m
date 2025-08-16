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

            % Step 1: ingest runtime labels and evaluate labelled data
            %   Using RuntimeLabelModel (pseudocode):
            %       rlm = reg.model.RuntimeLabelModel();
            %       cfg = rlm.load(labelMatrix);
            %       lbls = rlm.process(cfg);
            %       results = obj.evaluateLabelledData(embeddings, lbls);
            results = obj.evaluateLabelledData(embeddings, labelMatrix);

            % Step 2: generate report from metrics and display
            repRaw = obj.ReportModel.load(results.Metrics);
            reportData = obj.ReportModel.process(repRaw);
            if ~isempty(obj.View)
                obj.View.display(reportData);
            end

            % Step 3: create diagnostic plots
            metricsStruct = results.Metrics;
            obj.Model.validateMetrics(metricsStruct);
            trendsFig = obj.VisualizationModel.plotTrends(metricsStruct);

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
                    'TrendsFigure', trendsFig, ...
                    'HeatmapPNG', heatPNG));
            end

            % Return metrics for upstream consumers
            if isstruct(results) && isfield(results, 'Metrics')
                metrics = results.Metrics;
            else
                metrics = [];
            end
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
            %   Legacy Reference
            %       Equivalent to `reg.eval_retrieval` and `reg.metrics_ndcg`.
            %   Pseudocode/Validation stub:
            %       assert(size(embeddings,1) == numel(posSets))
            error("reg:controller:NotImplemented", ...
                "EvaluationController.retrievalMetrics is not implemented.");
        end

        function results = evaluateLabelledData(obj, embeddings, labelMatrix, opts) %#ok<INUSD>
            %EVALUATELABELLEDDATA Run evaluation on runtime-labelled data.
            %   RESULTS = EVALUATELABELLEDDATA(EMBEDDINGS, LABELMATRIX) ingests
            %   label information via ``RuntimeLabelModel`` and computes metrics.
            %   The returned ``results`` struct merges evaluation outputs with a
            %   ``Metrics`` field whose schema mirrors ``EvaluationModel.process``:
            %       - results.Metrics.accuracy   (:,1 double)
            %       - results.Metrics.loss       (:,1 double)
            %       - results.Metrics.perLabel   (table with ``LabelIdx``,
            %                                     ``RecallAtK`` and ``Support``)
            %       - results.Metrics.clustering (struct with ``purity``,
            %                                     ``silhouette`` and ``idx``)
            %       - results.Metrics.epochs     (:,1 double) optional
            %   Additional bookkeeping fields may also be present for plotting.
            %
            %   Evaluation Flow (pseudocode):
            %       rlm   = reg.model.RuntimeLabelModel();
            %       cfg   = rlm.load(labelMatrix);
            %       lbls  = rlm.process(cfg);
            %       raw   = obj.Model.load(embeddings, lbls);
            %       eval  = obj.Model.process(raw);
            %       metrics = eval.Metrics;
            arguments
                obj
                embeddings double
                labelMatrix double = []
                opts struct = struct()
            end

            % Step 1: load evaluation inputs and compute core metrics
            evalRaw = obj.Model.load(embeddings, labelMatrix);
            evalResult = obj.Model.process(evalRaw);
            metrics = evalResult.Metrics;
            % Pseudocode/validation stub:
            %   assert(isfield(metrics, 'accuracy') && iscolumn(metrics.accuracy));
            %   assert(isfield(metrics, 'loss') && iscolumn(metrics.loss));
            %   assert(isfield(metrics, 'perLabel') && istable(metrics.perLabel));
            %   assert(isfield(metrics, 'clustering') && isstruct(metrics.clustering));
            %   if isfield(metrics, 'epochs')
            %       assert(iscolumn(metrics.epochs));
            %       assert(numel(metrics.epochs) == numel(metrics.accuracy));
            %   end

            % Per-label evaluation via consolidated model
            try
                metrics.perLabel = obj.Model.perLabelMetrics(
                    embeddings, labelMatrix, 10);
            catch
                metrics.perLabel = [];
            end

            % Clustering evaluation via consolidated model
            try
                metrics.clustering = obj.Model.clusteringMetrics(
                    embeddings, labelMatrix, 10);
            catch
                metrics.clustering = [];
            end

            % Step 2: persist metrics using metrics view
            obj.MetricsView.log(metrics);

            % Return combined results including metrics for further reporting
            results = evalResult;
            results.Metrics = metrics;
            results.embeddings = embeddings;
            results.labelMatrix = labelMatrix;
        end
    end
end
