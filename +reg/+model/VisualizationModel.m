classdef VisualizationModel < reg.mvc.BaseModel
    %VISUALIZATIONMODEL Stub model for generating evaluation plots.
    %   Provides helpers to render trend lines and co-retrieval heatmaps.

    properties
        % LastPlotPath (string): destination of most recently saved plot
        LastPlotPath string = ""
    end

    methods
        function obj = VisualizationModel(varargin) %#ok<INUSD>
            %VISUALIZATIONMODEL Construct visualization model.
            %   Currently accepts no configuration but is defined for
            %   symmetry with other models in the MVC framework.
        end

        function fig = plotTrends(~, metrics)
            %PLOTTRENDS Generate trend plot from supplied metrics struct.
            %   Inputs
            %       metrics - struct containing training history with fields:
            %                 ``epochs``, ``accuracy`` and ``loss``.
            %   Output
            %       fig     - handle to the created figure.  No files are
            %                 written by this stub implementation.

            arguments
                ~
                metrics struct
                metrics.epochs (:,1) double
                metrics.accuracy (:,1) double
                metrics.loss (:,1) double
            end

            fig = figure("Visible", "off");
            plot(metrics.epochs, [metrics.accuracy(:), metrics.loss(:)]);
            legend("Accuracy", "Loss");
            xlabel("Epoch");
            ylabel("Metric value");
        end

        function data = plotTrendsData(~, metrics) %#ok<INUSD>
            %PLOTTRENDSDATA Prepare training trend data for plotting.
            %   DATA = PLOTTRENDSDATA(METRICS) should extract the ``epochs``,
            %   ``accuracy`` and ``loss`` fields from the supplied ``metrics``
            %   struct and return them in a new struct suitable for plotting.

            arguments
                ~
                metrics struct
            end

            % Pseudocode:
            %   assert(all(isfield(metrics, {"epochs", "accuracy", "loss"})))
            %   data.epochs = metrics.epochs;
            %   data.accuracy = metrics.accuracy;
            %   data.loss = metrics.loss;
            error("reg:model:NotImplemented", ...
                "VisualizationModel.plotTrendsData is not implemented.");
        end

        function pngPath = plotCoRetrievalHeatmap(obj, coMatrix, pngPath, labels) %#ok<INUSD>
            %PLOTCORETRIEVALHEATMAP Render heatmap from co-retrieval matrix.
            %   Inputs
            %       coMatrix - L x L numeric matrix of co-retrieval rates
            %                  where rows typically sum to one.
            %       pngPath  - destination file path for the heatmap PNG.
            %       labels   - (optional) cell array of label names used to
            %                  annotate the axes.
            %   Output
            %       pngPath  - the path where the heatmap image should be
            %                  saved.
            %   Side Effects
            %       Should visualise the supplied matrix as a heatmap and
            %       persist it to ``pngPath``.
            arguments
                obj
                coMatrix double
                pngPath (1,1) string
                labels cell = {}
            end
            % Pseudocode/Validation:
            %   assert(size(coMatrix,1)==size(coMatrix,2))
            %   heatmap(coMatrix)
            %   saveas(fig, pngPath)
            %   obj.LastPlotPath = pngPath
            error("reg:model:NotImplemented", ...
                "VisualizationModel.plotCoRetrievalHeatmap is not implemented.");
        end

        function data = load(~, varargin) %#ok<INUSD>
            %LOAD Stub for interface completeness.
            arguments
                ~
                varargin (1,:) cell
            end
            error("reg:model:NotImplemented", ...
                "VisualizationModel.load is not implemented.");
        end

        function result = process(~, data) %#ok<INUSD>
            %PROCESS Stub for interface completeness.
            arguments
                ~
                data struct
            end
            error("reg:model:NotImplemented", ...
                "VisualizationModel.process is not implemented.");
        end
    end
end
