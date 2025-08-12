%% NAME-REGISTRY:TEST testHybridSearch
function tests = testHybridSearch
%TESTHYBRIDSEARCH Placeholder tests for hybrid search module.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTHYBRIDSEARCHRETURNSRESULTS Ensure hybrid search returns results.
function testHybridSearchReturnsResults(testCase)
    [queryStr, xMat, docTbl] = minimalHybridInputs();
    resultsTbl = reg.hybridSearch(queryStr, xMat, docTbl);
    testCase.verifyClass(resultsTbl, 'table');
end

function [queryStr, xMat, docTbl] = minimalHybridInputs()
    queryStr = "";
    xMat = zeros(0, 0);
    docTbl = table();
end
