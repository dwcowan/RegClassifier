classdef TestEvaluationPipeline < matlab.unittest.TestCase
    %TESTEVALUATIONPIPELINE Verify pipeline orchestrates controller and view.

    methods(Test)
        function runInvokesVisualization(tc)
            % Set up stubbed controller, visualization model and view
            viz  = StubVizModel();
            ctrl = StubEvalController(viz);
            metricsView = SpyView();
            plotView = SpyView();

            % Execute pipeline
            pipe = reg.controller.EvaluationPipeline(ctrl, metricsView, plotView);
            pipe.run('goldDir', 'metrics.csv');

            % Controller should evaluate gold pack
            tc.verifyTrue(ctrl.EvalCalled);

            % Visualization model should receive metrics CSV
            tc.verifyEqual(viz.TrendsArgs{1}, 'metrics.csv');

            % Plot view should be handed paths to generated plots
            tc.verifyEqual(plotView.DisplayedData.TrendsPNG, ...
                fullfile(tempdir(), 'trends.png'));
            tc.verifyEqual(plotView.DisplayedData.HeatmapPNG, ...
                fullfile(tempdir(), 'heatmap.png'));

            % Metrics view should receive evaluation results
            tc.verifyTrue(isstruct(metricsView.DisplayedData));
        end
    end
end

classdef StubEvalController < handle
    properties
        VisualizationModel
        EvalCalled = false
    end
    methods
        function obj = StubEvalController(viz)
            obj.VisualizationModel = viz;
        end
        function results = evaluateGoldPack(obj, ~)
            obj.EvalCalled = true;
            results.embeddings = 1;
            results.labelMatrix = 1;
            results.labels = {'A'};
        end
    end
end

classdef StubVizModel < handle
    properties
        TrendsArgs
        HeatArgs
    end
    methods
        function path = plotTrends(obj, csvPath, pngPath)
            obj.TrendsArgs = {csvPath, pngPath};
            path = pngPath;
        end
        function path = plotCoRetrievalHeatmap(obj, embeddings, labelMatrix, pngPath, labels)
            %#ok<INUSD>
            obj.HeatArgs = {embeddings, labelMatrix, pngPath, labels};
            path = pngPath;
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

