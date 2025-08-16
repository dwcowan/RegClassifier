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
            arguments (Output)
                obj (1,1) reg.model.PipelineModel
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
            %   training, fine-tuning and evaluation input collation.
            %   RESULT is a struct with fields ``SearchIndex`` (struct with
            %   docId and embedding), ``Training`` (see RUNTRAINING output)
            %   and ``EvaluationInputs`` (struct with embeddings and labels).

            arguments
                obj
            end
            arguments (Output)
                result struct
                result.SearchIndex struct
                result.Training struct
                result.EvaluationInputs struct
            end

            % Step 1: load and process configuration
            % cfgRaw = ConfigModel.load();
            % cfg = ConfigModel.process(cfgRaw);

            % Step 2: ingest corpus and build search index
            % [documentsTbl, searchIndexStruct] = ingestCorpus(cfg);

            % Step 3: train models using the documents table
            % trainOut = runTraining(cfg, documentsTbl);

            % Step 4: optionally fine-tune model
            % if cfg.fineTuneEpochs > 0
            %     trainOut.FineTune = runFineTune(cfg);
            % end

            % Step 5: optionally project embeddings
            % if cfg.projEpochs > 0
            %     trainOut.ProjectedEmbeddings = runProjectionHead( ...
            %         trainOut.Embeddings);
            % end

            % Step 6: prepare evaluation inputs
            % evalInputs = evaluationInputs(trainOut);
            % result = struct('SearchIndex', searchIndexStruct, ...
            %     'Training', trainOut, ...
            %     'EvaluationInputs', evalInputs);

            error("reg:model:NotImplemented","PipelineModel.run is not implemented.");
        end

        function out = evaluationInputs(~, trainOut)
            %EVALUATIONINPUTS Collate embeddings and labels for evaluation.
            %   OUT = EVALUATIONINPUTS(trainOut) extracts the appropriate
            %   embeddings and optional label matrix from TRAINOUT in
            %   preparation for the EvaluationController. OUT is a struct
            %   with fields ``Embeddings`` (double matrix) and ``Labels``
            %   (double matrix, possibly empty).
            arguments
                ~
                trainOut struct
            end
            arguments (Output)
                out struct
                out.Embeddings double
                out.Labels double
            end
            % Extract evaluation embeddings from TRAINOUT, falling back to
            % projected embeddings when available.

            % Gather predicted labels from TRAINOUT if they were produced
            % during training.

            error("reg:model:NotImplemented", ...
                "PipelineModel.evaluationInputs is not implemented.");
        end

        function [documentsTbl, searchIndexStruct] = ingestCorpus(obj, cfg)
            %INGESTCORPUS Ingest PDFs, persist them and build the index.
            %   [DOCUMENTSTBL, SEARCHINDEXSTRUCT] = INGESTCORPUS(obj, cfg)
            %   reads PDFs into DOCUMENTSTBL, persists the table and
            %   prepares an index input struct containing an embedding
            %   matrix placeholder. The struct is forwarded to
            %   CorpusModel.buildIndex and the resulting search index
            %   structure is returned. DOCUMENTSTBL is provided so the same
            %   data can later be used for model training without an extra
            %   ingestion pass.
            %   Returns
            %       documentsTbl (table): ingested documents
            %       searchIndexStruct (struct): fields ``docId`` (string) and
            %           ``embedding`` (double matrix).
            arguments
                obj
                cfg (1,1) struct
            end
            arguments (Output)
                documentsTbl table
                searchIndexStruct struct
                searchIndexStruct.docId string
                searchIndexStruct.embedding double
            end
            % Step 1: ingest PDF documents into a table
            % documentsTbl = CorpusModel.ingestPdfs(cfg);

            % Step 2: persist the ingested documents
            % CorpusModel.persistDocuments(documentsTbl);

            % Step 3: build a search index structure from documents
            % indexInputsStruct = struct('documentsTbl', documentsTbl, ...
            %     'embeddingsMat', zeros(height(documentsTbl), 0));
            % searchIndexStruct = CorpusModel.buildIndex(indexInputsStruct);

            error("reg:model:NotImplemented", ...
                "PipelineModel.ingestCorpus is not implemented.");
        end

        function results = exampleSearch(obj, queryString, alpha, topK)
            %EXAMPLESEARCH Run a sample query against the search index.
            %   RESULTS = EXAMPLESEARCH(obj, queryString, alpha, topK)
            %   delegates to CorpusModel.queryIndex. Default parameters are
            %   provided for debugging convenience. RESULTS is a table with
            %   columns ``docId``, ``score`` and ``rank``.
            arguments
                obj
                queryString (1,1) string = "pipeline query"
                alpha (1,1) double = 0.5
                topK (1,1) double = 5
            end
            arguments (Output)
                results table
            end
            results = obj.CorpusModel.queryIndex(queryString, alpha, topK);
        end

        function out = runTraining(obj, cfg, documentsTbl)
            %RUNTRAINING Execute training sub-pipeline.
            %   OUT = RUNTRAINING(OBJ, CFG, DOCUMENTSTBL) executes the
            %   training workflow using the supplied configuration CFG and
            %   pre-ingested DOCUMENTSTBL. CFG must be a fully processed
            %   configuration struct as returned by ConfigModel.process.
            %   DOCUMENTSTBL should typically be the same table produced
            %   during indexing via ``ingestCorpus`` so ingestion only
            %   occurs once for both indexing and training. OUT is a struct
            %   with fields ``DocumentsTbl`` (table), ``ChunksTbl`` (table),
            %   ``FeaturesTbl`` (table), ``Embeddings`` (double matrix),
            %   ``Models`` (cell), ``Scores`` (double matrix),
            %   ``Thresholds`` (double vector) and ``PredLabels`` (double
            %   matrix).
            arguments
                obj
                cfg (1,1) struct
                documentsTbl table
            end
            arguments (Output)
                out struct
                out.DocumentsTbl table
                out.ChunksTbl table
                out.FeaturesTbl table
                out.Embeddings double
                out.Models cell
                out.Scores double
                out.Thresholds double
                out.PredLabels double
            end
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
            %   ConfigModel.process. OUT is a struct with fields
            %   ``TripletsTbl`` (table) and ``Network`` (struct placeholder
            %   for encoder).
            arguments
                obj
                cfg (1,1) struct
            end
            arguments (Output)
                out struct
                out.TripletsTbl table
                out.Network struct
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
            %   TrainingModel.trainProjectionHead. PROJECTED is a double
            %   matrix of projected embeddings.

            arguments
                obj
                embeddings double
            end
            arguments (Output)
                projected double
            end

            tripletsTbl = obj.TrainingModel.prepareDataset(struct('Embeddings', embeddings));
            projected = obj.TrainingModel.trainProjectionHead(tripletsTbl);
        end
    end
end
