classdef ClassifierModel < reg.mvc.BaseModel
    %CLASSIFIERMODEL Stub model training classifiers and predicting labels.

    properties
        % Structure containing classifier configuration
        config
    end

    methods
        function obj = ClassifierModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ClassifierModel.load is not implemented.");
        end
        function [models, scores, thresholds, pred] = process(~, inputs) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ClassifierModel.process is not implemented.");
        end
    end
end
