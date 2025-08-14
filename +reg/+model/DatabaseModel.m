classdef DatabaseModel < reg.mvc.BaseModel
    %DATABASEMODEL Stub model persisting predictions to a database.

    properties
        % Database configuration structure
        dbConfig
    end

    methods
        function obj = DatabaseModel(dbConfig)
            if nargin > 0
                obj.dbConfig = dbConfig;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "DatabaseModel.load is not implemented.");
        end
        function process(~, inputs) %#ok<INUSD>
            error("reg:model:NotImplemented", ...
                "DatabaseModel.process is not implemented.");
        end
    end
end
