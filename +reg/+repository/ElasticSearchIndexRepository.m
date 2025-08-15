classdef ElasticSearchIndexRepository < reg.repository.SearchIndexRepository
    %ELASTICSEARCHINDEXREPOSITORY Stub search index implementation.
    methods
        function save(~, index) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "ElasticSearchIndexRepository.save is not implemented.");
        end
        function index = load(~, ids) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "ElasticSearchIndexRepository.load is not implemented.");
        end
        function result = query(~, varargin) %#ok<INUSD>
            error("reg:repository:NotImplemented", ...
                "ElasticSearchIndexRepository.query is not implemented.");
        end
    end
end
