classdef VisualizationModelTest < matlab.unittest.TestCase
    methods (Test)
        function rejectsMalformedStruct(testCase)
            vm = reg.model.VisualizationModel();
            bad = struct();
            testCase.verifyError(@() vm.plotTrends(bad), ?MException);
        end
        function plotsValidMetrics(testCase)
            vm = reg.model.VisualizationModel();
            metrics = struct('epochs', (1:3)', ...
                             'accuracy', [0.5 0.6 0.7]', ...
                             'loss', [1.0 0.8 0.6]');
            fig = vm.plotTrends(metrics);
            testCase.verifyClass(fig, "matlab.ui.Figure");
            close(fig);
        end
    end
end
