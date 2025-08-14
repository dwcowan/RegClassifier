classdef ClassifierModel < reg.mvc.BaseModel
    %CLASSIFIERMODEL Stub model training classifiers and predicting labels.
    
    methods
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
