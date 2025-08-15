classdef ProjectionHeadController < reg.mvc.BaseController
    %PROJECTIONHEADCONTROLLER Orchestrates projection head training workflow.
    
    properties
        FeatureModel
        EmbeddingModel
        FineTuneDataModel
        ProjectionHeadModel
        EvaluationModel
    end
    
    methods
        function obj = ProjectionHeadController(featureModel, embeddingModel, dataModel, headModel, evalModel, view)
            %PROJECTIONHEADCONTROLLER Construct controller wiring models.
            %   OBJ = PROJECTIONHEADCONTROLLER(featureModel, dataModel,
            %   headModel, evalModel, view) sets up the projection head
            %   training workflow. Equivalent to `reg_projection_workflow`
            %   setup.
            obj@reg.mvc.BaseController(featureModel, view);
            obj.FeatureModel = featureModel;
            obj.EmbeddingModel = embeddingModel;
            obj.FineTuneDataModel = dataModel;
            obj.ProjectionHeadModel = headModel;
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
            %       * FineTuneDataModel expects embeddings for triplet mining
            %       * ProjectionHeadModel consumes triplets to learn weights
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
            [embeddings, ~] = obj.EmbeddingModel.process(embedRaw); %#ok<NASGU>
            %   Expect FeatureModel/EmbeddingModel to validate chunk schema and
            %   handle tokenizer or embedding errors internally.

            % Step 3: construct contrastive triplets from embeddings
            %   The data model should ensure non-empty triplets and balanced
            %   sampling.
            tripletsRaw = obj.FineTuneDataModel.load(embeddings);
            triplets = obj.FineTuneDataModel.process(tripletsRaw);

            % Step 5: train projection head using triplets
            %   Model should check dimensions and raise if triplets malformed.
            %   Potential Failure Modes
            %       * GPU out-of-memory during training batches.
            %       * Triplet indices outside embedding range.
            %       * Diverging loss due to extreme hyper‑parameters.
            %   Mitigation
            %       * Catch errors and retry on CPU or with reduced batch size.
            %       * Validate triplet indices before invoking the model.
            %       * Expose learning-rate and margin safeguards.
            headRaw = obj.ProjectionHeadModel.load(triplets);
            projE = obj.ProjectionHeadModel.process(headRaw);

            % Step 7: evaluate retrieval performance with projected vectors
            evalRaw = obj.EvaluationModel.load(projE);
            metrics = obj.EvaluationModel.process(evalRaw);
            obj.View.display(metrics);
        end
    end
end
