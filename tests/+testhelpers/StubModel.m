classdef StubModel < handle
    properties
        LoadOutput
        ProcessOutput
    end
    methods
        function obj = StubModel(loadOut, processOut)
            if nargin >= 1, obj.LoadOutput = loadOut; end
            if nargin >= 2, obj.ProcessOutput = processOut; end
        end
        function data = load(obj, varargin)
            data = obj.LoadOutput;
        end
        function result = process(obj, varargin)
            result = obj.ProcessOutput;
        end
    end
end
