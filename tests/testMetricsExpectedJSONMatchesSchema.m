%% NAME-REGISTRY:TEST testMetricsExpectedJSONMatchesSchema
function testMetricsExpectedJSONMatchesSchema(testCase)
%TESTMETRICSEXPECTEDJSONMATCHESSCHEMA Confirm metrics JSON matches expected schema.
    resultsTbl = minimalResultsTbl();
    goldTbl = minimalGoldTbl();
    metricsStruct = reg.evalRetrieval(resultsTbl, goldTbl);
    testCase.verifyClass(metricsStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
end

function resultsTbl = minimalResultsTbl()
    resultsTbl = table();
end

function goldTbl = minimalGoldTbl()
    goldTbl = table();
end
