classdef TestFineTuneController < RegTestCase
    %TESTFINETUNECONTROLLER Verify FineTuneController integrates models and view.

    properties
        Controller
        View

    end

    methods(TestMethodSetup)
        function setup(tc)

            pdfModel     = testhelpers.StubModel("files");
            chunkModel   = testhelpers.StubModel("chunks");
            weakModel    = testhelpers.StubModel("Yweak","Yboot");
            dataModel    = testhelpers.StubModel("triplets");
            encoderModel = testhelpers.StubModel("net");
            evalService  = testhelpers.StubService(struct('Accuracy',0.42));
            tc.View = testhelpers.SpyView();
            tc.Controller = reg.controller.FineTuneController(pdfModel, chunkModel, weakModel, dataModel, encoderModel, evalService, tc.View);

        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];

            tc.View = [];

        end
    end

    methods(Test)

        function runDisplaysMetrics(tc)
            tc.Controller.run();
            tc.verifyEqual(tc.View.DisplayedData.Accuracy, 0.42);
        end
    end
end
