classdef ConfigService
    %CONFIGSERVICE Read and provide configuration settings.
    %   Wraps ConfigModel so controllers and services can obtain
    %   configuration without instantiating the model directly.

    properties
        ConfigModel reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = ConfigService(cfgModel)
            %CONFIGSERVICE Construct service with underlying model.
            if nargin > 0
                obj.ConfigModel = cfgModel;
            end
        end

        function cfg = getConfig(obj)
            %GETCONFIG Load and validate configuration settings.
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);
        end
    end
end
