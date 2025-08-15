classdef VisualizationModel < reg.mvc.BaseModel
    %VISUALIZATIONMODEL Stub model for generating evaluation plots.
    %   Provides helpers to render trend lines and co-retrieval heatmaps.

    methods
        function obj = VisualizationModel(varargin) %#ok<INUSD>
            %VISUALIZATIONMODEL Construct visualization model.
            %   Currently accepts no configuration but is defined for
            %   symmetry with other models in the MVC framework.
        end

        function pngPath = plotTrends(~, csvPath, pngPath) %#ok<INUSD>
            %PLOTTRENDS Generate trend plots from metrics history.
            %   Inputs
            %       csvPath - file path to a metrics CSV containing
            %                 historical values.
            %       pngPath - destination file path for the rendered PNG.
            %   Output
            %       pngPath - the path where the plot should be written.
            %   Side Effects
            %       Should read metric values from csvPath and write a trend
            %       plot image to pngPath.

            error("reg:model:NotImplemented", ...
                "VisualizationModel.plotTrends is not implemented.");
        end

        function pngPath = plotCoRetrievalHeatmap(~, embeddings, labelMatrix, pngPath, labels) %#ok<INUSD>
            %PLOTCORETRIEVALHEATMAP Create a heatmap of label co-retrieval.
            %   Inputs
            %       embeddings   - numeric matrix of embedding vectors.
            %       labelMatrix  - logical or numeric matrix indicating label
            %                      assignments for each embedding.
            %       pngPath      - destination file path for the heatmap PNG.
            %       labels       - (optional) cell array of label names used to
            %                      annotate axes.
            %   Output
            %       pngPath      - the path where the heatmap should be saved.
            %   Side Effects
            %       Should compute co-retrieval frequencies from inputs and
            %       persist a heatmap image to pngPath.

            error("reg:model:NotImplemented", ...
                "VisualizationModel.plotCoRetrievalHeatmap is not implemented.");
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
