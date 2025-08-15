classdef PipelineController < reg.mvc.BaseController
    %PIPELINECONTROLLER Orchestrates end-to-end pipeline flow.

    properties
        ConfigModel
        IngestionModel
        EmbeddingModel
        EvaluationModel
        LoggingModel
        EmbeddingView
    end

    methods
        function obj = PipelineController(cfgModel, ingestModel, embedModel, evalModel, logModel, view, embView)
            %PIPELINECONTROLLER Construct controller wiring core models.
            %   OBJ = PIPELINECONTROLLER(CFG, INGEST, EMBED, EVAL, LOG, VIEW, EMBVIEW)
            %   stores references to the provided models, a metrics view
            %   and an optional embedding view.
            if nargin < 6 || isempty(view)
                view = reg.view.MetricsView();
            end
            if nargin < 7 || isempty(embView)
                embView = reg.view.EmbeddingView();
            end
            obj@reg.mvc.BaseController(cfgModel, view);
            obj.ConfigModel = cfgModel;
            obj.IngestionModel = ingestModel;
            obj.EmbeddingModel = embedModel;
            obj.EvaluationModel = evalModel;
            obj.LoggingModel = logModel;
            obj.EmbeddingView = embView;
        end

        function run(obj)
            %RUN Execute simplified pipeline coordinating models.
            %   Sequencing: Config -> Ingestion -> Embedding -> Evaluation.

            % Step 1: retrieve configuration
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);

            % Step 2: ingest documents/features via model
            ingestRaw = obj.IngestionModel.load(cfg);
            ingestOut = obj.IngestionModel.process(ingestRaw);

            % Step 3: embed features
            embRaw = obj.EmbeddingModel.load(ingestOut.Features);
            embOut = obj.EmbeddingModel.process(embRaw);
            if ~isempty(obj.EmbeddingView)
                obj.EmbeddingView.display(embOut);
            end

            % Step 4: evaluate results
            evalRaw = obj.EvaluationModel.load(embOut, []);
            evalResult = obj.EvaluationModel.process(evalRaw);

            % Log metrics and display via view
            logData = obj.LoggingModel.load(evalResult.Metrics);
            obj.LoggingModel.process(logData);
            if ~isempty(obj.View)
                obj.View.display(evalResult.Metrics);
            end
        end
    end
end
