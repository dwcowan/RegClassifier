classdef TestPipelineLogging < fixtures.RegTestCase
    %TESTPIPELINELOGGING Verify PipelineController logs metrics.

    properties
        Controller
        LogModel
    end

    methods(TestMethodSetup)
        function setup(tc)
            cfgModel   = testhelpers.ConfigStub();
            ingestSvc  = testhelpers.IngestStub();
            embedSvc   = testhelpers.EmbedStub();
            evalSvc    = testhelpers.EvalStub();
            tc.LogModel = testhelpers.LogSpyModel();
            view       = testhelpers.SpyView();
            tc.Controller = reg.controller.PipelineController(cfgModel, ingestSvc, embedSvc, evalSvc, tc.LogModel, view);
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];
            tc.LogModel = [];
        end
    end

    methods(Test)
        function runLogsTrainingMetrics(tc)
            tc.Controller.run();
            tc.verifyGreaterThanOrEqual(numel(tc.LogModel.Processed), 1);
            tc.verifyEqual(tc.LogModel.Processed{1}, 42);
        end
    end
end
