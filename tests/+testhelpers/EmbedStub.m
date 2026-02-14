classdef EmbedStub < handle
    properties
        ProcessOutput
    end
    methods
        function obj = EmbedStub(out)
            if nargin >= 1, obj.ProcessOutput = out; end
        end
        function data = load(obj, varargin)
            data = [];
        end
        function result = process(obj, varargin)
            result = obj.ProcessOutput;
        end
    end
end
