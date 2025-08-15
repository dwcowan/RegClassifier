classdef EvaluationModel < reg.mvc.BaseModel
    %EVALUATIONMODEL Compute evaluation metrics for model outputs.

    properties
        ConfigModel reg.model.ConfigModel
    end

    methods
        function obj = EvaluationModel(cfgModel)
            if nargin > 0
                obj.ConfigModel = cfgModel;
            end
        end

        function input = load(~, varargin)
            %LOAD Package predictions and references for evaluation.
            %   INPUT = LOAD(~, PRED, REF) returns a struct with fields
            %   ``Predictions`` and ``References`` capturing the supplied
            %   arrays.
            pred = [];
            ref = [];
            if numel(varargin) >= 1
                pred = varargin{1};
            end
            if numel(varargin) >= 2
                ref = varargin{2};
            end
            input = struct('Predictions', pred, 'References', ref);
        end

        function result = process(obj, input) %#ok<INUSD>
            %PROCESS Calculate evaluation metrics from INPUT.
            %   RESULT = PROCESS(obj, INPUT) returns a struct containing a
            %   ``Metrics`` field with evaluation scores.
            if ~isempty(obj.ConfigModel)
                cfgRaw = obj.ConfigModel.load();
                cfg = obj.ConfigModel.process(cfgRaw); %#ok<NASGU>
            end
            result = struct('Metrics', []);
            error("reg:model:NotImplemented", ...
                "EvaluationModel.process is not implemented.");
        end

        function perLabel = perLabelMetrics(~, embeddings, labelsLogical, k) %#ok<INUSD>
            %PERLABELMETRICS Compute per-label Recall@K.
            %   perLabel = PERLABELMETRICS(embeddings, labelsLogical, k)
            %   should return a table capturing recall scores for each
            %   label.  ``embeddings`` is an N-by-D matrix of document
            %   vectors, ``labelsLogical`` is an N-by-L logical matrix of
            %   label assignments and ``k`` denotes the retrieval cutoff.
            %   The returned table is expected to contain the columns
            %   ``LabelIdx``, ``RecallAtK`` and ``Support``.
            %
            %   This method replaces the former PerLabelEvalModel.process.
            error("reg:model:NotImplemented", ...
                "EvaluationModel.perLabelMetrics is not implemented.");
        end

        function metrics = clusteringMetrics(~, embeddings, labelsLogical, k) %#ok<INUSD>
            %CLUSTERINGMETRICS Evaluate clustering quality of embeddings.
            %   metrics = CLUSTERINGMETRICS(embeddings, labelsLogical, k)
            %   should perform k-means clustering on ``embeddings`` and
            %   derive purity and silhouette scores against
            %   ``labelsLogical``.  ``k`` specifies the number of
            %   clusters.  The expected output is a struct with fields
            %   ``purity``, ``silhouette`` and ``idx`` containing cluster
            %   assignments.
            %
            %   This method consolidates the former ClusteringEvalModel.
            error("reg:model:NotImplemented", ...
                "EvaluationModel.clusteringMetrics is not implemented.");
        end

        function [M, order] = coRetrievalMatrix(~, embeddings, labelMatrix, k) %#ok<INUSD>
            %CORETRIEVALMATRIX Derive label co-retrieval frequencies.
            %   [M, order] = CORETRIEVALMATRIX(embeddings, labelMatrix, k)
            %   should compute the pairwise co-retrieval matrix for the
            %   provided ``embeddings`` and ``labelMatrix`` using a
            %   top-``k`` neighbour search.  ``M`` is an L-by-L matrix of
            %   co-retrieval rates where rows sum to one and ``order``
            %   captures the column permutation applied to labels.
            %
            %   This method supersedes the CoRetrievalMatrixModel.
            error("reg:model:NotImplemented", ...
                "EvaluationModel.coRetrievalMatrix is not implemented.");
        end
    end
end
