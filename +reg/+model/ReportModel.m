classdef ReportModel < reg.mvc.BaseModel
    %REPORTMODEL Stub model assembling report data.
    
    methods
        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ReportModel.load is not implemented.");
        end
        function reportData = process(~, inputs) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "ReportModel.process is not implemented.");
        end
    end
end
