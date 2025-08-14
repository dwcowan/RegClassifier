classdef ExampleView < reg.mvc.BaseView
    %EXAMPLEVIEW Stub view storing displayed data.

    properties
        DisplayedData
    end

    methods
        function display(obj, data)
            %DISPLAY Store data for verification.
            obj.DisplayedData = data;
        end
    end
end
