classdef DatabaseModel < reg.mvc.BaseModel
    %DATABASEMODEL Stub model persisting predictions to a database.

    properties
        % Database configuration structure
        dbConfig
    end

    methods
        function obj = DatabaseModel(dbConfig)
            %DATABASEMODEL Construct database model.
            %   OBJ = DATABASEMODEL(dbConfig) stores DB configuration for
            %   later use. Equivalent to initialization in `ensure_db`.
            if nargin > 0
                obj.dbConfig = dbConfig;
            end
        end

        function inputs = load(~, varargin) %#ok<INUSD>
            %LOAD Establish database connection.
            %   INPUTS = LOAD(obj) prepares database handles for writing.
            %   Equivalent to `ensure_db` connection setup.
            error("reg:model:NotImplemented", ...
                "DatabaseModel.load is not implemented.");
        end
        function process(~, inputs) %#ok<INUSD>
            %PROCESS Persist predictions to database.
            %   PROCESS(obj, inputs) writes results using the provided
            %   configuration. Equivalent to `ensure_db` persistence.
            error("reg:model:NotImplemented", ...
                "DatabaseModel.process is not implemented.");
        end
    end
end
