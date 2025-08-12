%% NAME-REGISTRY:TEST testProjectionHeadSimulated
function tests = testProjectionHeadSimulated
%TESTPROJECTIONHEADSIMULATED Placeholder tests for projection head training.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTPROJECTIONHEADSIMULATEDTRAINSHEAD Check projection head training pathway.
function testProjectionHeadSimulatedTrainsHead(testCase)
    [xMat, yMat] = minimalTrainingMats();
    headStruct = reg.trainProjectionHead(xMat, yMat);
    testCase.verifyClass(headStruct, 'struct');
end

function [xMat, yMat] = minimalTrainingMats()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
