classdef PipelineController < reg.mvc.BaseController
    %PIPELINECONTROLLER Orchestrates end-to-end pipeline flow.

    properties
        ConfigModel
        TrainingModel
        EmbeddingModel
        EvaluationModel
        EmbeddingView
    end

    methods
        function obj = PipelineController(cfgModel, trainModel, embedModel, evalModel, view, embView)
            %PIPELINECONTROLLER Construct controller wiring core models.
            %   OBJ = PIPELINECONTROLLER(CFG, TRAIN, EMBED, EVAL, VIEW, EMBVIEW)
            %   stores references to the provided models, a metrics view
            %   and an optional embedding view.
            if nargin < 5 || isempty(view)
                view = reg.view.MetricsView();
            end
            if nargin < 6 || isempty(embView)
                embView = reg.view.EmbeddingView();
            end
            obj@reg.mvc.BaseController(cfgModel, view);
            obj.ConfigModel = cfgModel;
            obj.TrainingModel = trainModel;
            obj.EmbeddingModel = embedModel;
            obj.EvaluationModel = evalModel;
            obj.EmbeddingView = embView;
        end

        function run(obj)
            %RUN Execute simplified pipeline coordinating models.
            %   Sequencing: Config -> Ingestion -> Embedding -> Evaluation.

            % Step 1: retrieve configuration
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);

            % Step 2: ingest documents/features via training model
            ingestOut = obj.TrainingModel.ingest(cfg);

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
            reg.helpers.logMetrics(evalResult.Metrics);
            if ~isempty(obj.View)
                obj.View.display(evalResult.Metrics);
            end
        end
    end
end
