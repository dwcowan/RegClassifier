%% NAME-REGISTRY:TEST testRegressionMetricsSimulated
function tests = testRegressionMetricsSimulated
%TESTREGRESSIONMETRICSSIMULATED Placeholder tests for regression metrics.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.trainMultilabel([], []);
    reg.evalPerLabel([], []);
    assert(false, 'Not implemented yet');
end
