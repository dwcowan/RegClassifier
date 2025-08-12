%% NAME-REGISTRY:TEST testReportArtifact
function tests = testReportArtifact
%TESTREPORTARTIFACT Placeholder tests for report generation.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%% NAME-REGISTRY:TEST testReportArtifactGeneratesReport
function testReportArtifactGeneratesReport(testCase)
%TESTREPORTARTIFACTGENERATESREPORT Generate evaluation report artifact.
    resultsTbl = minimalResultsTbl();
    goldTbl = minimalGoldTbl();
    metricsStruct = reg.evalRetrieval(resultsTbl, goldTbl);
    testCase.verifyClass(metricsStruct, 'struct');
end

function resultsTbl = minimalResultsTbl()
    resultsTbl = table();
end

function goldTbl = minimalGoldTbl()
    goldTbl = table();
end
