classdef SearchIndexModel < reg.mvc.BaseModel
    %SEARCHINDEXMODEL Stub model building retrieval index.

    properties
        % Configuration for building the search index
        config
    end

    methods
        function obj = SearchIndexModel(config)
            %SEARCHINDEXMODEL Construct search index model.
            %   OBJ = SEARCHINDEXMODEL(config) stores index configuration.
            %   Equivalent to initialization in `upsert_chunks`.
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            %LOAD Gather data for index building.
            %   INPUTS = LOAD(obj) retrieves documents and metadata for the
            %   index. Equivalent to `upsert_chunks` preparation.
            error("reg:model:NotImplemented", ...
                "SearchIndexModel.load is not implemented.");
        end
        function searchIx = process(~, inputs) %#ok<INUSD>
            %PROCESS Build or update the search index.
            %   SEARCHIX = PROCESS(obj, inputs) returns index handle or id.
            %   Equivalent to `upsert_chunks`.
            error("reg:model:NotImplemented", ...
                "SearchIndexModel.process is not implemented.");
        end
    end
end
