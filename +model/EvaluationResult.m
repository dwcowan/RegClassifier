classdef EvaluationResult
    %EVALUATIONRESULT Value object for metric summaries.

    properties
        Metrics
    end

    methods
        function obj = EvaluationResult(metrics)
            if nargin > 0
                obj.Metrics = metrics;
            end
        end
    end
end
