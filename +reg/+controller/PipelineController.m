classdef PipelineController < reg.mvc.BaseController
    %PIPELINECONTROLLER Orchestrates end-to-end pipeline flow.

    properties
        % PipelineModel (reg.model.PipelineModel): coordinates lower level
        %   models.  Expected to expose methods ``run``, ``runFineTune``,
        %   ``runProjectionHead`` and ``runTraining`` returning structs.
        PipelineModel reg.model.PipelineModel
    end

    methods
        function obj = PipelineController(pipelineModel, view)
            %PIPELINECONTROLLER Construct controller wiring pipeline model.
            arguments
                obj (1,1) reg.controller.PipelineController
                pipelineModel reg.model.PipelineModel
                view reg.view.MetricsView = reg.view.MetricsView()
            end
            arguments (Output)
                obj (1,1) reg.controller.PipelineController
            end
            %{
            % Pseudocode:
            %
            % obj@reg.mvc.BaseController(pipelineModel, view);
            % obj.PipelineModel = pipelineModel;
            %}
            error("reg:controller:NotImplemented", ...
                "PipelineController constructor is not implemented.");
        end

        function result = runFineTune(obj, cfg)
            %RUNFINETUNE Execute encoder fine-tuning workflow.
            %   RESULT = RUNFINETUNE(obj, CFG) delegates the fine-tuning
            %   process to the PipelineModel using the supplied processed
            %   configuration CFG and displays any outputs using the
            %   controller view. RESULT is a struct with fields:
            %       TripletsTbl table [n x ?]  - dataset of contrastive triplets
            %       Network     struct [1 x 1] - placeholder encoder network
            arguments
                obj (1,1) reg.controller.PipelineController
                cfg (1,1) struct
            end
            arguments (Output)
                result (1,1) struct
            end
            %{
            % Pseudocode:
            %
            % result = obj.PipelineModel.runFineTune(cfg);
            % if obj.View is available
            %     obj.View.display(result);
            % end
            %}
            error("reg:controller:NotImplemented", ...
                "PipelineController.runFineTune is not implemented.");
        end

        function projected = runProjectionHead(obj, embeddings)
            %RUNPROJECTIONHEAD Train projection head on embeddings.
            %   PROJECTED = RUNPROJECTIONHEAD(obj, EMBEDDINGS) delegates
            %   projection head training to the PipelineModel and displays
            %   the resulting embeddings using the controller view.
            arguments
                obj (1,1) reg.controller.PipelineController
                embeddings double
            end
            arguments (Output)
                projected double
            end
            %{
            % Pseudocode:
            %
            % projected = obj.PipelineModel.runProjectionHead(embeddings);
            % if obj.View is available
            %     obj.View.display(projected);
            % end
            %}
            error("reg:controller:NotImplemented", ...
                "PipelineController.runProjectionHead is not implemented.");
        end

        function run(obj)
            %RUN Execute the full pipeline end-to-end.
            arguments
                obj (1,1) reg.controller.PipelineController
            end
            %{
            % Pseudocode:
            %
            % result = obj.PipelineModel.run();
            % if metrics should be computed
            %     metrics = evaluate result via EvaluationController
            %     if obj.View is available
            %         obj.View.log(metrics);
            %         obj.View.display(metrics);
            %     end
            % elseif obj.View is available
            %     obj.View.display(result);
            % end
            %}

            error("reg:controller:NotImplemented", ...
                "PipelineController.run is not implemented.");
        end

        function result = runTraining(obj, cfg, documentsTbl)
            %RUNTRAINING Execute only the training workflow.
            %   RESULT = RUNTRAINING(OBJ, CFG, DOCUMENTSTBL) delegates the
            %   workflow to the PipelineModel using the supplied processed
            %   configuration CFG and pre-ingested DOCUMENTSTBL, then
            %   displays the results using the controller view. RESULT is a
            %   struct with fields:
            %       DocumentsTbl table [n x ?]   - original documents
            %       ChunksTbl    table [c x ?]   - document chunks
            %       FeaturesTbl  table [c x ?]   - extracted features
            %       Embeddings   double [c x d] - embedding matrix
            %       Models       cell   [1 x m] - trained model objects
            %       Scores       double [c x m] - classifier scores
            %       Thresholds   double [1 x m] - decision thresholds
            %       PredLabels   double [c x m] - predicted labels
            arguments
                obj (1,1) reg.controller.PipelineController
                cfg (1,1) struct
                documentsTbl table
            end
            arguments (Output)
                result (1,1) struct
            end
            %{
            % Pseudocode:
            %
            % result = obj.PipelineModel.runTraining(cfg, documentsTbl);
            % if obj.View is available
            %     obj.View.display(result);
            % end
            %}
            error("reg:controller:NotImplemented", ...
                "PipelineController.runTraining is not implemented.");
        end
    end
end
