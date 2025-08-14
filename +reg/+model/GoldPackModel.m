classdef GoldPackModel < reg.mvc.BaseModel
    %GOLDPACKMODEL Stub model providing labelled gold data.

    properties
        % Configuration for gold data retrieval
        config
    end

    methods
        function obj = GoldPackModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function data = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "GoldPackModel.load is not implemented.");
        end
        function result = process(~, data) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "GoldPackModel.process is not implemented.");
        end
    end
end
