classdef ProjectionHeadModel < reg.mvc.BaseModel
    %PROJECTIONHEADMODEL Stub model applying projection head to embeddings.
    
    methods
        function E = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "ProjectionHeadModel.load is not implemented.");
        end
        function Eproj = process(~, E) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "ProjectionHeadModel.process is not implemented.");
        end
    end
end
