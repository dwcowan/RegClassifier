%% NAME-REGISTRY:TEST testHybridSearchReturnsResults
function tests = testHybridSearchReturnsResults
%TESTHYBRIDSEARCHRETURNSRESULTS Ensure hybrid search returns results.
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
    [queryStr, xMat, docTbl] = minimalHybridInputs();
    resultsTbl = reg.hybridSearch(queryStr, xMat, docTbl);
    testCase.verifyClass(resultsTbl, 'table');
    testCase.verifyGreaterThan(height(resultsTbl), 0);
end

function [queryStr, xMat, docTbl] = minimalHybridInputs()
    queryStr = "query";
    xMat = rand(1, 3);
    docTbl = table("doc", 'VariableNames', "text");
end
