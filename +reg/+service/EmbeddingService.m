classdef EmbeddingService
    %EMBEDDINGSERVICE Generate dense embeddings from feature data.
    %   Encapsulates embedding backends previously modeled via
    %   EmbeddingModel.

    properties
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = EmbeddingService(cfg)
            %EMBEDDINGSERVICE Construct embedding service with config.
            if nargin > 0
                obj.cfg = cfg;
            end
        end

        function featureData = prepare(~, features) %#ok<INUSD>
            %PREPARE Adapt features for embedding computation.
            %   FEATUREDATA = PREPARE(FEATURES) readies sparse features for
            %   the embedding backend.
            error("reg:service:NotImplemented", ...
                "EmbeddingService.prepare is not implemented.");
        end

        function embeddings = embed(~, featureData) %#ok<INUSD>
            %EMBED Produce dense vectors from FEATUREDATA.
            %   EMBEDDINGS = EMBED(FEATUREDATA) should return an array of
            %   `reg.model.Embedding` instances.
            error("reg:service:NotImplemented", ...
                "EmbeddingService.embed is not implemented.");
        end
    end
end
