%% NAME-REGISTRY:TEST TestGoldMetrics
function tests = TestGoldMetrics
%TESTGOLDMETRICS Placeholder tests for gold data metrics.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.loadGold('');
    reg.evalPerLabel([], []);
    assert(false, 'Not implemented yet');
end
