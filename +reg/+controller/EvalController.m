classdef EvalController < reg.mvc.BaseController
    %EVALCONTROLLER Orchestrates evaluation and reporting workflow.
    
    properties
        EvaluationModel
        LoggingModel
        ReportModel
    end
    
    methods
        function obj = EvalController(evalModel, logModel, reportModel, view)
            %EVALCONTROLLER Construct evaluation controller.
            %   OBJ = EVALCONTROLLER(evalModel, logModel, reportModel, view)
            %   wires the models to a view. Equivalent to
            %   `reg_eval_and_report` setup.
            obj@reg.mvc.BaseController(evalModel, view);
            obj.EvaluationModel = evalModel;
            obj.LoggingModel = logModel;
            obj.ReportModel = reportModel;
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
            %       Step 2 ↔ `log_metrics`
            %       Step 3 ↔ report generation in `reg_eval_and_report`

            % Step 1: load evaluation inputs and compute metrics
            evalRaw = obj.EvaluationModel.load();
            metrics = obj.EvaluationModel.process(evalRaw);  % `eval_retrieval`

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
