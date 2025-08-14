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
            obj@reg.mvc.BaseController(featureModel, view);
            obj.FeatureModel = featureModel;
            obj.FineTuneDataModel = dataModel;
            obj.ProjectionHeadModel = headModel;
            obj.EvaluationModel = evalModel;
        end
        
        function run(obj)
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
