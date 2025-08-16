classdef ReportView < reg.mvc.BaseView
    %REPORTVIEW Stub view for rendering evaluation reports.
    %   Expects a struct DATA with fields describing report content:
    %       * summaryTables - table or cell array summarising overall metrics
    %       * irbSubset     - subset of predictions flagged for IRB review
    %       * trendCharts   - chart objects or file paths showing metric trends
    %       * (optional) metric arrays or other artefacts to embed
    %   Typical usage: EvaluationController assembles DATA after running
    %   its workflow and passes it to this view. A production
    %   implementation would format tables into HTML/PDF, persist IRB subsets
    %   to CSV for audit, and embed trend charts as images.

    properties
        DisplayedData
        SummaryTables
        IRBSubset
        TrendCharts

        % Placeholders for future customisation hooks --------------------
        TemplateName = "default_report"   % allows switching rendering templates
        PostRenderCallback                 % optional callback executed after display
    end

    methods
        function display(~, data) %#ok<INUSD>
            %DISPLAY Present report data for rendering.
            %   DISPLAY(~, DATA) would format summary tables, IRB subsets and
            %   trend charts into a comprehensive evaluation report.

            arguments
                ~
                data struct
            end

            % Pseudocode:
            %   render DATA.summaryTables into HTML or Markdown
            %   export DATA.irbSubset for review
            %   embed DATA.trendCharts into the report
            error("reg:view:NotImplemented", ...
                "ReportView.display is not implemented.");
        end
    end
end

