classdef TestFineTuneController < matlab.unittest.TestCase
    %TESTFINETUNECONTROLLER Ensure FineTuneController methods propagate stubs.

    properties
        Controller
    end

    methods(TestMethodSetup)
        function setup(tc)
            pdfModel = reg.model.PDFIngestModel();
            chunkModel = reg.model.TextChunkModel();
            weakModel = reg.model.WeakLabelModel();
            dataModel = reg.model.FineTuneDataModel();
            encoderModel = reg.model.EncoderFineTuneModel();
            evalModel = reg.model.EvaluationModel();
            view = reg.view.MetricsView();
            tc.Controller = reg.controller.FineTuneController(pdfModel, chunkModel, weakModel, dataModel, encoderModel, evalModel, view);
        end
    end

    methods(TestMethodTeardown)
        function teardown(tc)
            tc.Controller = [];
        end
    end

    methods(Test)
        function buildTripletsPropagates(tc)
            tc.verifyError(@() tc.Controller.buildTriplets(), 'reg:model:NotImplemented');
        end
        function trainEncoderPropagates(tc)
            tc.verifyError(@() tc.Controller.trainEncoder([]), 'reg:model:NotImplemented');
        end
        function saveModelRoundTrip(tc)
            net = struct('W', 1);
            tmp = [tempname '.mat'];
            tc.Controller.saveModel(net, tmp);
            S = load(tmp, 'net');
            tc.verifyEqual(S.net, net);
            delete(tmp);
        end
    end
end
