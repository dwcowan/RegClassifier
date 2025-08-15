classdef SearchIndexModel < reg.mvc.BaseModel
    %SEARCHINDEXMODEL Stub model building retrieval index.

    properties
        % Shared configuration reference
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = SearchIndexModel(cfg)
            %SEARCHINDEXMODEL Construct search index model.
            %   OBJ = SEARCHINDEXMODEL(cfg) uses settings such as
            %   cfg.gpuEnabled or cfg.projDim when creating indexes.
            if nargin > 0
                obj.cfg = cfg;
            end
        end

        function indexInputs = load(~, varargin) %#ok<INUSD>
            %LOAD Gather data for index building.
            %   indexInputs = LOAD(obj) retrieves documents and metadata for
            %   the index.
            %   Parameters
            %       varargin - Placeholder for future options (unused)
            %   Returns
            %       indexInputs (struct): Documents, embeddings and ids.
            %   Side Effects
            %       None.
            %   Legacy Reference
            %       Equivalent to `upsert_chunks` preparation.
            %   Extension Point
            %       Override to source documents from other systems.
            % Pseudocode:
            %   1. Load documents and embeddings
            %   2. Package into indexInputs struct
            %   3. Return indexInputs
            error("reg:model:NotImplemented", ...
                "SearchIndexModel.load is not implemented.");
        end
        function searchIndex = process(~, indexInputs) %#ok<INUSD>
            %PROCESS Build or update the search index.
            %   searchIndex = PROCESS(obj, indexInputs) returns index handle
            %   or identifier.
            %   Parameters
            %       indexInputs (struct): Data required to build the index.
            %   Returns
            %       searchIndex (struct): Handle or id for the created index.
            %   Side Effects
            %       May write index files or call external services.
            %   Legacy Reference
            %       Equivalent to `upsert_chunks`.
            %   Extension Point
            %       Plug in alternative indexing backends.
            % Pseudocode:
            %   1. Initialize search index backend
            %   2. Upsert documents and embeddings from indexInputs
            %   3. Return searchIndex identifier
            error("reg:model:NotImplemented", ...
                "SearchIndexModel.process is not implemented.");
        end
    end
end
