classdef TestModelStubs < matlab.unittest.TestCase
    %TESTMODELSTUBS Ensure stub models raise NotImplemented errors.
    
    properties (TestParameter)
        ModelClass = {
            'reg.model.ConfigModel',
            'reg.model.PDFIngestModel',
            'reg.model.TextChunkModel',
            'reg.model.FeatureModel',
            'reg.model.ProjectionHeadModel',
            'reg.model.WeakLabelModel',
            'reg.model.ClassifierModel',
            'reg.model.SearchIndexModel',
            'reg.model.DatabaseModel',
            'reg.model.ReportModel',
            'reg.model.FineTuneDataModel',
            'reg.model.EncoderFineTuneModel',
            'reg.model.EvaluationModel',
            'reg.model.LoggingModel',
            'reg.model.GoldPackModel'
        };
    end
    
    methods(Test)
        function loadNotImplemented(tc, ModelClass)
            model = feval(ModelClass);
            tc.verifyError(@() model.load(), 'reg:model:NotImplemented');
        end
        function processNotImplemented(tc, ModelClass)
            model = feval(ModelClass);
            tc.verifyError(@() model.process([]), 'reg:model:NotImplemented');
        end
        function searchQueryNotImplemented(tc)
            model = reg.model.SearchIndexModel();
            tc.verifyError(@() model.query("test", 0.5, 10), ...
                'reg:model:NotImplemented');
        end
    end
end
