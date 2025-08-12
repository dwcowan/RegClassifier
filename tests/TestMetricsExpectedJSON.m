%% NAME-REGISTRY:TEST TestMetricsExpectedJSON
function tests = TestMetricsExpectedJSON
%TESTMETRICSEXPECTEDJSON Placeholder tests for metrics JSON comparison.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.evalRetrieval(table(), table());
    assert(false, 'Not implemented yet');
end
