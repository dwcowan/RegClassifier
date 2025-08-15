classdef PipelineController < reg.mvc.BaseController
    %PIPELINECONTROLLER Orchestrates end-to-end pipeline flow.

    properties
        ConfigModel
        TrainingModel
        EvaluationModel
        EmbeddingView
        CorpusModel
    end

    methods
        function obj = PipelineController(cfgModel, trainModel, evalModel, view, embView, corpusModel)
            %PIPELINECONTROLLER Construct controller wiring core models.
            %   OBJ = PIPELINECONTROLLER(CFG, TRAIN, EVAL, VIEW, EMBVIEW)
            %   stores references to the provided models, a metrics view
            %   and an optional embedding view.
            if nargin < 4 || isempty(view)
                view = reg.view.MetricsView();
            end
            if nargin < 5 || isempty(embView)
                embView = reg.view.EmbeddingView();
            end
            if nargin < 6 || isempty(corpusModel)
                corpusModel = reg.model.CorpusModel();
            end
            obj@reg.mvc.BaseController(cfgModel, view);
            obj.ConfigModel = cfgModel;
            obj.TrainingModel = trainModel;
            obj.EvaluationModel = evalModel;
            obj.EmbeddingView = embView;
            obj.CorpusModel = corpusModel;
        end

        function run(obj)
            %RUN Execute simplified pipeline coordinating models.
            %   Sequencing: Config -> Ingestion -> Embedding -> Evaluation.

            % Step 1: retrieve configuration
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);

            % Step 2: ingest PDFs and build search index via corpus model
            docs = obj.CorpusModel.ingestPdfs(cfg);
            obj.CorpusModel.persistDocuments(docs);
            obj.CorpusModel.buildIndex(docs);
            obj.CorpusModel.queryIndex("pipeline query", 0.5, 5);

            % Step 3: ingest documents and chunk text via training model
            ingestOut = obj.TrainingModel.ingest(cfg);

            % Step 4: extract features and compute embeddings
            [features, ~] = obj.TrainingModel.extractFeatures(ingestOut.Chunks);
            embOut = obj.TrainingModel.computeEmbeddings(features);
            if ~isempty(obj.EmbeddingView)
                obj.EmbeddingView.display(embOut);
            end

            % Step 5: evaluate results
            evalRaw = obj.EvaluationModel.load(embOut, []);
            evalResult = obj.EvaluationModel.process(evalRaw);

            % Log metrics and display via view
            if ~isempty(obj.View)
                obj.View.log(evalResult.Metrics);
                obj.View.display(evalResult.Metrics);
            end
        end
    end
end
