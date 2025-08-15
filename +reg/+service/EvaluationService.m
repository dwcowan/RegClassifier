classdef EvaluationService
    %EVALUATIONSERVICE Compute evaluation metrics for model outputs.
    %   Centralizes logic previously in EvaluationModel.

    properties
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = EvaluationService(cfg)
            %EVALUATIONSERVICE Construct service with configuration.
            if nargin > 0
                obj.cfg = cfg;
            end
        end

        function inputs = prepare(~, varargin) %#ok<INUSD>
            %PREPARE Gather predictions and references for evaluation.
            error("reg:service:NotImplemented", ...
                "EvaluationService.prepare is not implemented.");
        end

        function metrics = compute(~, inputs) %#ok<INUSD>
            %COMPUTE Calculate evaluation metrics from INPUTS.
            error("reg:service:NotImplemented", ...
                "EvaluationService.compute is not implemented.");
        end
    end
end
