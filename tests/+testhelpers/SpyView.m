classdef SpyView < handle
    properties
        DisplayedData
        RenderCallCount = 0
    end
    methods
        function render(obj, data)
            obj.DisplayedData = data;
            obj.RenderCallCount = obj.RenderCallCount + 1;
        end
        function display(obj, data)
            obj.DisplayedData = data;
        end
    end
end
