classdef GoldPackModel < reg.mvc.BaseModel
    %GOLDPACKMODEL Stub model providing labelled gold data.

    properties
        % Configuration for gold data retrieval
        config
    end

    methods
        function obj = GoldPackModel(config)
            %GOLDPACKMODEL Construct gold data model.
            %   OBJ = GOLDPACKMODEL(config) stores retrieval settings.
            %   Equivalent to initialization in `load_gold`.
            if nargin > 0
                obj.config = config;
            end
        end

        function data = load(~, varargin) %#ok<INUSD>
            %LOAD Retrieve gold labelled data.
            %   DATA = LOAD(obj) reads pre-packaged gold datasets.
            %   Equivalent to `load_gold`.
            error("reg:model:NotImplemented", ...
                "GoldPackModel.load is not implemented.");
        end
        function result = process(~, data) %#ok<INUSD>
            %PROCESS Return processed gold data.
            %   RESULT = PROCESS(obj, data) outputs structured gold
            %   artefacts. Equivalent to `load_gold` post-processing.
            error("reg:model:NotImplemented", ...
                "GoldPackModel.process is not implemented.");
        end
    end
end
