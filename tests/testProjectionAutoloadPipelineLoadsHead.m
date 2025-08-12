%% NAME-REGISTRY:TEST testProjectionAutoloadPipelineLoadsHead
function tests = testProjectionAutoloadPipelineLoadsHead
%TESTPROJECTIONAUTOLOADPIPELINELOADSHEAD Ensure projection head autoloads correctly.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testLoadsHead
end

function testLoadsHead(testCase)
    [xMat, yMat] = minimalTrainingMats();
    headStruct = reg.trainProjectionHead(xMat, yMat);
    testCase.verifyClass(headStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
end

function [xMat, yMat] = minimalTrainingMats()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
