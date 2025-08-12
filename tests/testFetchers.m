%% NAME-REGISTRY:TEST testFetchers
function tests = testFetchers
%TESTFETCHERS Placeholder tests for data fetch utilities.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testPlaceholder(~)
    reg.crrDiffVersions('', '');
    reg.crrDiffArticles('', '', '');
    assert(false, 'Not implemented yet');
end
