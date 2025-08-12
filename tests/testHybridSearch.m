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
    reg.hybridSearch('', [], table());
    testCase.assumeFail('Not implemented yet');
end
