classdef FeatureModel < reg.mvc.BaseModel
    %FEATUREMODEL Stub model generating feature representations.

    properties
        % Feature extraction configuration
        config
    end

    methods
        function obj = FeatureModel(config)
            %FEATUREMODEL Construct feature extraction model.
            %   OBJ = FEATUREMODEL(config) stores parameters for feature
            %   generation. Equivalent to initialization in
            %   `precompute_embeddings`.
            if nargin > 0
                obj.config = config;
            end
        end

        function chunksT = load(~, varargin) %#ok<INUSD>
            %LOAD Retrieve text chunks for feature extraction.
            %   CHUNKST = LOAD(obj) returns a table of text segments.
            %   Equivalent to `precompute_embeddings` input gathering.
            error("reg:model:NotImplemented", ...
                "FeatureModel.load is not implemented.");
        end
        function [features, embeddings, vocab] = process(~, chunksT) %#ok<INUSD>
            %PROCESS Generate features and embeddings.
            %   [FEATURES, EMBEDDINGS, VOCAB] = PROCESS(obj, chunksT) returns
            %   numerical representations. Equivalent to
            %   `precompute_embeddings`.
            error("reg:model:NotImplemented", ...
                "FeatureModel.process is not implemented.");
        end
    end
end
