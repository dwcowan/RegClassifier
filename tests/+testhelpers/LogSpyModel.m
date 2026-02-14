classdef LogSpyModel < handle
    properties
        ProcessCalled = false
        ProcessInput
    end
    methods
        function result = process(obj, data)
            obj.ProcessCalled = true;
            obj.ProcessInput = data;
            result = [];
        end
    end
end
