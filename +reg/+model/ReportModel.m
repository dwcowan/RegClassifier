classdef ReportModel < reg.mvc.BaseModel
    %REPORTMODEL Stub model assembling report data.

    properties
        % Report generation configuration
        config
    end

    methods
        function obj = ReportModel(config)
            %REPORTMODEL Construct report generation model.
            %   OBJ = REPORTMODEL(config) stores reporting parameters.
            %   Equivalent to initialization in `generate_reg_report`.
            if nargin > 0
                obj.config = config;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            %LOAD Gather inputs required for reporting.
            %   INPUTS = LOAD(obj) collects metrics and metadata for the
            %   report. Equivalent to `generate_reg_report` data loading.
            error("reg:model:NotImplemented", ...
                "ReportModel.load is not implemented.");
        end
        function reportData = process(~, inputs) %#ok<INUSD>
            %PROCESS Assemble report data structure.
            %   REPORTDATA = PROCESS(obj, inputs) returns a struct ready for
            %   rendering. Equivalent to `generate_reg_report`.
            error("reg:model:NotImplemented", ...
                "ReportModel.process is not implemented.");
        end
    end
end
