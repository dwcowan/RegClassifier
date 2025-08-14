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
