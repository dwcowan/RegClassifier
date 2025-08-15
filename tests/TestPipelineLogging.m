classdef TestPipelineLogging < RegTestCase
    %TESTPIPELINELOGGING Verify PipelineController logs metrics.

    properties
        Controller
        LogModel
    end

    methods(TestMethodSetup)
        function setup(tc)
            cfgModel   = ConfigStub();
            ingestSvc  = IngestStub();
            embedSvc   = EmbedStub();
            evalSvc    = EvalStub();
            tc.LogModel = LogSpyModel();
            view       = SpyView();
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

classdef IngestStub < handle
    methods
        function out = ingest(~, ~)
            out = reg.service.IngestionOutput([], [], []);
        end
    end
end

classdef EmbedStub < handle
    methods
        function input = prepare(~, feats)
            input = reg.service.EmbeddingInput(feats);
        end
        function out = embed(~, input)
            out = reg.service.EmbeddingOutput(input.Features);
        end
    end
end

classdef EvalStub < handle
    methods
        function input = prepare(~, emb, ~)
            input = reg.service.EvaluationInput(emb, []);
        end
        function result = compute(~, input) %#ok<INUSD>
            result = reg.service.EvaluationResult(42);
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
