classdef EvalController < reg.mvc.BaseController
    %EVALCONTROLLER Orchestrates evaluation and reporting workflow.
    
    properties
        EvaluationModel
        LoggingModel
        ReportModel
    end
    
    methods
        function obj = EvalController(evalModel, logModel, reportModel, view)
            obj@reg.mvc.BaseController(evalModel, view);
            obj.EvaluationModel = evalModel;
            obj.LoggingModel = logModel;
            obj.ReportModel = reportModel;
        end
        
        function run(obj)
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
