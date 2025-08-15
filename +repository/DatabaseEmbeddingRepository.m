classdef DatabaseEmbeddingRepository < reg.repository.EmbeddingRepository
    %DATABASEEMBEDDINGREPOSITORY Stub database implementation.
    methods
        function save(~, embeddings) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "DatabaseEmbeddingRepository.save is not implemented.");
        end
        function embeddings = load(~, ids) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "DatabaseEmbeddingRepository.load is not implemented.");
        end
        function result = query(~, varargin) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "DatabaseEmbeddingRepository.query is not implemented.");
        end
    end
end
