classdef ReportView < reg.mvc.BaseView
    %REPORTVIEW Stub view for rendering reports.
    
    properties
        DisplayedData
        SummaryTables
        IRBSubset
        TrendCharts
    end

    methods
        function display(obj, data)
            %DISPLAY Store report data for verification and expose key
            %evaluation sections for tests.
            %   DISPLAY(obj, data) keeps summary tables, IRB subsets and
            %   trend charts for inspection. Returns nothing. Equivalent to
            %   rendering in `generate_reg_report`.
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
        end
    end
end
