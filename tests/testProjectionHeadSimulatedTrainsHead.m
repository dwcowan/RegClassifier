%% NAME-REGISTRY:TEST testProjectionHeadSimulatedTrainsHead
function tests = testProjectionHeadSimulatedTrainsHead
%TESTPROJECTIONHEADSIMULATEDTRAINSHEAD Check projection head training pathway.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testTrainsHead
end

function testTrainsHead(testCase)
    [xMat, yMat] = minimalTrainingMats();
    headStruct = reg.trainProjectionHead(xMat, yMat);
    testCase.verifyClass(headStruct, 'struct');
    testCase.fatalAssertFail('Not implemented yet');
end

function [xMat, yMat] = minimalTrainingMats()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
