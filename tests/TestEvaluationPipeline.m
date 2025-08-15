classdef TestEvaluationPipeline < matlab.unittest.TestCase
    %TESTEVALUATIONPIPELINE Ensure pipeline stub raises NotImplemented.

    methods (Test)
        function runNotImplemented(tc)
            view = reg.view.ReportView();
            ctrl = reg.controller.EvaluationController();
            pipe = reg.controller.EvaluationPipeline(ctrl, view);
            tc.verifyError(@() pipe.run('gold'), 'reg:controller:NotImplemented');
        end
    end
end
