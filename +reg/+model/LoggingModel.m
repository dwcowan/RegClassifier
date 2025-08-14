classdef LoggingModel < reg.mvc.BaseModel
    %LOGGINGMODEL Stub model for persisting metrics.
    
    methods
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
