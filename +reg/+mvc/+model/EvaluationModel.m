classdef EvaluationModel < reg.mvc.BaseModel
    %EVALUATIONMODEL Stub model computing evaluation metrics.
    
    methods
        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "EvaluationModel.load is not implemented.");
        end
        function metrics = process(~, inputs) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "EvaluationModel.process is not implemented.");
        end
    end
end
