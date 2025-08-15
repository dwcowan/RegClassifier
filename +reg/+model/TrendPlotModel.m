classdef TrendPlotModel < reg.mvc.BaseModel
    %TRENPLOTMODEL Stub model dedicated to rendering metric trend plots.
    %   Separates trend visualisation responsibilities from other plotting
    %   utilities for finer granularity.

    methods
        function pngPath = plotTrends(~, csvPath, pngPath) %#ok<INUSD>
            %PLOTTRENDS Visualise metric trends over time.
            %   Inputs
            %       csvPath - path to a CSV file containing historical metric
            %                 values.
            %       pngPath - destination file path for the generated PNG.
            %   Output
            %       pngPath - the path where the trend plot should be saved.
            %   Side Effects
            %       Should read metrics from csvPath and write a plot image to
            %       pngPath.

            error('reg:model:NotImplemented', ...
                'TrendPlotModel.plotTrends is not implemented.');
        end

        function data = load(~, varargin) %#ok<INUSD>
            %LOAD Stub for interface completeness.
            error('reg:model:NotImplemented', ...
                'TrendPlotModel.load is not implemented.');
        end

        function result = process(~, data) %#ok<INUSD>
            %PROCESS Stub for interface completeness.
            error('reg:model:NotImplemented', ...
                'TrendPlotModel.process is not implemented.');
        end
    end
end
