classdef ExampleModel < reg.mvc.BaseModel
    %EXAMPLEMODEL Stub implementation of BaseModel.
    %   All methods raise a NotImplemented error.

    methods
        function data = load(~, varargin) %#ok<INUSD>
            error("reg:mvc:NotImplemented", ...
                "ExampleModel.load is not implemented.");
        end
        function result = process(~, data) %#ok<INUSD>
            error("reg:mvc:NotImplemented", ...
                "ExampleModel.process is not implemented.");
        end
    end
end
