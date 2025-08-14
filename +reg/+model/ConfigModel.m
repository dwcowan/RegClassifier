classdef ConfigModel < reg.mvc.BaseModel
    %CONFIGMODEL Stub model retrieving configuration parameters.

    properties
        % Configuration settings to retrieve
        config
    end

    methods
        function obj = ConfigModel(config)
            %CONFIGMODEL Construct configuration model.
            %   OBJ = CONFIGMODEL(config) stores configuration parameters.
            %   Equivalent to initialization in `load_knobs`.
            if nargin > 0
                obj.config = config;
            end
        end

        function data = load(~, varargin) %#ok<INUSD>
            %LOAD Retrieve configuration from source.
            %   DATA = LOAD(obj) reads knob settings and returns a struct.
            %   Equivalent to `load_knobs`.
            error("reg:model:NotImplemented", ...
                "ConfigModel.load is not implemented.");
        end
        function result = process(~, data) %#ok<INUSD>
            %PROCESS Validate configuration values.
            %   RESULT = PROCESS(obj, data) performs sanity checks and
            %   returns the validated structure. Equivalent to
            %   `validate_knobs`.
            error("reg:model:NotImplemented", ...
                "ConfigModel.process is not implemented.");
        end
    end
end
