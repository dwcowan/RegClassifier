%% NAME-REGISTRY:TEST testRulesAndModelTrainsModel
function tests = testRulesAndModelTrainsModel
%TESTRULESANDMODELTRAINSMODEL Train weak rules and baseline model.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testTrainsModel
end

function testTrainsModel(testCase)
    chunkTbl = minimalChunkTbl();
    yBootMat = reg.weakRules(chunkTbl);
    testCase.verifyTrue(issparse(yBootMat));

    [xMat, yMat] = minimalTrainingData();
    modelStruct = reg.trainMultilabel(xMat, yMat);
    testCase.verifyClass(modelStruct, 'struct');
    testCase.fatalAssertFail('Not implemented yet');
end

function chunkTbl = minimalChunkTbl()
    chunkTbl = table();
end

function [xMat, yMat] = minimalTrainingData()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
