classdef VisualizationModel < reg.mvc.BaseModel
    %VISUALIZATIONMODEL Stub model for generating evaluation plots.
    %   Provides helpers to render trend lines and co-retrieval heatmaps.

    methods
        function obj = VisualizationModel(varargin) %#ok<INUSD>
            %VISUALIZATIONMODEL Construct visualization model.
            %   Currently accepts no configuration but is defined for
            %   symmetry with other models in the MVC framework.
        end

        function pngPath = plotTrends(~, csvPath, pngPath)
            %PLOTTRENDS Generate trend plots from metrics history.
            %   pngPath = PLOTTRENDS(obj, csvPath, pngPath) wraps
            %   reg.plot_trends.
            pngPath = reg.plot_trends(csvPath, pngPath);
        end

        function pngPath = plotCoRetrievalHeatmap(~, embeddings, labelMatrix, pngPath, labels)
            %PLOTCORETRIEVALHEATMAP Create a heatmap of label co-retrieval.
            %   pngPath = PLOTCORETRIEVALHEATMAP(obj, embeddings, labelMatrix,
            %   pngPath, labels) delegates to reg.plot_coretrieval_heatmap.
            [M, order] = reg.label_coretrieval_matrix(embeddings, labelMatrix, 10);
            pngPath = reg.plot_coretrieval_heatmap(M(order,order), string(labels(order)), pngPath);
        end

        function data = load(~, varargin) %#ok<INUSD>
            %LOAD Stub for interface completeness.
            error("reg:model:NotImplemented", ...
                "VisualizationModel.load is not implemented.");
        end

        function result = process(~, data) %#ok<INUSD>
            %PROCESS Stub for interface completeness.
            error("reg:model:NotImplemented", ...
                "VisualizationModel.process is not implemented.");
        end
    end
end
