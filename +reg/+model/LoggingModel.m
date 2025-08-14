classdef LoggingModel < reg.mvc.BaseModel
    %LOGGINGMODEL Stub model for persisting metrics.

    properties
        % Logging configuration such as file path or endpoint
        config
    end

    methods
        function obj = LoggingModel(config)
            %LOGGINGMODEL Construct logging model.
            %   OBJ = LOGGINGMODEL(config) stores logging configuration.
            %   Equivalent to initialization in `log_metrics`.
            if nargin > 0
                obj.config = config;
            end
        end

        function metrics = load(~, varargin) %#ok<INUSD>
            %LOAD Acquire metrics to log.
            %   METRICS = LOAD(obj) collects metrics data structures.
            %   Equivalent to `log_metrics` input preparation.
            error("reg:model:NotImplemented", ...
                "LoggingModel.load is not implemented.");
        end
        function process(~, metrics) %#ok<INUSD>
            %PROCESS Persist metrics using configured backend.
            %   PROCESS(obj, metrics) records data to logs or storage.
            %   Equivalent to `log_metrics`.
            error("reg:model:NotImplemented", ...
                "LoggingModel.process is not implemented.");
        end
    end
end
