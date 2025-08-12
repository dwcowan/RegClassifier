%% NAME-REGISTRY:TEST testProjectionAutoloadPipelineLoadsHead
function testProjectionAutoloadPipelineLoadsHead(testCase)
%TESTPROJECTIONAUTOLOADPIPELINELOADSHEAD Ensure projection head autoloads correctly.
    [xMat, yMat] = minimalTrainingMats();
    headStruct = reg.trainProjectionHead(xMat, yMat);
    testCase.verifyClass(headStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
end

function [xMat, yMat] = minimalTrainingMats()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
