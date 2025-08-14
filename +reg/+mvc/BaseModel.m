classdef (Abstract) BaseModel < handle
    %BASEMODEL Interface for data and core computation layer.
    %   Responsible for accessing and transforming data.

    methods (Abstract)
        function data = load(obj, varargin)
            %LOAD Retrieve input data from a source.
        end

        function result = process(obj, data)
            %PROCESS Transform input data into usable results.
        end
    end
end
