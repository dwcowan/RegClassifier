classdef FeatureModel < reg.mvc.BaseModel
    %FEATUREMODEL Stub model generating feature representations.

    properties
        % Feature extraction configuration
        config
    end

    methods
        function obj = FeatureModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function chunksT = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "FeatureModel.load is not implemented.");
        end
        function [features, embeddings, vocab] = process(~, chunksT) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "FeatureModel.process is not implemented.");
        end
    end
end
