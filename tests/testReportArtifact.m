%% NAME-REGISTRY:TEST testReportArtifact
function tests = testReportArtifact
%TESTREPORTARTIFACT Tests for report generation.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testGeneratesFile
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
