classdef WeakLabelModel < reg.mvc.BaseModel
    %WEAKLABELMODEL Stub model generating weak supervision labels.
    
    methods
        function chunksT = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "WeakLabelModel.load is not implemented.");
        end
        function [Yweak, Yboot] = process(~, chunksT) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "WeakLabelModel.process is not implemented.");
        end
    end
end
