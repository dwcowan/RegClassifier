classdef SpyController < reg.mvc.BaseController
    properties
        RunCalled = false
    end
    methods
        function run(obj, varargin)
            obj.RunCalled = true;
        end
    end
end
