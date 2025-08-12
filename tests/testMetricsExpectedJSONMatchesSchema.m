%% NAME-REGISTRY:TEST testMetricsExpectedJSONMatchesSchema
function tests = testMetricsExpectedJSONMatchesSchema
%TESTMETRICSEXPECTEDJSONMATCHESSCHEMA Confirm metrics JSON matches expected schema.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Regression'}; % testMatchesSchema
end

function testMatchesSchema(testCase)
    resultsTbl = minimalResultsTbl();
    goldTbl = minimalGoldTbl();
    metricsStruct = reg.evalRetrieval(resultsTbl, goldTbl);
    testCase.verifyClass(metricsStruct, 'struct');
    testCase.fatalAssertFail('Not implemented yet');
end

function resultsTbl = minimalResultsTbl()
    resultsTbl = table();
end

function goldTbl = minimalGoldTbl()
    goldTbl = table();
end
