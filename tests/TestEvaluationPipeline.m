classdef TestEvaluationPipeline < RegTestCase
    % Validate that EvaluationPipeline orchestrates controller and view.

    methods (Test)
        function run_pipeline(tc)
            view = reg.view.ReportView();
            ctrl = reg.controller.EvaluationController();
            pipe = reg.controller.EvaluationPipeline(ctrl, view);
            % Minimal metrics history for trend chart
            csv = fullfile(tempdir, 'metrics.csv');
            T = table((1:2)', rand(2,1), 'VariableNames', {'Epoch','RecallAt10'});
            writetable(T, csv);
            pipe.run('gold', csv);
            tc.verifyTrue(isfield(view.DisplayedData, 'summaryTables'));
            tc.verifyTrue(isfield(view.DisplayedData, 'trendCharts'));
        end
    end
end
