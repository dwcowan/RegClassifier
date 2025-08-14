classdef SearchIndexModel < reg.mvc.BaseModel
    %SEARCHINDEXMODEL Stub model building retrieval index.

    properties
        % Configuration for building the search index
        config
    end

    methods
        function obj = SearchIndexModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "SearchIndexModel.load is not implemented.");
        end
        function searchIx = process(~, inputs) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "SearchIndexModel.process is not implemented.");
        end
    end
end
