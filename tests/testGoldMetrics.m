%% NAME-REGISTRY:TEST testGoldMetrics
function tests = testGoldMetrics
%TESTGOLDMETRICS Placeholder tests for gold data metrics.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTGOLDMETRICSEVALUATESGOLD Evaluate gold data metrics.
function testGoldMetricsEvaluatesGold(testCase)
    reg.loadGold('');
    reg.evalPerLabel([], []);
    testCase.assumeFail('Not implemented yet');
end
