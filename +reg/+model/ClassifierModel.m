classdef ClassifierModel < reg.mvc.BaseModel
    %CLASSIFIERMODEL Stub model training classifiers and predicting labels.

    properties
        % Structure containing classifier configuration
        config
    end

    methods
        function obj = ClassifierModel(config)
            %CLASSIFIERMODEL Construct classifier model.
            %   OBJ = CLASSIFIERMODEL(config) sets classifier parameters.
            %   Equivalent to initialization in `predict_multilabel`.
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            %LOAD Prepare data for classifier training.
            %   INPUTS = LOAD(obj, ...) returns structures required for
            %   training. Equivalent to `train_multilabel` data loading.
            error("reg:model:NotImplemented", ...
                "ClassifierModel.load is not implemented.");
        end
        function [models, scores, thresholds, pred] = process(~, inputs) %#ok<INUSD>
            %PROCESS Train classifiers and generate predictions.
            %   [MODELS,SCORES,THRESHOLDS,PRED] = PROCESS(obj, inputs)
            %   produces classifier outputs. Equivalent to
            %   `predict_multilabel`.
            error("reg:model:NotImplemented", ...
                "ClassifierModel.process is not implemented.");
        end
    end
end
