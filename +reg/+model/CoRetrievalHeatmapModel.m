classdef CoRetrievalHeatmapModel < reg.mvc.BaseModel
    %CORETRIEVALHEATMAPMODEL Stub model dedicated to co-retrieval heatmaps.
    %   Encapsulates generation of label co-retrieval visualisations separate
    %   from other plotting utilities.

    methods
        function pngPath = plotCoRetrievalHeatmap(~, embeddings, labelMatrix, pngPath, labels) %#ok<INUSD>
            %PLOTCORETRIEVALHEATMAP Visualise label co-retrieval frequencies.
            %   Inputs
            %       embeddings  - numeric matrix of embedding vectors.
            %       labelMatrix - logical or numeric matrix denoting labels for
            %                     each embedding.
            %       pngPath     - destination file path for the heatmap PNG.
            %       labels      - (optional) cell array of label names to use for
            %                     axis annotations.
            %   Output
            %       pngPath     - the path where the heatmap image should be
            %                     saved.
            %   Side Effects
            %       Should compute a co-retrieval matrix from the embeddings and
            %       labels and persist a heatmap to pngPath.

            error('reg:model:NotImplemented', ...
                'CoRetrievalHeatmapModel.plotCoRetrievalHeatmap is not implemented.');
        end

        function data = load(~, varargin) %#ok<INUSD>
            %LOAD Stub for interface completeness.
            error('reg:model:NotImplemented', ...
                'CoRetrievalHeatmapModel.load is not implemented.');
        end

        function result = process(~, data) %#ok<INUSD>
            %PROCESS Stub for interface completeness.
            error('reg:model:NotImplemented', ...
                'CoRetrievalHeatmapModel.process is not implemented.');
        end
    end
end
