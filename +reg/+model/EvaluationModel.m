classdef EvaluationModel < reg.mvc.BaseModel
    %EVALUATIONMODEL Stub model computing evaluation metrics.

    properties
        % Evaluation configuration
        config
    end

    methods
        function obj = EvaluationModel(config)
            %EVALUATIONMODEL Construct evaluation model.
            %   OBJ = EVALUATIONMODEL(config) stores evaluation options.
            %   Equivalent to setup in `eval_retrieval`.
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            %LOAD Gather data required for evaluation.
            %   INPUTS = LOAD(obj) retrieves prediction and gold labels.
            %   Equivalent to `eval_retrieval` data loading.
            error("reg:model:NotImplemented", ...
                "EvaluationModel.load is not implemented.");
        end
        function metrics = process(~, inputs) %#ok<INUSD>
            %PROCESS Compute evaluation metrics.
            %   METRICS = PROCESS(obj, inputs) returns a struct of scores.
            %   Equivalent to `eval_retrieval`.
            error("reg:model:NotImplemented", ...
                "EvaluationModel.process is not implemented.");
        end
    end
end
