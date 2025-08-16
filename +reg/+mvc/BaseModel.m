classdef BaseModel < handle
    %BASEMODEL Abstract data model for the reg MVC framework.
    %   Subclasses implement specific data acquisition and transformation
    %   responsibilities. Controllers invoke the lifecycle methods in the
    %   order `load` then `process`, mirroring the legacy `reg_pipeline`
    %   script which first gathered raw inputs before generating
    %   artefacts.

    methods
        function data = load(obj, varargin)
            %LOAD Retrieve raw application data.
            %   DATA = LOAD(obj) should collect information from files,
            %   databases or external services. Implementations may accept
            %   optional parameters via VARARGIN to specialise data
            %   acquisition. The returned DATA is then forwarded to
            %   `process` for transformation.
            arguments
                obj
            end
            arguments (Repeating)
                varargin
            end
            arguments (Output)
                data
            end
            error("reg:mvc:NotImplemented", ...
                "Models must override load to gather raw data.");
        end

        function result = process(obj, data)
            %PROCESS Convert raw data into domain specific results.
            %   RESULT = PROCESS(obj, DATA) receives the output of `load`
            %   and transforms it into the form expected by controllers and
            %   views. For example, in `reg_pipeline` a model may load text
            %   chunks and process them into embeddings.
            arguments
                obj
                data
            end
            arguments (Output)
                result
            end
            error("reg:mvc:NotImplemented", ...
                "Models must override process to transform data.");
        end
    end
end
