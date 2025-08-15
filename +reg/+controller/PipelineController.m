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

        function run(obj)
            %RUN Execute simplified pipeline by delegating to model.
            result = obj.PipelineModel.run();
            if ~isempty(obj.View) && isfield(result, "Metrics")
                obj.View.log(result.Metrics);
                obj.View.display(result.Metrics);
            elseif ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
