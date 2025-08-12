%% NAME-REGISTRY:TEST testReportArtifact
function tests = testReportArtifact
%TESTREPORTARTIFACT Placeholder tests for report generation.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTREPORTARTIFACTGENERATESREPORT Generate evaluation report artifact.
function testReportArtifactGeneratesReport(testCase)
    reg.evalRetrieval(table(), table());
    testCase.assumeFail('Not implemented yet');
end
