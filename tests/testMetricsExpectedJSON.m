%% NAME-REGISTRY:TEST testMetricsExpectedJSON
function tests = testMetricsExpectedJSON
%TESTMETRICSEXPECTEDJSON Placeholder tests for metrics JSON comparison.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%% NAME-REGISTRY:TEST testMetricsExpectedJSONMatchesSchema
function testMetricsExpectedJSONMatchesSchema(testCase)
%TESTMETRICSEXPECTEDJSONMATCHESSCHEMA Confirm metrics JSON matches expected schema.
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
