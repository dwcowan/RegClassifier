classdef EmbeddingService
    %EMBEDDINGSERVICE Generate dense embeddings from feature data.
    %   Encapsulates embedding backends previously modeled via
    %   EmbeddingModel.

    properties
        ConfigService reg.service.ConfigService
        EmbeddingRepo reg.repository.EmbeddingRepository
        SearchRepo reg.repository.SearchIndexRepository
    end

    methods
        function obj = EmbeddingService(cfgSvc, embeddingRepo, searchRepo)
            %EMBEDDINGSERVICE Construct embedding service with dependencies.
            if nargin > 0
                obj.ConfigService = cfgSvc;
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

        function output = embed(~, ~) %#ok<STOUT>
            %EMBED Produce dense vectors from INPUT.
            %   OUTPUT = EMBED(INPUT) should return an EmbeddingOutput
            %   containing an array of `reg.model.Embedding` instances.
            %
            %   This is a stub implementation. Use the functional embedding
            %   functions (reg.doc_embeddings_bert_gpu, reg.doc_embeddings_fasttext)
            %   or reg.precompute_embeddings instead.
            error("reg:service:NotImplemented", ...
                "EmbeddingService.embed is not implemented. Use reg.precompute_embeddings() instead.");
        end
    end
end
