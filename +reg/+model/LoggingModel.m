classdef LoggingModel < reg.mvc.BaseModel
    %LOGGINGMODEL Stub model for persisting metrics.

    properties
        % Logging configuration such as file path or endpoint
        config
    end

    methods
        function obj = LoggingModel(config)
            if nargin > 0
                obj.config = config;
            end
        end

        function metrics = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "LoggingModel.load is not implemented.");
        end
        function process(~, metrics) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "LoggingModel.process is not implemented.");
        end
    end
end
