classdef DatabaseModel < reg.mvc.BaseModel
    %DATABASEMODEL Stub model persisting predictions to a database.

    properties
        % Database connection handle created in `load`
        conn

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

        function inputs = load(obj, varargin) %#ok<INUSD>
            %LOAD Establish database connection.
            %   INPUTS = LOAD(obj) prepares database handles for writing by
            %   creating or reusing a connection in the `conn` property.
            %   Equivalent to `ensure_db` connection setup. Implementations
            %   should close any existing connection before opening a new
            %   one.
            error("reg:model:NotImplemented", ...
                "DatabaseModel.load is not implemented.");
        end

        function process(obj, inputs) %#ok<INUSD>
            %PROCESS Persist predictions to database.
            %   PROCESS(obj, inputs) writes chunk predictions and scores
            %   using `reg.upsert_chunks` so that rows in the `reg_chunks`
            %   table are inserted or updated with `lbl_*` and `score_*`
            %   columns for each label. Implementations should wrap
            %   inserts in a transaction when supported and ensure
            %   connections are committed or rolled back on error. Call
            %   `close(obj.conn)` when database work is complete to free
            %   resources.
            %   Equivalent to `ensure_db` persistence.
            error("reg:model:NotImplemented", ...
                "DatabaseModel.process is not implemented.");
        end
    end
end
