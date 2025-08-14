classdef GoldPackModel < reg.mvc.BaseModel
    %GOLDPACKMODEL Stub model providing labelled gold data.
    
    methods
        function data = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "GoldPackModel.load is not implemented.");
        end
        function result = process(~, data) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "GoldPackModel.process is not implemented.");
        end
    end
end
