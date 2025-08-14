classdef TestModelStubs < matlab.unittest.TestCase
    %TESTMODELSTUBS Ensure stub models raise NotImplemented errors.
    
    properties (TestParameter)
        ModelClass = {
            'reg.mvc.model.ConfigModel',
            'reg.mvc.model.PDFIngestModel',
            'reg.mvc.model.TextChunkModel',
            'reg.mvc.model.FeatureModel',
            'reg.mvc.model.ProjectionHeadModel',
            'reg.mvc.model.WeakLabelModel',
            'reg.mvc.model.ClassifierModel',
            'reg.mvc.model.SearchIndexModel',
            'reg.mvc.model.DatabaseModel',
            'reg.mvc.model.ReportModel',
            'reg.mvc.model.FineTuneDataModel',
            'reg.mvc.model.EncoderFineTuneModel',
            'reg.mvc.model.EvaluationModel',
            'reg.mvc.model.LoggingModel',
            'reg.mvc.model.GoldPackModel'
        };
    end
    
    methods(Test)
        function loadNotImplemented(tc, ModelClass)
            model = feval(ModelClass);
            tc.verifyError(@() model.load(), 'reg:mvc:model:NotImplemented');
        end
        function processNotImplemented(tc, ModelClass)
            model = feval(ModelClass);
            tc.verifyError(@() model.process([]), 'reg:mvc:model:NotImplemented');
        end
    end
end
