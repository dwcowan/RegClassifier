classdef EvaluationModel < reg.mvc.BaseModel
    %EVALUATIONMODEL Stub model computing evaluation metrics.

    properties
        % Evaluation configuration
        config
    end

    methods
        function obj = EvaluationModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "EvaluationModel.load is not implemented.");
        end
        function metrics = process(~, inputs) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "EvaluationModel.process is not implemented.");
        end
    end
end
