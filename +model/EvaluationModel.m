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
            %   INPUT = LOAD(~, PRED, REF) returns a struct with fields
            %   ``Predictions`` and ``References`` capturing the supplied
            %   arrays.
            pred = [];
            ref = [];
            if numel(varargin) >= 1
                pred = varargin{1};
            end
            if numel(varargin) >= 2
                ref = varargin{2};
            end
            input = struct('Predictions', pred, 'References', ref);
        end

        function result = process(obj, input) %#ok<INUSD>
            %PROCESS Calculate evaluation metrics from INPUT.
            %   RESULT = PROCESS(obj, INPUT) returns a struct containing a
            %   ``Metrics`` field with evaluation scores.
            if ~isempty(obj.ConfigModel)
                cfgRaw = obj.ConfigModel.load();
                cfg = obj.ConfigModel.process(cfgRaw); %#ok<NASGU>
            end
            result = struct('Metrics', []);
            error("reg:model:NotImplemented", ...
                "EvaluationModel.process is not implemented.");
        end
    end
end
