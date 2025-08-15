classdef TestPipelineController < matlab.unittest.TestCase
    %TESTPIPELINECONTROLLER Ensure PipelineController propagates NotImplemented.

    properties
        Controller
    end

    methods(TestMethodSetup)
        function setup(tc)
            cfgModel = reg.model.ConfigModel();
            cfgSvc = reg.service.ConfigService(cfgModel);
            ingestSvc = IngestStub();
            embSvc = reg.service.EmbeddingService(cfgSvc);
            evalSvc = reg.service.EvaluationService(cfgSvc);
            logModel = reg.model.LoggingModel();
            view = reg.view.ReportView();
            tc.Controller = reg.controller.PipelineController(cfgSvc, ingestSvc, embSvc, evalSvc, logModel, view);
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
