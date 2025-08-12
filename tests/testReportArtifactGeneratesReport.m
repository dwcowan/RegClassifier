%% NAME-REGISTRY:TEST testReportArtifactGeneratesReport
function testReportArtifactGeneratesReport(testCase)
%TESTREPORTARTIFACTGENERATESREPORT Generate evaluation report artifact.
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
