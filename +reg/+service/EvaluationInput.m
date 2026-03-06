classdef EvaluationInput
    %EVALUATIONINPUT Container for artifacts needed to compute metrics.

    properties
        Predictions
        References
    end

    methods
        function obj = EvaluationInput(pred, ref)
            if nargin > 0
                obj.Predictions = pred;
            end
            if nargin > 1
                obj.References = ref;
            end
        end
    end
end

