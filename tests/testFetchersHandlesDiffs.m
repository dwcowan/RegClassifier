%% NAME-REGISTRY:TEST testFetchersHandlesDiffs
function testFetchersHandlesDiffs(testCase)
%TESTFETCHERSHANDLESDIFFS Ensure diff fetch utilities run without errors.
    [oldPathStr, newPathStr] = minimalVersionPaths();
    diffStruct = reg.crrDiffVersions(oldPathStr, newPathStr);
    testCase.verifyClass(diffStruct, 'struct');

    [articleIdStr, versionAStr, versionBStr] = minimalArticleInputs();
    articleStruct = reg.crrDiffArticles(articleIdStr, versionAStr, versionBStr);
    testCase.verifyClass(articleStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
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
