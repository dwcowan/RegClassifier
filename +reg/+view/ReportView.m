classdef ReportView < reg.mvc.BaseView
    %REPORTVIEW Stub view for rendering reports.
    
    properties
        DisplayedData
    end
    
    methods
        function display(obj, data)
            %DISPLAY Store report data for verification.
            obj.DisplayedData = data;
        end
    end
end
