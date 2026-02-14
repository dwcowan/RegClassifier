classdef TestEvaluationController < RegTestCase

    %TESTEVALUATIONCONTROLLER Verify EvalController integrates models and view.

    properties
        Controller
        View
    end

    methods(TestMethodSetup)
        function setup(tc)
            evalService = testhelpers.StubService();
            logModel    = testhelpers.StubService();
            reportModel = testhelpers.StubService(struct('OutputPath','report.pdf'));
            tc.View = testhelpers.SpyView();
            tc.Controller = reg.controller.EvalController(evalService, logModel, reportModel, tc.View);
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];
            tc.View = [];
        end
    end

    methods(Test)
        function runDisplaysReport(tc)
            tc.Controller.run();
            tc.verifyEqual(tc.View.DisplayedData.OutputPath, 'report.pdf');
        end
    end
end

