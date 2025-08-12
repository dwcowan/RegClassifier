%% NAME-REGISTRY:TEST testMetricsExpectedJSON
function tests = testMetricsExpectedJSON
%TESTMETRICSEXPECTEDJSON Placeholder tests for metrics JSON comparison.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(testCase)
    reg.evalRetrieval(table(), table());
    testCase.assumeFail('Not implemented yet');
end
