classdef ProjectionHeadController < reg.mvc.BaseController
    %PROJECTIONHEADCONTROLLER Orchestrates projection head training workflow.

    properties
        FeatureModel
        EmbeddingModel
        TrainingModel
        EvaluationModel
    end

    methods
        function obj = ProjectionHeadController(featureModel, embeddingModel, trainModel, evalModel, view)
            %PROJECTIONHEADCONTROLLER Construct controller wiring models.
            %   OBJ = PROJECTIONHEADCONTROLLER(featureModel, embeddingModel,
            %   trainModel, evalModel, view) sets up the projection head
            %   training workflow using the unified TrainingModel. Equivalent
            %   to `reg_projection_workflow` setup.
            obj@reg.mvc.BaseController(featureModel, view);
            obj.FeatureModel = featureModel;
            obj.EmbeddingModel = embeddingModel;
            obj.TrainingModel = trainModel;
            obj.EvaluationModel = evalModel;
        end

        function run(obj)
            %RUN Execute projection head training and evaluation.
            %   Orchestrates feature extraction, triplet building, head
            %   training and metric computation.
            %
            %   Preconditions
            %       * FeatureModel supplies chunk text
            %       * EmbeddingModel computes dense embeddings
            %       * TrainingModel builds triplets and trains projection head
            %   Side Effects
            %       * Projection head parameters may be persisted
            %       * Evaluation metrics displayed via view
            %
            %   Legacy mapping:
            %       Step 1 ↔ `precompute_embeddings`
            %       Step 3 ↔ `ft_build_contrastive_dataset`
            %       Step 5 ↔ `train_projection_head`
            %       Step 7 ↔ `eval_retrieval`

            % Step 1: load chunks and extract features
            chunks = obj.FeatureModel.load();
            [features, vocab] = obj.FeatureModel.process(chunks); %#ok<NASGU>

            % Step 1b: compute embeddings from features
            embedRaw = obj.EmbeddingModel.load(features);
            embeddings = obj.EmbeddingModel.process(embedRaw);
            %   Expect FeatureModel/EmbeddingModel to validate chunk schema and
            %   handle tokenizer or embedding errors internally.

            % Step 3: construct contrastive triplets from embeddings
            %   TrainingModel should ensure non-empty triplets and balanced
            %   sampling.
            triplets = obj.TrainingModel.prepareDataset(embeddings.Vectors);

            % Step 5: train projection head using triplets
            %   TrainingModel should check dimensions and raise if triplets malformed.
            %   Potential Failure Modes
            %       * GPU out-of-memory during training batches.
            %       * Triplet indices outside embedding range.
            %       * Diverging loss due to extreme hyper‑parameters.
            %   Mitigation
            %       * Catch errors and retry on CPU or with reduced batch size.
            %       * Validate triplet indices before invoking the model.
            %       * Expose learning-rate and margin safeguards.
            projE = obj.TrainingModel.trainProjectionHead(triplets);

            % Step 7: evaluate retrieval performance with projected vectors
            evalRaw = obj.EvaluationModel.load(projE);
            evalResult = obj.EvaluationModel.process(evalRaw);
            obj.View.display(evalResult.Metrics);
        end
    end
end
