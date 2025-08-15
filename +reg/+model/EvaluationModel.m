classdef EvaluationModel < reg.mvc.BaseModel
    %EVALUATIONMODEL Stub model computing evaluation metrics.

    properties
        % Shared configuration reference
        cfg reg.model.ConfigModel = reg.model.ConfigModel();
    end

    methods
        function obj = EvaluationModel(cfg)
            %EVALUATIONMODEL Construct evaluation model.
            %   OBJ = EVALUATIONMODEL(cfg) provides access to evaluation
            %   options held in cfg, such as cfg.labels.
            if nargin > 0
                obj.cfg = cfg;
            end
        end

        function evaluationInputs = load(~, varargin) %#ok<INUSD>
            %LOAD Gather data required for evaluation.
            %   evaluationInputs = LOAD(obj) retrieves prediction and gold
            %   labels.
            %   Parameters
            %       varargin - Placeholder for future options (unused)
            %   Returns
            %       evaluationInputs (struct): Predictions and references.
            %   Side Effects
            %       None.
            %   Legacy Reference
            %       Equivalent to `eval_retrieval` data loading.
            %   Extension Point
            %       Override to compute additional derived signals.
            % Pseudocode:
            %   1. Load predictions and gold labels
            %   2. Package into evaluationInputs struct
            %   3. Return evaluationInputs
            error("reg:model:NotImplemented", ...
                "EvaluationModel.load is not implemented.");
        end
        function metricsStruct = process(~, evaluationInputs) %#ok<INUSD>
            %PROCESS Compute evaluation metrics.
            %   metricsStruct = PROCESS(obj, evaluationInputs) returns a
            %   struct of scores.
            %   Parameters
            %       evaluationInputs (struct): Predictions and references.
            %   Returns
            %       metricsStruct (struct): Calculated evaluation metrics.
            %   Side Effects
            %       May log metrics via callback.
            %   Legacy Reference
            %       Equivalent to `eval_retrieval`.
            %   Extension Point
            %       Add custom metrics or visualizations here.
            % Pseudocode:
            %   1. Compare predictions against gold labels
            %   2. Aggregate results into metricsStruct
            %   3. Return metricsStruct
            error("reg:model:NotImplemented", ...
                "EvaluationModel.process is not implemented.");
        end
    end
end
