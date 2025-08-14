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
            %   RUN(obj) loads data, computes metrics, logs them and
            %   displays a report. Equivalent to `reg_eval_and_report`.
            evalRaw = obj.EvaluationModel.load(); %#ok<NASGU>
            metrics = obj.EvaluationModel.process([]); %#ok<NASGU>
            logRaw = obj.LoggingModel.load(); %#ok<NASGU>
            obj.LoggingModel.process([]);
            repRaw = obj.ReportModel.load(); %#ok<NASGU>
            reportData = obj.ReportModel.process([]); %#ok<NASGU>
            obj.View.display(reportData);
        end
    end
end
