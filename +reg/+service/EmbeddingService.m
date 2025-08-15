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

        function input = prepare(~, features)
            %PREPARE Wrap raw FEATURES in an EmbeddingInput value object.
            %   INPUT = PREPARE(FEATURES) packages sparse features for the
            %   embedding backend while preserving value semantics.
            input = reg.service.EmbeddingInput(features);
        end

        function output = embed(~, input) %#ok<INUSD>
            %EMBED Produce dense vectors from INPUT.
            %   OUTPUT = EMBED(INPUT) should return an EmbeddingOutput
            %   containing an array of `reg.model.Embedding` instances.
            %#ok<NASGU>
            error("reg:service:NotImplemented", ...
                "EmbeddingService.embed is not implemented.");
            % output = reg.service.EmbeddingOutput([]);
        end
    end
end
