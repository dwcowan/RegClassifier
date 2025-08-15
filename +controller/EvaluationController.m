classdef EvaluationController < reg.mvc.BaseController
    %EVALUATIONCONTROLLER Provide utilities for evaluation and reporting.
    %   This controller bundles common evaluation routines used across the
    %   project such as retrieval metrics and gold-pack evaluation.

    properties
        VisualizationModel reg.model.VisualizationModel = reg.model.VisualizationModel();
    end

    methods
        function obj = EvaluationController(model, view, vizModel)
            %EVALUATIONCONTROLLER Construct controller wiring model and view.
            obj@reg.mvc.BaseController(model, view);
            if nargin >= 3 && ~isempty(vizModel)
                obj.VisualizationModel = vizModel;
            end
        end

        function run(obj)
            %RUN Execute evaluation workflow.
            %   RUN(obj) loads data via the model, processes it and passes
            %   the results to the associated view for presentation.
            data = obj.Model.load();
            results = obj.Model.process(data);
            obj.View.display(results);
        end
        function metrics = retrievalMetrics(~, embeddings, posSets, k) %#ok<INUSD>
            %RETRIEVALMETRICS Compute retrieval metrics at K.
            %   METRICS = RETRIEVALMETRICS(embeddings, posSets, k) should
            %   produce Recall@K, mAP and nDCG scores for a set of embeddings
            %   and positive index sets.
            %   Legacy Reference
            %       Equivalent to `reg.eval_retrieval` and `reg.metrics_ndcg`.
            %   Pseudocode:
            %       1. For each query embedding compute similarity scores
            %       2. Derive recall, mAP and nDCG at K
            %       3. Return metrics struct
            error("reg:controller:NotImplemented", ...
                "EvaluationController.retrievalMetrics is not implemented.");
        end

        function results = evaluateGoldPack(obj, goldDir, opts) %#ok<INUSD>
            %EVALUATEGOLDPACK Run evaluation against a gold mini-pack.
            %   RESULTS = EVALUATEGOLDPACK(goldDir) should load gold
            %   artefacts, embed chunks and compute retrieval metrics overall
            %   and per label.
            %   Legacy Reference
            %       Equivalent to `reg_eval_gold`.
            %   Pseudocode:
            %       1. Load gold chunks and labels from goldDir
            %       2. Embed chunks and form positive sets
            %       3. Compute retrieval metrics and optional clustering
            %       4. Return struct with overall and per-label results
            error("reg:controller:NotImplemented", ...
                "EvaluationController.evaluateGoldPack is not implemented.");
        end
    end
end
