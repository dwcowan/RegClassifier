%% NAME-REGISTRY:TEST testRegressionMetricsSimulated
function tests = testRegressionMetricsSimulated
%TESTREGRESSIONMETRICSSIMULATED Placeholder tests for regression metrics.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTREGRESSIONMETRICSSIMULATEDCOMPUTESMETRICS Compute regression metrics on simulated data.
function testRegressionMetricsSimulatedComputesMetrics(testCase)
    reg.trainMultilabel([], []);
    reg.evalPerLabel([], []);
    testCase.assumeFail('Not implemented yet');
end
