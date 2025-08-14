classdef SearchIndexModel < reg.mvc.BaseModel
    %SEARCHINDEXMODEL Stub model building retrieval index.
    
    methods
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
