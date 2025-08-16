classdef MetricsView < reg.mvc.BaseView
    %METRICSVIEW Stub view for presenting metrics produced by controllers.
    %   Expected fields in DATA include:
    %       * overall  - struct of aggregate scores (RecallAtK, mAP, etc.)
    %       * perLabel - table of metrics per label or class
    %       * history  - optional arrays of metric values over time
    %   Controllers such as PipelineController pass this view the metrics
    %   struct. A full implementation might log these values, plot progress
    %   charts or render HTML tables.

    properties
        DisplayedMetrics

        % Placeholder for future customisation hook ----------------------
        OnDisplayCallback   % function handle executed after metrics stored
    end

    methods
        function display(~, data) %#ok<INUSD>
            %DISPLAY Present metrics for verification.
            %   DISPLAY(~, DATA) would format metrics into tables, charts or
            %   logs for further analysis.

            arguments
                ~
                data struct
            end

            % Pseudocode:
            %   extract overall, perLabel and history sections from DATA
            %   render each section using appropriate visualisation
            error("reg:view:NotImplemented", ...
                "MetricsView.display is not implemented.");
        end

        function log(~, metrics) %#ok<INUSD>
            %LOG Present metrics through a logging mechanism.
            %   LOG(~, METRICS) would persist metrics to a log file or
            %   external monitoring service.

            arguments
                ~
                metrics struct
            end

            % Pseudocode:
            %   convert METRICS struct to textual representation
            %   append text to log output
            error("reg:view:NotImplemented", ...
                "MetricsView.log is not implemented.");
        end
    end
end
