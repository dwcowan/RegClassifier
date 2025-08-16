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

            % Step 4: fine-tuning workflow
            ftOut = obj.runFineTune(cfg); %#ok<NASGU>

            % Step 5: evaluation
            evalRaw = obj.EvaluationModel.load(trainOut.Embeddings, []);
            evalResult = obj.EvaluationModel.process(evalRaw);

            result = struct('Documents', docs, ...
                'Training', trainOut, ...
                'Metrics', evalResult.Metrics);
        end

        function docs = ingestCorpus(obj, cfg)
            %INGESTCORPUS Ingest PDFs and build search index.
            docs = obj.CorpusModel.ingestPdfs(cfg);
            obj.CorpusModel.persistDocuments(docs);
            obj.CorpusModel.buildIndex(docs);
            obj.CorpusModel.queryIndex("pipeline query", 0.5, 5);
        end

        function out = runTraining(obj, cfg)
            %RUNTRAINING Execute training sub-pipeline.
            if nargin < 2 || isempty(cfg)
                cfgRaw = obj.ConfigModel.load();
                cfg = obj.ConfigModel.process(cfgRaw);
            end
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
            if nargin < 2 || isempty(cfg)
                cfgRaw = obj.ConfigModel.load();
                cfg = obj.ConfigModel.process(cfgRaw);
            end
            docs = obj.TrainingModel.ingest(cfg);
            chunks = obj.TrainingModel.chunk(docs);
            [weakLabels, bootLabels] = obj.TrainingModel.weakLabel(chunks);
            raw = struct('Chunks', chunks, 'WeakLabels', weakLabels, ...
                'BootLabels', bootLabels);
            triplets = obj.TrainingModel.prepareDataset(raw);
            net = obj.TrainingModel.fineTuneEncoder(triplets);
            out = struct('Triplets', triplets, 'Network', net);
        end
    end
end
