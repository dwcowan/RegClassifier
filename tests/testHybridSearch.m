%% NAME-REGISTRY:TEST testHybridSearch
function tests = testHybridSearch
%TESTHYBRIDSEARCH Tests for hybrid search module.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Unit'}; % testReturnsResults
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
