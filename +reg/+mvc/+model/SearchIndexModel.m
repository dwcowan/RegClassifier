classdef SearchIndexModel < reg.mvc.BaseModel
    %SEARCHINDEXMODEL Stub model building retrieval index.
    
    methods
        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "SearchIndexModel.load is not implemented.");
        end
        function searchIx = process(~, inputs) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "SearchIndexModel.process is not implemented.");
        end
    end
end
