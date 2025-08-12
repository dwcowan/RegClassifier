%% NAME-REGISTRY:TEST testFetchersHandlesDiffs
function testFetchersHandlesDiffs(testCase)
%TESTFETCHERSHANDLESDIFFS Ensure diff fetch utilities run without errors.
    import tests.fixtures.EnvironmentFixture
    testCase.applyFixture(EnvironmentFixture);
    [oldPathStr, newPathStr] = minimalVersionPaths();
    diffStruct = reg.crrDiffVersions(oldPathStr, newPathStr);
    testCase.verifyClass(diffStruct, 'struct');
    testCase.verifyNotEmpty(fieldnames(diffStruct));

    [articleIdStr, versionAStr, versionBStr] = minimalArticleInputs();
    articleStruct = reg.crrDiffArticles(articleIdStr, versionAStr, versionBStr);
    testCase.verifyClass(articleStruct, 'struct');
    testCase.verifyNotEmpty(fieldnames(articleStruct));
end

function [oldPathStr, newPathStr] = minimalVersionPaths()
    oldPathStr = "old";
    newPathStr = "new";
end

function [articleIdStr, versionAStr, versionBStr] = minimalArticleInputs()
    articleIdStr = "1";
    versionAStr = "a";
    versionBStr = "b";
end
