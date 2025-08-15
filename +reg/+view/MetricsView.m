classdef MetricsView < reg.mvc.BaseView
    %METRICSVIEW Stub view for presenting metrics produced by controllers.
    %   Expected fields in DATA include:
    %       * overall  - struct of aggregate scores (RecallAtK, mAP, etc.)
    %       * perLabel - table of metrics per label or class
    %       * history  - optional arrays of metric values over time
    %   Controllers such as ProjectionHeadController or FineTuneController
    %   pass this view the metrics struct. A full implementation might log
    %   these values, plot progress charts or render HTML tables.

    properties
        DisplayedMetrics

        % Placeholder for future customisation hook ----------------------
        OnDisplayCallback   % function handle executed after metrics stored
    end

    methods
        function display(obj, data)
            %DISPLAY Store metrics for verification.
            %   DISPLAY(obj, DATA) captures metric structures for later
            %   inspection. In a production view:
            %       * overall scores could be printed or persisted to CSV
            %       * perLabel tables might be turned into bar charts
            %       * history arrays would feed trend plots
            %   If OnDisplayCallback is set, it is invoked with DATA.

            obj.DisplayedMetrics = data;
            if ~isempty(obj.OnDisplayCallback)
                obj.OnDisplayCallback(data);
            end
        end

        function log(~, metrics)
            %LOG Simple logging helper for metrics structs.
            %   LOG(~, METRICS) prints METRICS to the console. In a full
            %   implementation this could persist to disk or external services.

            disp(metrics);
        end
    end
end
