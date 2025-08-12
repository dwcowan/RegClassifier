%% NAME-REGISTRY:TEST TestFetchers
function tests = TestFetchers
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
