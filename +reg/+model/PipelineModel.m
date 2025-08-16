classdef PipelineModel < reg.mvc.BaseModel
    %PIPELINEMODEL Encapsulate full pipeline coordination.
    %   Handles configuration loading, corpus ingestion, feature and
    %   embedding extraction, classifier training, encoder fine-tuning
    %   and evaluation. Internal steps delegate to specialised models
    %   such as ConfigModel, CorpusModel, TrainingModel and
    %   EvaluationModel.

    properties
        % ConfigModel: supplies configuration defaults and validation
        ConfigModel reg.model.ConfigModel

        % TrainingModel: handles ingestion, chunking and classifier training
        TrainingModel reg.model.TrainingModel

        % CorpusModel: provides corpus ingestion and search indexing
        CorpusModel reg.model.CorpusModel

        % EvaluationModel: computes evaluation metrics
        EvaluationModel reg.model.EvaluationModel
    end

    methods
        function obj = PipelineModel(cfgModel, corpusModel, trainModel, evalModel)
            %PIPELINEMODEL Construct pipeline model wiring core models.
            arguments
                cfgModel reg.model.ConfigModel = reg.model.ConfigModel()
                corpusModel reg.model.CorpusModel = reg.model.CorpusModel()
                trainModel reg.model.TrainingModel = reg.model.TrainingModel()
                evalModel reg.model.EvaluationModel = reg.model.EvaluationModel()
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
            %   training, fine-tuning and evaluation. RESULT is a struct
            %   with fields ``SearchIndex``, ``Training`` and ``Metrics``.

            arguments
                obj
            end

            % Step 1: configuration
            cfgRaw = obj.ConfigModel.load();
            cfg = obj.ConfigModel.process(cfgRaw);

            % Step 2: corpus ingestion and index build
            searchIndexStruct = obj.ingestCorpus(cfg);

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

            result = struct('SearchIndex', searchIndexStruct, ...
                'Training', trainOut, ...
                'Metrics', metrics);
        end

        function searchIndexStruct = ingestCorpus(obj, cfg)
            %INGESTCORPUS Ingest PDFs, persist them and build the index.
            %   searchIndexStruct = INGESTCORPUS(obj, cfg) reads PDFs into a
            %   document table, persists the table and prepares an index
            %   input struct containing an embedding matrix placeholder.
            %   The struct is forwarded to CorpusModel.buildIndex and the
            %   resulting search index structure is returned.
            %   Returns
            %       searchIndexStruct (struct): fields ``docId`` and
            %           ``embedding`` as produced by CorpusModel.buildIndex.
            arguments
                obj
                cfg (1,1) struct
            end
            documentsTbl = obj.CorpusModel.ingestPdfs(cfg);
            obj.CorpusModel.persistDocuments(documentsTbl);
            indexInputsStruct = struct( ...
                'documentsTbl', documentsTbl, ...
                'embeddingsMat', zeros(height(documentsTbl), 0));
            searchIndexStruct = obj.CorpusModel.buildIndex(indexInputsStruct);
        end

        function results = exampleSearch(obj, queryString, alpha, topK)
            %EXAMPLESEARCH Run a sample query against the search index.
            %   RESULTS = EXAMPLESEARCH(obj, queryString, alpha, topK)
            %   delegates to CorpusModel.queryIndex. Default parameters are
            %   provided for debugging convenience.
            arguments
                obj
                queryString (1,1) string = "pipeline query"
                alpha (1,1) double = 0.5
                topK (1,1) double = 5
            end
            results = obj.CorpusModel.queryIndex(queryString, alpha, topK);
        end

        function out = runTraining(obj, cfg)
            %RUNTRAINING Execute training sub-pipeline.
            %   OUT = RUNTRAINING(OBJ, CFG) executes the training workflow
            %   using the supplied configuration CFG. CFG must be a fully
            %   processed configuration struct as returned by
            %   ConfigModel.process.
            arguments
                obj
                cfg (1,1) struct
            end
            documentsTbl = obj.TrainingModel.ingest(cfg);
            chunksTbl = obj.TrainingModel.chunk(documentsTbl);
            [featuresTbl, ~] = obj.TrainingModel.extractFeatures(chunksTbl);
            embeddingsMat = obj.TrainingModel.computeEmbeddings(featuresTbl);
            trainingInputs = struct('Embeddings', embeddingsMat);
            [modelsCell, scoresMat, thresholdsVec, predLabelsMat] = ...
                obj.TrainingModel.trainClassifier(trainingInputs);
            out = struct('DocumentsTbl', documentsTbl, ...
                'ChunksTbl', chunksTbl, 'FeaturesTbl', featuresTbl, ...
                'Embeddings', embeddingsMat, 'Models', {modelsCell}, ...
                'Scores', scoresMat, 'Thresholds', thresholdsVec, ...
                'PredLabels', predLabelsMat);
        end

        function out = runFineTune(obj, cfg)
            %RUNFINETUNE Execute encoder fine-tuning workflow.
            %   OUT = RUNFINETUNE(OBJ, CFG) performs encoder fine-tuning
            %   using the supplied configuration CFG. CFG must be a fully
            %   processed configuration struct as returned by
            %   ConfigModel.process.
            arguments
                obj
                cfg (1,1) struct
            end
            documentsTbl = obj.TrainingModel.ingest(cfg);
            chunksTbl = obj.TrainingModel.chunk(documentsTbl);
            [weakLabelsMat, bootLabelsMat] = obj.TrainingModel.weakLabel(chunksTbl);
            rawStruct = struct('Chunks', chunksTbl, 'WeakLabels', weakLabelsMat, ...
                'BootLabels', bootLabelsMat);
            tripletsTbl = obj.TrainingModel.prepareDataset(rawStruct);
            net = obj.TrainingModel.fineTuneEncoder(tripletsTbl);
            out = struct('TripletsTbl', tripletsTbl, 'Network', net);
        end

        function projected = runProjectionHead(obj, embeddings)
            %RUNPROJECTIONHEAD Train projection head on embeddings.
            %   PROJECTED = RUNPROJECTIONHEAD(obj, EMBEDDINGS) builds
            %   contrastive triplets and delegates training to
            %   TrainingModel.trainProjectionHead.

            arguments
                obj
                embeddings double
            end

            tripletsTbl = obj.TrainingModel.prepareDataset(struct('Embeddings', embeddings));
            projected = obj.TrainingModel.trainProjectionHead(tripletsTbl);
        end
    end
end
