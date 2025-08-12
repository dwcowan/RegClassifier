%% NAME-REGISTRY:TEST testProjectionHeadSimulatedTrainsHead
function testProjectionHeadSimulatedTrainsHead(testCase)
%TESTPROJECTIONHEADSIMULATEDTRAINSHEAD Check projection head training pathway.
    [xMat, yMat] = minimalTrainingMats();
    headStruct = reg.trainProjectionHead(xMat, yMat);
    testCase.verifyClass(headStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
end

function [xMat, yMat] = minimalTrainingMats()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
