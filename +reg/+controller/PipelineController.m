classdef PipelineController < reg.mvc.BaseController
    %PIPELINECONTROLLER Orchestrates end-to-end pipeline flow.
    
    properties
        ConfigModel
        IngestionService
        EmbeddingService
        EvaluationService
        LoggingModel
    end

    methods
        function obj = PipelineController(cfgModel, ingestSvc, embedSvc, evalSvc, logModel, view)
            %PIPELINECONTROLLER Construct controller wiring core services.
            %   OBJ = PIPELINECONTROLLER(CFG, INGEST, EMBED, EVAL, LOG, VIEW)
            %   stores references to the provided services and view.
            obj@reg.mvc.BaseController(cfgModel, view);
            obj.ConfigModel = cfgModel;
            obj.IngestionService = ingestSvc;
            obj.EmbeddingService = embedSvc;
            obj.EvaluationService = evalSvc;
            obj.LoggingModel = logModel;
        end

        function run(obj)
            %RUN Execute simplified pipeline coordinating services.
            %   Sequencing: Config -> Ingestion -> Embedding -> Evaluation.

            % Step 1: retrieve configuration
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);

            % Step 2: ingest documents/features via service
            ingestOut = obj.IngestionService.ingest(cfg);

            % Step 3: embed features
            embInput = obj.EmbeddingService.prepare(ingestOut.Features);
            embOut = obj.EmbeddingService.embed(embInput);

            % Step 4: evaluate results
            evalInput = obj.EvaluationService.prepare(embOut, []);
            evalResult = obj.EvaluationService.compute(evalInput);

            % Log metrics and display via view
            logData = obj.LoggingModel.load(evalResult.Metrics);
            obj.LoggingModel.process(logData);
            obj.View.display(evalResult.Metrics);
        end
    end
end
