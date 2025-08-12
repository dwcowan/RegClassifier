%% NAME-REGISTRY:TEST testHybridSearch
function tests = testHybridSearch
%TESTHYBRIDSEARCH Tests for hybrid search module.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testReturnsResults(testCase)
    import tests.fixtures.EnvironmentFixture
    testCase.applyFixture(EnvironmentFixture);
    queryStr = "query";
    xMat = rand(1, 3);
    docTbl = table("doc", 'VariableNames', "text");
    resultsTbl = reg.hybridSearch(queryStr, xMat, docTbl);
    verifyGreaterThan(testCase, height(resultsTbl), 0);
end
