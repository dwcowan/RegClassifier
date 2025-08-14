classdef DatabaseModel < reg.mvc.BaseModel
    %DATABASEMODEL Stub model persisting predictions to a database.
    
    methods
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
