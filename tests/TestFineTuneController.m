
classdef TestFineTuneController < RegTestCase
    %TESTFINETUNECONTROLLER Verify FineTuneController integrates models and view.

    properties
        Controller
        View

    end

    methods(TestMethodSetup)
        function setup(tc)

            pdfModel     = StubModel("files");
            chunkModel   = StubModel("chunks");
            weakModel    = StubModel("Yweak","Yboot");
            dataModel    = StubModel("triplets");
            encoderModel = StubModel("net");
            evalModel    = StubModel(struct('Accuracy',0.42));
            tc.View = SpyView();
            tc.Controller = reg.controller.FineTuneController(pdfModel, chunkModel, weakModel, dataModel, encoderModel, evalModel, tc.View);

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

classdef StubModel < handle
    properties
        ProcessOutputs
    end
    methods
        function obj = StubModel(varargin)
            obj.ProcessOutputs = varargin;
        end
        function varargout = load(~)
            varargout = cell(1,nargout);
            [varargout{:}] = deal([]);
        end
        function varargout = process(obj, ~)
            varargout = obj.ProcessOutputs;
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

