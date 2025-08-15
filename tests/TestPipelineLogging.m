classdef TestPipelineLogging < RegTestCase
    %TESTPIPELINELOGGING Verify PipelineController logs metrics.

    properties
        Controller
        LogModel
    end

    methods(TestMethodSetup)
        function setup(tc)
            cfgModel   = ConfigStub();
            pdfModel   = PassThroughModel();
            chunkModel = PassThroughModel();
            featModel  = FeatureStub();
            projModel  = PassThroughModel();
            weakModel  = PassThroughModel();
            clsModel   = ClassifierStub();
            searchModel = PassThroughModel();
            dbModel    = PassThroughModel();
            tc.LogModel = LogSpyModel();
            reportModel = PassThroughModel();
            view       = SpyView();
            tc.Controller = reg.controller.PipelineController(cfgModel, pdfModel, chunkModel, featModel, projModel, weakModel, ...
                clsModel, searchModel, dbModel, tc.LogModel, reportModel, view);
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

classdef ConfigStub < handle
    methods
        function applySeeds(~), end
        function loadKnobs(~), end
        function validateKnobs(~), end
        function printActiveKnobs(~), end
        function cfg = load(~), cfg = []; end
        function cfg = process(~, cfgIn)
            cfg = cfgIn;
        end
    end
end

classdef PassThroughModel < handle
    methods
        function out = load(~, data)
            if nargin < 2, data = []; end
            out = data;
        end
        function out = process(~, data)
            out = data;
        end
    end
end

classdef FeatureStub < handle
    methods
        function data = load(~, ~)
            data = [];
        end
        function [features, embeddings, vocab] = process(~, ~)
            features = [];
            embeddings = [];
            vocab = [];
        end
    end
end

classdef ClassifierStub < handle
    methods
        function data = load(~, ~)
            data = [];
        end
        function [models, scores, thresholds, pred] = process(~, ~)
            models = [];
            scores = 42;
            thresholds = [];
            pred = [];
        end
    end
end

classdef LogSpyModel < handle
    properties
        Processed = {}
    end
    methods
        function dataOut = load(~, dataIn)
            dataOut = dataIn;
        end
        function process(obj, data)
            obj.Processed{end+1} = data;
        end
    end
end

classdef SpyView < handle
    properties
        Displayed
    end
    methods
        function display(obj, data)
            obj.Displayed = data;
        end
    end
end
