classdef EvalController < reg.mvc.BaseController
    %EVALCONTROLLER Orchestrates evaluation and reporting workflow.

    properties
        EvaluationModel
        LoggingModel
        ReportModel
        ClusteringEvalModel = []
        PerLabelEvalModel = []
    end

    methods
        function obj = EvalController(evalModel, logModel, reportModel, view, varargin)
            %EVALCONTROLLER Construct evaluation controller.
            %   OBJ = EVALCONTROLLER(evalModel, logModel, reportModel, view)
            %   wires the models to a view. Equivalent to
            %   `reg_eval_and_report` setup.
            %   Additional optional models:
            %       varargin{1} - clustering evaluation model
            %       varargin{2} - per-label evaluation model
            obj@reg.mvc.BaseController([], view);
            obj.EvaluationModel = evalModel;
            obj.LoggingModel = logModel;
            obj.ReportModel = reportModel;
            if numel(varargin) >= 1
                obj.ClusteringEvalModel = varargin{1};
            end
            if numel(varargin) >= 2
                obj.PerLabelEvalModel = varargin{2};
            end
        end

        function run(obj)
            %RUN Execute evaluation and reporting pipeline.
            %   RUN(obj) orchestrates metric computation, persistence and
            %   report rendering.
            %
            %   Preconditions
            %       * EvaluationModel supplies predictions and gold labels
            %       * LoggingModel has write access to metrics store
            %       * ReportModel expects a metrics struct
            %   Side Effects
            %       * Metrics appended to history (e.g., CSV)
            %       * Summary report displayed via associated view
            %
            %   Legacy mapping:
            %       Step 1 ↔ `eval_retrieval`
            %       Step 1a ↔ `eval_per_label`
            %       Step 1b ↔ `eval_clustering`
            %       Step 2 ↔ `log_metrics`
            %       Step 3 ↔ report generation in `reg_eval_and_report`

            % Step 1: load evaluation inputs and compute metrics
            evalRaw = obj.EvaluationModel.load();
            metrics = obj.EvaluationModel.process(evalRaw);  % `eval_retrieval`

            % Optional: per-label evaluation
            if ~isempty(obj.PerLabelEvalModel)
                perLabelRaw = obj.PerLabelEvalModel.load();
                perLabelMetrics = obj.PerLabelEvalModel.process(perLabelRaw);  % `eval_per_label`
                metrics.perLabel = perLabelMetrics;
            end

            % Optional: clustering evaluation
            if ~isempty(obj.ClusteringEvalModel)
                clusterRaw = obj.ClusteringEvalModel.load();
                clusterMetrics = obj.ClusteringEvalModel.process(clusterRaw);  % `eval_clustering`
                metrics.clustering = clusterMetrics;
            end

            % Step 2: persist metrics using logging model
            %   LoggingModel should validate schema and handle IO errors.
            logRaw = obj.LoggingModel.load(metrics);
            obj.LoggingModel.process(logRaw);  % `log_metrics`

            % Step 3: assemble and render report from metrics
            %   ReportModel is expected to verify metric fields.
            repRaw = obj.ReportModel.load(metrics);
            reportData = obj.ReportModel.process(repRaw);
            obj.View.display(reportData);
        end
    end
end
