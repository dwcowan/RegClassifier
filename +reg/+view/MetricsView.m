classdef MetricsView < reg.mvc.BaseView
    %METRICSVIEW Stub view for presenting metrics.
    
    properties
        DisplayedMetrics
    end
    
    methods
        function display(obj, data)
            %DISPLAY Store metrics for verification.
            %   DISPLAY(obj, data) captures metric structures for later
            %   inspection. Returns nothing. Equivalent to `log_metrics`.
            obj.DisplayedMetrics = data;
        end
    end
end
