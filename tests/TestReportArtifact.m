%% NAME-REGISTRY:TEST TestReportArtifact
function tests = TestReportArtifact
%TESTREPORTARTIFACT Placeholder tests for report generation.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.evalRetrieval(table(), table());
    assert(false, 'Not implemented yet');
end
