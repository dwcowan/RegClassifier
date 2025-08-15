classdef Embedding
    %EMBEDDING Domain entity representing a dense vector.
    %   Associates a vector with its originating chunk or document.

    properties
        Vector double = []
        ChunkId string = ""
    end

    methods
        function obj = Embedding(vec, chunkId)
            %EMBEDDING Construct an embedding instance.
            %   OBJ = EMBEDDING(vec, chunkId) stores VECTOR and provenance
            %   information via CHUNKID.
            if nargin >= 1, obj.Vector = vec; end
            if nargin >= 2, obj.ChunkId = chunkId; end
        end

    end

    methods (Static)
        function save(embeddings) %#ok<INUSD>
            %SAVE Persist embedding vectors to storage.
            %   SAVE(embeddings) writes EMBEDDINGS to the configured
            %   storage backend.
            error("reg:model:NotImplemented", ...
                "Embedding.save is not implemented.");
        end

        function embeddings = load(ids) %#ok<INUSD,STOUT>
            %LOAD Retrieve embeddings by identifier.
            %   embeddings = LOAD(ids) fetches vectors from storage.
            error("reg:model:NotImplemented", ...
                "Embedding.load is not implemented.");
        end

        function result = query(varargin) %#ok<STOUT>
            %QUERY Execute an embedding search.
            %   result = QUERY(varargin) returns matching embeddings.
            error("reg:model:NotImplemented", ...
                "Embedding.query is not implemented.");
        end
    end
end
