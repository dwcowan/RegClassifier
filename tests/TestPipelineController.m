classdef TestPipelineController < matlab.unittest.TestCase
    %TESTPIPELINECONTROLLER Ensure PipelineController propagates NotImplemented.
    
    properties
        Controller
    end
    
    methods(TestMethodSetup)
        function setup(tc)
            cfgModel = reg.model.ConfigModel();
            pdfModel = reg.model.PDFIngestModel();
            chunkModel = reg.model.TextChunkModel();
            featModel = reg.model.FeatureModel();
            projModel = reg.model.ProjectionHeadModel();
            weakModel = reg.model.WeakLabelModel();
            clsModel = reg.model.ClassifierModel();
            searchModel = reg.model.SearchIndexModel();
            dbModel = reg.model.DatabaseModel();
            reportModel = reg.model.ReportModel();
            view = reg.view.ReportView();
            tc.Controller = reg.controller.PipelineController(cfgModel, pdfModel, chunkModel, featModel, projModel, weakModel, clsModel, searchModel, dbModel, reportModel, view);
        end
    end
    
    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];
        end
    end
    
    methods(Test)
        function runPropagatesNotImplemented(tc)
            tc.verifyError(@() tc.Controller.run(), 'reg:model:NotImplemented');
        end
    end
end
