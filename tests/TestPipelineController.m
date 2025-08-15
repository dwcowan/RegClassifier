classdef TestPipelineController < matlab.unittest.TestCase
    %TESTPIPELINECONTROLLER Ensure PipelineController propagates NotImplemented.
    
    properties
        Controller
    end
    
    methods(TestMethodSetup)
        function setup(tc)
            cfgModel = reg.model.ConfigModel();
            ingestSvc = IngestStub();
            embSvc = reg.service.EmbeddingService();
            evalSvc = reg.service.EvaluationService();
            logModel = reg.model.LoggingModel();
            view = reg.view.ReportView();
            tc.Controller = reg.controller.PipelineController(cfgModel, ingestSvc, embSvc, evalSvc, logModel, view);
        end
    end
    
    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];
        end
    end
    
    methods(Test)
        function runPropagatesNotImplemented(tc)
            tc.verifyError(@() tc.Controller.run(), 'reg:service:NotImplemented');
        end
    end
end

classdef IngestStub < handle
    methods
        function out = ingest(~, ~)
            out = reg.service.IngestionOutput([], [], []);
        end
    end
end
