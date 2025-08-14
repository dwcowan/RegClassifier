classdef ProjectionHeadController < reg.mvc.BaseController
    %PROJECTIONHEADCONTROLLER Orchestrates projection head training workflow.
    
    properties
        FeatureModel
        FineTuneDataModel
        ProjectionHeadModel
        EvaluationModel
    end
    
    methods
        function obj = ProjectionHeadController(featureModel, dataModel, headModel, evalModel, view)
            %PROJECTIONHEADCONTROLLER Construct controller wiring models.
            %   OBJ = PROJECTIONHEADCONTROLLER(featureModel, dataModel,
            %   headModel, evalModel, view) sets up the projection head
            %   training workflow. Equivalent to `reg_projection_workflow`
            %   setup.
            obj@reg.mvc.BaseController(featureModel, view);
            obj.FeatureModel = featureModel;
            obj.FineTuneDataModel = dataModel;
            obj.ProjectionHeadModel = headModel;
            obj.EvaluationModel = evalModel;
        end

        function run(obj)
            %RUN Execute projection head training and evaluation.
            %   Equivalent to `reg_projection_workflow`.
            chunks = obj.FeatureModel.load(); %#ok<NASGU>
            [features, embeddings, vocab] = obj.FeatureModel.process([]); %#ok<NASGU>
            tripletsRaw = obj.FineTuneDataModel.load(); %#ok<NASGU>
            triplets = obj.FineTuneDataModel.process([]); %#ok<NASGU>
            headRaw = obj.ProjectionHeadModel.load(); %#ok<NASGU>
            projE = obj.ProjectionHeadModel.process([]); %#ok<NASGU>
            evalRaw = obj.EvaluationModel.load(); %#ok<NASGU>
            metrics = obj.EvaluationModel.process([]); %#ok<NASGU>
            obj.View.display(metrics);
        end
    end
end
