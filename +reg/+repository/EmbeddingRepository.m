classdef (Abstract) EmbeddingRepository
    %EMBEDDINGREPOSITORY Interface for embedding persistence.
    methods (Abstract)
        save(obj, embeddings)
        embeddings = load(obj, ids)
        result = query(obj, varargin)
    end
end
