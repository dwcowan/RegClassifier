classdef EmbeddingService
    %EMBEDDINGSERVICE Generate dense embeddings from feature data.
    %   Encapsulates embedding backends previously modeled via
    %   EmbeddingModel.

    properties
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
        EmbeddingRepo reg.repository.EmbeddingRepository
        SearchRepo reg.repository.SearchIndexRepository
    end

    methods
        function obj = EmbeddingService(cfg, embeddingRepo, searchRepo)
            %EMBEDDINGSERVICE Construct embedding service with dependencies.
            if nargin > 0
                obj.cfg = cfg;
            end
            if nargin > 1
                obj.EmbeddingRepo = embeddingRepo;
            end
            if nargin > 2
                obj.SearchRepo = searchRepo;
            end
        end

        function input = prepare(~, features)
            %PREPARE Wrap raw FEATURES in an EmbeddingInput value object.
            %   INPUT = PREPARE(FEATURES) packages sparse features for the
            %   embedding backend while preserving value semantics.
            input = reg.service.EmbeddingInput(features);
        end

        function output = embed(obj, input) %#ok<INUSD>
            %EMBED Produce dense vectors from INPUT.
            %   OUTPUT = EMBED(INPUT) should return an EmbeddingOutput
            %   containing an array of `reg.model.Embedding` instances.
            %#ok<NASGU>
            output = reg.service.EmbeddingOutput([]);
            if ~isempty(obj.EmbeddingRepo)
                obj.EmbeddingRepo.save(output);
            end
            if ~isempty(obj.SearchRepo)
                obj.SearchRepo.save(output);
            end
            error("reg:service:NotImplemented", ...
                "EmbeddingService.embed is not implemented.");
        end
    end
end
