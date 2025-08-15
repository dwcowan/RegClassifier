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
        function display(obj, data)
            %DISPLAY Store report data for verification and expose key sections.
            %   DISPLAY(obj, DATA) retains summary tables, IRB subsets and
            %   trend charts for inspection. In a real view:
            %       * summaryTables would be rendered to HTML/Markdown
            %       * irbSubset could be written to a CSV for manual review
            %       * trendCharts might be saved as PNG and embedded
            %   Additional metric arrays would be handled similarly.
            %   If PostRenderCallback is defined it is invoked with DATA.

            obj.DisplayedData = data;
            if isstruct(data) && isfield(data, 'summaryTables')
                obj.SummaryTables = data.summaryTables;
            end
            if isstruct(data) && isfield(data, 'irbSubset')
                obj.IRBSubset = data.irbSubset;
            end
            if isstruct(data) && isfield(data, 'trendCharts')
                obj.TrendCharts = data.trendCharts;
            end

            if ~isempty(obj.PostRenderCallback)
                obj.PostRenderCallback(data);
            end
        end
    end
end

