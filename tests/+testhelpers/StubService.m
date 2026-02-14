classdef StubService < handle
    properties
        ProcessOutput
    end
    methods
        function obj = StubService(out)
            if nargin < 1, out = []; end
            obj.ProcessOutput = out;
        end
        function data = prepare(~)
            data = [];
        end
        function out = compute(obj, ~)
            out = obj.ProcessOutput;
        end
        function result = process(obj, ~)
            result = obj.ProcessOutput;
        end
        function data = load(obj, ~)
            data = obj.ProcessOutput;
        end
    end
end
