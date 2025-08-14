classdef TestEvaluationController < RegTestCase
    %TESTEVALUATIONCONTROLLER Verify EvalController integrates models and view.

    properties
        Controller
        View
    end

    methods(TestMethodSetup)
        function setup(tc)
            evalModel   = StubModel();
            logModel    = StubModel();
            reportModel = StubModel(struct('OutputPath','report.pdf'));
            tc.View = SpyView();
            tc.Controller = reg.controller.EvalController(evalModel, logModel, reportModel, tc.View);
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

classdef StubModel < handle
    properties
        ProcessOutput
    end
    methods
        function obj = StubModel(out)
            if nargin < 1, out = []; end
            obj.ProcessOutput = out;
        end
        function data = load(~)
            data = [];
        end
        function out = process(obj, ~)
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

