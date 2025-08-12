%% NAME-REGISTRY:TEST testFetchers
function tests = testFetchers
%TESTFETCHERS Placeholder tests for data fetch utilities.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTFETCHERSHANDLESDIFFS Ensure diff fetch utilities run without errors.
function testFetchersHandlesDiffs(testCase)
    reg.crrDiffVersions('', '');
    reg.crrDiffArticles('', '', '');
    testCase.assumeFail('Not implemented yet');
end
