%% NAME-REGISTRY:TEST testFetchers
function tests = testFetchers
%TESTFETCHERS Tests for data fetch utilities.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testDiffFunctionsReturnStructs(testCase)
    import tests.fixtures.EnvironmentFixture
    testCase.applyFixture(EnvironmentFixture);
    diffStruct = reg.crrDiffVersions("old", "new");
    verifyClass(testCase, diffStruct, 'struct');
    verifyNotEmpty(testCase, fieldnames(diffStruct));

    articleStruct = reg.crrDiffArticles("1", "a", "b");
    verifyClass(testCase, articleStruct, 'struct');
    verifyNotEmpty(testCase, fieldnames(articleStruct));
end
