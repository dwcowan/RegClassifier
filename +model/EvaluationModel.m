classdef EvaluationModel < reg.mvc.BaseModel
    %EVALUATIONMODEL Compute evaluation metrics for model outputs.

    properties
        ConfigModel reg.model.ConfigModel
    end

    methods
        function obj = EvaluationModel(cfgModel)
            if nargin > 0
                obj.ConfigModel = cfgModel;
            end
        end

        function input = load(~, varargin)
            %LOAD Package predictions and references for evaluation.
            pred = [];
            ref = [];
            if numel(varargin) >= 1
                pred = varargin{1};
            end
            if numel(varargin) >= 2
                ref = varargin{2};
            end
            input = reg.service.EvaluationInput(pred, ref);
        end

        function result = process(obj, input) %#ok<INUSD>
            %PROCESS Calculate evaluation metrics from INPUT.
            if ~isempty(obj.ConfigModel)
                cfgRaw = obj.ConfigModel.load();
                cfg = obj.ConfigModel.process(cfgRaw); %#ok<NASGU>
            end
            result = reg.service.EvaluationResult([]);
            error("reg:model:NotImplemented", ...
                "EvaluationModel.process is not implemented.");
        end
    end
end
