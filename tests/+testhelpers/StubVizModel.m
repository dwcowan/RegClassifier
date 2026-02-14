classdef StubVizModel < handle
    properties
        ProcessOutput
    end
    methods
        function obj = StubVizModel(out)
            if nargin >= 1, obj.ProcessOutput = out; end
        end
        function result = process(obj, varargin)
            result = obj.ProcessOutput;
        end
    end
end
