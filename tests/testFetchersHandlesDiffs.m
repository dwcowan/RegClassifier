%% NAME-REGISTRY:TEST testFetchersHandlesDiffs
function tests = testFetchersHandlesDiffs
%TESTFETCHERSHANDLESDIFFS Ensure diff fetch utilities run without errors.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testHandlesDiffs
end

function testHandlesDiffs(testCase)
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
