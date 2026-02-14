classdef StubEvalController < handle
    properties
        RunOutput
    end
    methods
        function obj = StubEvalController(out)
            if nargin >= 1, obj.RunOutput = out; end
        end
        function run(obj, varargin)
            % Stub run method
        end
    end
end
