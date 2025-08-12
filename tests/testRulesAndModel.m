%% NAME-REGISTRY:TEST testRulesAndModel
function tests = testRulesAndModel
%TESTRULESANDMODEL Placeholder tests for weak rules and model training.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTRULESANDMODELTRAINSMODEL Train weak rules and baseline model.
function testRulesAndModelTrainsModel(testCase)
    chunkTbl = minimalChunkTbl();
    yBootMat = reg.weakRules(chunkTbl);
    testCase.verifyTrue(issparse(yBootMat));

    [xMat, yMat] = minimalTrainingData();
    modelStruct = reg.trainMultilabel(xMat, yMat);
    testCase.verifyClass(modelStruct, 'struct');
end

function chunkTbl = minimalChunkTbl()
    chunkTbl = table();
end

function [xMat, yMat] = minimalTrainingData()
    xMat = zeros(0, 0);
    yMat = zeros(0, 0);
end
