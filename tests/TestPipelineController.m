classdef TestPipelineController < matlab.unittest.TestCase
    %TESTPIPELINECONTROLLER Ensure PipelineController propagates NotImplemented.
    
    properties
        Controller
    end
    
    methods(TestMethodSetup)
        function setup(tc)
            cfgModel = reg.mvc.model.ConfigModel();
            pdfModel = reg.mvc.model.PDFIngestModel();
            chunkModel = reg.mvc.model.TextChunkModel();
            featModel = reg.mvc.model.FeatureModel();
            projModel = reg.mvc.model.ProjectionHeadModel();
            weakModel = reg.mvc.model.WeakLabelModel();
            clsModel = reg.mvc.model.ClassifierModel();
            searchModel = reg.mvc.model.SearchIndexModel();
            dbModel = reg.mvc.model.DatabaseModel();
            reportModel = reg.mvc.model.ReportModel();
            view = reg.mvc.view.ReportView();
            tc.Controller = reg.mvc.controller.PipelineController(cfgModel, pdfModel, chunkModel, featModel, projModel, weakModel, clsModel, searchModel, dbModel, reportModel, view);
        end
    end
    
    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];
        end
    end
    
    methods(Test)
        function runPropagatesNotImplemented(tc)
            tc.verifyError(@() tc.Controller.run(), 'reg:mvc:model:NotImplemented');
        end
    end
end
