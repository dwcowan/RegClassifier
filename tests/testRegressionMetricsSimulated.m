%% NAME-REGISTRY:TEST testRegressionMetricsSimulated
function tests = testRegressionMetricsSimulated
%TESTREGRESSIONMETRICSSIMULATED Placeholder tests for regression metrics.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(testCase)
    reg.trainMultilabel([], []);
    reg.evalPerLabel([], []);
    testCase.assumeFail('Not implemented yet');
end
