classdef PipelineModel < reg.mvc.BaseModel
    %PIPELINEMODEL Encapsulate full pipeline coordination.
    %   Handles configuration loading, corpus ingestion, feature and
    %   embedding extraction, classifier training, encoder fine-tuning
    %   and evaluation. Internal steps delegate to specialised models
    %   such as ConfigModel, CorpusModel, TrainingModel and
    %   EvaluationModel.

    properties
        ConfigModel
        TrainingModel
        CorpusModel
        EvaluationModel
    end

    methods
        function obj = PipelineModel(cfgModel, corpusModel, trainModel, evalModel)
            %PIPELINEMODEL Construct pipeline model wiring core models.
            if nargin < 1 || isempty(cfgModel)
                cfgModel = reg.model.ConfigModel();
            end
            if nargin < 2 || isempty(corpusModel)
                corpusModel = reg.model.CorpusModel();
            end
            if nargin < 3 || isempty(trainModel)
                trainModel = reg.model.TrainingModel();
            end
            if nargin < 4 || isempty(evalModel)
                evalModel = reg.model.EvaluationModel();
            end
            obj.ConfigModel = cfgModel;
            obj.CorpusModel = corpusModel;
            obj.TrainingModel = trainModel;
            obj.EvaluationModel = evalModel;
        end

        function result = run(obj)
            %RUN Execute the end-to-end pipeline.
            %   RESULT = RUN(obj) coordinates configuration loading,
            %   corpus ingestion, feature/embedding extraction, classifier
            %   training, fine-tuning and evaluation.

            % Step 1: configuration
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);

            % Step 2: corpus ingestion
            docs = obj.ingestCorpus(cfg);

            % Step 3: training workflow (features, embeddings, classifier)
            trainOut = obj.runTraining(cfg);

            % Step 4: optional fine-tuning workflow
            if isfield(cfg, 'fineTuneEpochs') && cfg.fineTuneEpochs > 0
                trainOut.FineTune = obj.runFineTune(cfg);
            end

            % Step 5: optional projection head workflow
            if isfield(cfg, 'projEpochs') && cfg.projEpochs > 0
                trainOut.ProjectedEmbeddings = obj.runProjectionHead(
                    trainOut.Embeddings);
            end

            % Step 6: evaluation via controller
            evalEmbeddings = trainOut.Embeddings;
            if isfield(trainOut, 'ProjectedEmbeddings')
                evalEmbeddings = trainOut.ProjectedEmbeddings;
            end
            labels = [];
            if isfield(trainOut, 'PredLabels')
                labels = trainOut.PredLabels;
            end
            evalController = reg.controller.EvaluationController(
                obj.EvaluationModel, reg.model.ReportModel());
            metrics = evalController.run(evalEmbeddings, labels);

            result = struct('Documents', docs, ...
                'Training', trainOut, ...
                'Metrics', metrics);
        end

        function docs = ingestCorpus(obj, cfg)
            %INGESTCORPUS Ingest PDFs, persist them and build the index.
            docs = obj.CorpusModel.ingestPdfs(cfg);
            obj.CorpusModel.persistDocuments(docs);
            obj.CorpusModel.buildIndex(docs);
        end

        function results = exampleSearch(obj, queryString, alpha, topK)
            %EXAMPLESEARCH Run a sample query against the search index.
            %   RESULTS = EXAMPLESEARCH(obj, queryString, alpha, topK)
            %   delegates to CorpusModel.queryIndex. Default parameters are
            %   provided for debugging convenience.
            if nargin < 2
                queryString = "pipeline query";
            end
            if nargin < 3
                alpha = 0.5;
            end
            if nargin < 4
                topK = 5;
            end
            results = obj.CorpusModel.queryIndex(queryString, alpha, topK);
        end

        function out = runTraining(obj, cfg)
            %RUNTRAINING Execute training sub-pipeline.
            %   OUT = RUNTRAINING(OBJ, CFG) executes the training workflow
            %   using the supplied configuration CFG. CFG must be a fully
            %   processed configuration struct as returned by
            %   ConfigModel.process.
            ingestOut = obj.TrainingModel.ingest(cfg);
            [features, ~] = obj.TrainingModel.extractFeatures(ingestOut.Chunks);
            embeddings = obj.TrainingModel.computeEmbeddings(features);
            trainingInputs = struct('Embeddings', embeddings);
            [models, scores, thresholds, predLabels] = ...
                obj.TrainingModel.trainClassifier(trainingInputs);
            out = struct('Ingest', ingestOut, 'Features', features, ...
                'Embeddings', embeddings, 'Models', {models}, ...
                'Scores', scores, 'Thresholds', thresholds, ...
                'PredLabels', predLabels);
        end

        function out = runFineTune(obj, cfg)
            %RUNFINETUNE Execute encoder fine-tuning workflow.
            %   OUT = RUNFINETUNE(OBJ, CFG) performs encoder fine-tuning
            %   using the supplied configuration CFG. CFG must be a fully
            %   processed configuration struct as returned by
            %   ConfigModel.process.
            docs = obj.TrainingModel.ingest(cfg);
            chunks = obj.TrainingModel.chunk(docs);
            [weakLabels, bootLabels] = obj.TrainingModel.weakLabel(chunks);
            raw = struct('Chunks', chunks, 'WeakLabels', weakLabels, ...
                'BootLabels', bootLabels);
            triplets = obj.TrainingModel.prepareDataset(raw);
            net = obj.TrainingModel.fineTuneEncoder(triplets);
            out = struct('Triplets', triplets, 'Network', net);
        end

        function projected = runProjectionHead(obj, embeddings)
            %RUNPROJECTIONHEAD Train projection head on embeddings.
            %   PROJECTED = RUNPROJECTIONHEAD(obj, EMBEDDINGS) builds
            %   contrastive triplets and delegates training to
            %   TrainingModel.trainProjectionHead.

            triplets = obj.TrainingModel.prepareDataset(embeddings);
            projected = obj.TrainingModel.trainProjectionHead(triplets);
        end
    end
end
