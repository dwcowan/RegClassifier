%% NAME-REGISTRY:TEST testReportArtifact
function tests = testReportArtifact
%TESTREPORTARTIFACT Tests for report generation.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testGeneratesFile(testCase)
    import tests.fixtures.EnvironmentFixture
    testCase.applyFixture(EnvironmentFixture);
    resultsTbl = table("doc", 'VariableNames', "document");
    goldTbl = table("doc", 'VariableNames', "document");
    reportPathStr = fullfile(tempdir, "report.html");
    reg.reportArtifact(resultsTbl, goldTbl, reportPathStr);
    verifyTrue(testCase, isfile(reportPathStr));
end
