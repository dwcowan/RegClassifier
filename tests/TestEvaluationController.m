classdef TestEvaluationController < RegTestCase

    %TESTEVALUATIONCONTROLLER Verify EvalController integrates models and view.

    properties
        Controller
        View
    end

    methods(TestMethodSetup)
        function setup(tc)
            evalService = StubService();
            logModel    = StubService();
            reportModel = StubService(struct('OutputPath','report.pdf'));
            tc.View = SpyView();
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

classdef StubService < handle
    properties
        ProcessOutput
    end
    methods
        function obj = StubService(out)
            if nargin < 1, out = []; end
            obj.ProcessOutput = out;
        end
        function data = prepare(~)
            data = [];
        end
        function out = compute(obj, ~)
            out = obj.ProcessOutput;
        end
    end
end

classdef SpyView < handle
    properties
        DisplayedData
    end
    methods
        function display(obj, data)
            obj.DisplayedData = data;
        end
    end
end

