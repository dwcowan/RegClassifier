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

        function result = runFineTune(obj, cfg)
            %RUNFINETUNE Execute encoder fine-tuning workflow.
            %   RESULT = RUNFINETUNE(obj, CFG) delegates the fine-tuning
            %   process to the PipelineModel using the supplied processed
            %   configuration CFG and displays any outputs using the
            %   controller view.

            result = obj.PipelineModel.runFineTune(cfg);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function projected = runProjectionHead(obj, embeddings)
            %RUNPROJECTIONHEAD Train projection head on embeddings.
            %   PROJECTED = RUNPROJECTIONHEAD(obj, EMBEDDINGS) delegates
            %   projection head training to the PipelineModel and displays
            %   the resulting embeddings using the controller view.

            projected = obj.PipelineModel.runProjectionHead(embeddings);
            if ~isempty(obj.View)
                obj.View.display(projected);
            end
        end

        function run(obj)
            %RUN Execute the full pipeline end-to-end.

            result = obj.PipelineModel.run();

            if ~isempty(obj.View) && isfield(result, "Metrics")
                obj.View.log(result.Metrics);
                obj.View.display(result.Metrics);
            elseif ~isempty(obj.View)
                obj.View.display(result);
            end
        end

        function runTraining(obj, cfg)
            %RUNTRAINING Execute only the training workflow.
            %   RUNTRAINING(OBJ, CFG) delegates the workflow to the
            %   PipelineModel using the supplied processed configuration
            %   CFG and displays the results using the controller view.
            result = obj.PipelineModel.runTraining(cfg);
            if ~isempty(obj.View)
                obj.View.display(result);
            end
        end
    end
end
