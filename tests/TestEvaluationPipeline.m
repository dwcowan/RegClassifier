classdef TestEvaluationPipeline < matlab.unittest.TestCase
    %TESTEVALUATIONPIPELINE Verify pipeline orchestrates controller and view.

    methods(Test)
        function runInvokesVisualization(tc)
            % Set up stubbed controller, visualization model and view
            viz  = testhelpers.StubVizModel();
            ctrl = testhelpers.StubEvalController(viz);
            metricsView = testhelpers.SpyView();
            plotView = testhelpers.SpyView();

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
