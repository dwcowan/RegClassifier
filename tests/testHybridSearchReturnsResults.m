%% NAME-REGISTRY:TEST testHybridSearchReturnsResults
function testHybridSearchReturnsResults(testCase)
%TESTHYBRIDSEARCHRETURNSRESULTS Ensure hybrid search returns results.
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
