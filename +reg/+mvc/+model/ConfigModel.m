classdef ConfigModel < reg.mvc.BaseModel
    %CONFIGMODEL Stub model retrieving configuration parameters.
    
    methods
        function data = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "ConfigModel.load is not implemented.");
        end
        function result = process(~, data) %#ok<INUSD>
            error("reg:mvc:model:NotImplemented", ...
                "ConfigModel.process is not implemented.");
        end
    end
end
