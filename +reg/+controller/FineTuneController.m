classdef FineTuneController < reg.mvc.BaseController
    %FINETUNECONTROLLER Orchestrates encoder fine-tuning workflow.

    properties
        TrainingModel
        EvaluationModel
    end

    methods
        function obj = FineTuneController(trainModel, evalModel, view)
            %FINETUNECONTROLLER Construct controller wiring models and view.
            %   OBJ = FINETUNECONTROLLER(trainModel, evalModel, view)
            %   assembles components for the fine-tuning workflow using the
            %   unified TrainingModel. Equivalent to
            %   `reg_finetune_encoder_workflow` setup.
            obj@reg.mvc.BaseController(trainModel, view);
            obj.TrainingModel = trainModel;
            obj.EvaluationModel = evalModel;
        end

        function triplets = buildTriplets(obj)
            %BUILDTRIPLETS Generate contrastive triplets via training model.
            %   TRIPLETS = BUILDTRIPLETS(obj) produces training triplets.
            %   Equivalent to `ft_build_contrastive_dataset`.

            docs = obj.TrainingModel.ingest();
            chunks = obj.TrainingModel.chunk(docs);
            [weakLabels, bootLabels] = obj.TrainingModel.weakLabel(chunks); %#ok<NASGU>
            raw = struct('Chunks', chunks, 'WeakLabels', weakLabels);
            triplets = obj.TrainingModel.prepareDataset(raw);
        end

        function net = trainEncoder(obj, triplets) %#ok<INUSD>
            %TRAINENCODER Fine-tune encoder given triplets.
            %   NET = TRAINENCODER(obj, triplets) returns a trained model.
            %   Equivalent to `ft_train_encoder`.
            net = obj.TrainingModel.fineTuneEncoder(triplets);
        end

        function metrics = evaluate(obj, net) %#ok<INUSD>
            %EVALUATE Compute evaluation metrics on fine-tuned encoder.
            %   METRICS = EVALUATE(obj, net) returns evaluation scores.
            %   Equivalent to `ft_eval`.
            raw = obj.EvaluationModel.load();
            result = obj.EvaluationModel.process(raw);
            metrics = result.Metrics;
        end

        function saveModel(~, net, varargin)
            %SAVEMODEL Persist fine-tuned encoder to disk.
            %   SAVEMODEL(obj, net, filename) saves the network to a MAT
            %   file. Equivalent to model saving in `ft_train_encoder`.

            error("NotImplemented: model checkpointing");

            % Pseudocode for future implementation:
            % checkpointDir = "./checkpoints";
            % if ~exist(checkpointDir, "dir")
            %     mkdir(checkpointDir);
            % end
            % if ~isempty(varargin)
            %     fileName = varargin{1};
            % else
            %     fileName = "fine_tuned_encoder.mat";
            % end
            % checkpointPath = fullfile(checkpointDir, fileName);
            % save(checkpointPath, "net", "-v7.3");
        end

        function run(obj)
            %RUN Execute full fine-tuning workflow.
            %   Coordinates triplet creation, encoder training, evaluation
            %   and model persistence.
            %
            %   Preconditions
            %       * TrainingModel provides ingestion, chunking and
            %         labeling capabilities
            %       * Disk should be writable for model checkpoint
            %   Side Effects
            %       * Trained encoder saved to MAT file
            %       * Metrics rendered via view
            %
            %   Legacy mapping:
            %       Step 1 ↔ `ft_build_contrastive_dataset`
            %       Step 2 ↔ `ft_train_encoder`
            %       Step 3 ↔ `ft_eval`

            % Step 1: build contrastive triplets from corpus using
            %   TrainingModel to ingest data, chunk text and generate
            %   weak labels. The TrainingModel should validate that
            %   triplets cover all labels.
            triplets = obj.buildTriplets();

            % Step 2: fine-tune encoder using triplets
            %   TrainingModel expected to handle empty or malformed
            %   triplets by raising informative errors.
            net = obj.trainEncoder(triplets);

            % Step 3: evaluate fine-tuned encoder
            %   Evaluation model verifies metric inputs and reports issues.
            metrics = obj.evaluate(net);

            % Step 4: persist model checkpoint
            obj.saveModel(net);

            % Step 5: display evaluation metrics
            obj.View.display(metrics);
        end
    end
end
