classdef MetricsView < reg.mvc.BaseView
    %METRICSVIEW Stub view for presenting metrics.
    
    properties
        DisplayedMetrics
    end
    
    methods
        function display(obj, data)
            %DISPLAY Store metrics for verification.
            obj.DisplayedMetrics = data;
        end
    end
end
