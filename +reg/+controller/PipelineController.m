classdef PipelineController < reg.mvc.BaseController
    %PIPELINECONTROLLER Orchestrates end-to-end pipeline flow.

    properties
        PipelineModel
    end

    methods
        function obj = PipelineController(pipelineModel, view)
            %PIPELINECONTROLLER Construct controller wiring pipeline model.
            if nargin < 2 || isempty(view)
                view = reg.view.MetricsView();
            end
            obj@reg.mvc.BaseController(pipelineModel, view);
            obj.PipelineModel = pipelineModel;
        end

        function net = runFineTune(obj, cfg)
            %RUNFINETUNE Execute encoder fine-tuning workflow.
            %   NET = RUNFINETUNE(obj, CFG) constructs triplets using the
            %   TrainingModel and delegates encoder fine-tuning to
            %   TrainingModel.fineTuneEncoder.

            docs = obj.PipelineModel.TrainingModel.ingest(cfg);
            chunks = obj.PipelineModel.TrainingModel.chunk(docs);
            [weakLabels, bootLabels] = obj.PipelineModel.TrainingModel.weakLabel(chunks); %#ok<NASGU>
            raw = struct('Chunks', chunks, 'WeakLabels', weakLabels, ...
                'BootLabels', bootLabels);
            triplets = obj.PipelineModel.TrainingModel.prepareDataset(raw);
            net = obj.PipelineModel.TrainingModel.fineTuneEncoder(triplets);
        end

        function projected = runProjectionHead(obj, embeddings)
            %RUNPROJECTIONHEAD Train projection head on embeddings.
            %   PROJECTED = RUNPROJECTIONHEAD(obj, EMBEDDINGS) builds contrastive
            %   triplets and delegates training to
            %   TrainingModel.trainProjectionHead.

            triplets = obj.PipelineModel.TrainingModel.prepareDataset(embeddings);
            projected = obj.PipelineModel.TrainingModel.trainProjectionHead(triplets);
        end

        function run(obj)
            %RUN Execute the full pipeline end-to-end.

            cfgRaw = obj.PipelineModel.ConfigModel.load();
            cfg = obj.PipelineModel.ConfigModel.process(cfgRaw);

            docs = obj.PipelineModel.ingestCorpus(cfg);
            trainOut = obj.PipelineModel.runTraining(cfg);

            if isfield(cfg, 'fineTuneEpochs') && cfg.fineTuneEpochs > 0
                trainOut.FineTune = obj.runFineTune(cfg);
            end

            if isfield(cfg, 'projEpochs') && cfg.projEpochs > 0
                trainOut.ProjectedEmbeddings = obj.runProjectionHead(trainOut.Embeddings);
            end

            evalEmbeddings = trainOut.Embeddings;
            if isfield(trainOut, 'ProjectedEmbeddings')
                evalEmbeddings = trainOut.ProjectedEmbeddings;
            end

            evalController = reg.controller.EvaluationController( ...
                obj.PipelineModel.EvaluationModel, reg.model.ReportModel());
            metrics = evalController.run(evalEmbeddings, []);

            result = struct('Documents', docs, 'Training', trainOut, ...
                'Metrics', metrics);

            if ~isempty(obj.View) && isfield(result, "Metrics")
                obj.View.log(result.Metrics);
                obj.View.display(result.Metrics);
            elseif ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function runTraining(obj)
            %RUNTRAINING Execute only the training workflow.
            result = obj.PipelineModel.runTraining();
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
