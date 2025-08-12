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
    [oldPathStr, newPathStr] = minimalVersionPaths();
    diffStruct = reg.crrDiffVersions(oldPathStr, newPathStr);
    testCase.verifyClass(diffStruct, 'struct');

    [articleIdStr, versionAStr, versionBStr] = minimalArticleInputs();
    articleStruct = reg.crrDiffArticles(articleIdStr, versionAStr, versionBStr);
    testCase.verifyClass(articleStruct, 'struct');
end

function [oldPathStr, newPathStr] = minimalVersionPaths()
    oldPathStr = "";
    newPathStr = "";
end

function [articleIdStr, versionAStr, versionBStr] = minimalArticleInputs()
    articleIdStr = "";
    versionAStr = "";
    versionBStr = "";
end
