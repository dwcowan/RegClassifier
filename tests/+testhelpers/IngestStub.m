classdef IngestStub < handle
    properties
        ProcessOutput
    end
    methods
        function obj = IngestStub(out)
            if nargin >= 1, obj.ProcessOutput = out; else, obj.ProcessOutput = table(); end
        end
        function data = load(obj, varargin)
            data = [];
        end
        function result = process(obj, varargin)
            result = obj.ProcessOutput;
        end
    end
end
