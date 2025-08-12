%% NAME-REGISTRY:TEST testProjectionAutoloadPipeline
function tests = testProjectionAutoloadPipeline
%TESTPROJECTIONAUTOLOADPIPELINE Placeholder tests for projection head autoloading.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%% NAME-REGISTRY:TEST testProjectionAutoloadPipelineLoadsHead
function testProjectionAutoloadPipelineLoadsHead(testCase)
%TESTPROJECTIONAUTOLOADPIPELINELOADSHEAD Ensure projection head autoloads correctly.
    [xMat, yMat] = minimalTrainingMats();
    headStruct = reg.trainProjectionHead(xMat, yMat);
    testCase.verifyClass(headStruct, 'struct');
end

function [xMat, yMat] = minimalTrainingMats()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
