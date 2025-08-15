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

        function input = prepare(~, pred, ref)
            %PREPARE Package predictions and references for evaluation.
            %   INPUT = PREPARE(PRED, REF) returns an EvaluationInput value
            %   object which can later be handed to COMPUTE.
            input = reg.service.EvaluationInput(pred, ref);
        end

        function result = compute(~, input) %#ok<INUSD>
            %COMPUTE Calculate evaluation metrics from INPUT.
            %#ok<NASGU>
            error("reg:service:NotImplemented", ...
                "EvaluationService.compute is not implemented.");
            % result = reg.service.EvaluationResult([]);
        end
    end
end
