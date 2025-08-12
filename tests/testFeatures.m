%% NAME-REGISTRY:TEST testFeatures
function tests = testFeatures
%TESTFEATURES Tests for embedding generation.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

function testEmbeddingOutputs(testCase)
    testCase.applyFixture(fixtures.EnvironmentFixture);
    chunkTbl = table();

    xMat = reg.docEmbeddingsBertGpu(chunkTbl);
    verifyClass(testCase, xMat, 'double');
    verifySize(testCase, xMat, [height(chunkTbl), 0]);

    xMatPre = reg.precomputeEmbeddings(chunkTbl);
    verifyClass(testCase, xMatPre, 'double');
    verifyEqual(testCase, xMatPre, xMat);
end
