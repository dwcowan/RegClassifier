%% NAME-REGISTRY:TEST testReportArtifactGeneratesReport
function tests = testReportArtifactGeneratesReport
%TESTREPORTARTIFACTGENERATESREPORT Generate evaluation report artifact.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testGeneratesReport
end

function testGeneratesReport(testCase)
    import tests.fixtures.EnvironmentFixture
    testCase.applyFixture(EnvironmentFixture);
    resultsTbl = minimalResultsTbl();
    goldTbl = minimalGoldTbl();
    metricsStruct = reg.evalRetrieval(resultsTbl, goldTbl);
    testCase.verifyClass(metricsStruct, 'struct');
    testCase.verifyNotEmpty(fieldnames(metricsStruct));
end

function resultsTbl = minimalResultsTbl()
    resultsTbl = table("doc", 'VariableNames', "document");
end

function goldTbl = minimalGoldTbl()
    goldTbl = table("doc", 'VariableNames', "document");
end
