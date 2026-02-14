classdef ConfigStub < handle
    properties
        LoadOutput
    end
    methods
        function obj = ConfigStub(out)
            if nargin >= 1, obj.LoadOutput = out; end
        end
        function data = load(obj, varargin)
            data = obj.LoadOutput;
        end
    end
end
