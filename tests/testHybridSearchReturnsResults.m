%% NAME-REGISTRY:TEST testHybridSearchReturnsResults
function testHybridSearchReturnsResults(testCase)
%TESTHYBRIDSEARCHRETURNSRESULTS Ensure hybrid search returns results.
    [queryStr, xMat, docTbl] = minimalHybridInputs();
    resultsTbl = reg.hybridSearch(queryStr, xMat, docTbl);
    testCase.verifyClass(resultsTbl, 'table');
    testCase.assumeFail('Not implemented yet');
end

function [queryStr, xMat, docTbl] = minimalHybridInputs()
    queryStr = "";
    xMat = zeros(0, 0);
    docTbl = table();
end
