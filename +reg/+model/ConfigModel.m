classdef ConfigModel < reg.mvc.BaseModel
    %CONFIGMODEL Stub model retrieving configuration parameters.

    properties
        % Configuration settings to retrieve
        config
    end

    methods
        function obj = ConfigModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function data = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ConfigModel.load is not implemented.");
        end
        function result = process(~, data) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ConfigModel.process is not implemented.");
        end
    end
end
