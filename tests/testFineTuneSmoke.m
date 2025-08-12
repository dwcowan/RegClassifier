%% NAME-REGISTRY:TEST testFineTuneSmoke
function tests = testFineTuneSmoke
%TESTFINETUNESMOKE Placeholder tests for encoder fine-tuning smoke test.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTFINETUNESMOKERUNSENDTOEND Run encoder fine-tuning end-to-end.
function testFineTuneSmokeRunsEndToEnd(testCase)
    chunkTbl = minimalChunkTbl();
    yMat = zeros(0, 0);
    dsStruct = reg.ftBuildContrastiveDataset(chunkTbl, yMat);
    testCase.verifyClass(dsStruct, 'struct');

    encoderStruct = reg.ftTrainEncoder(dsStruct);
    testCase.verifyClass(encoderStruct, 'struct');
end

function chunkTbl = minimalChunkTbl()
    chunkTbl = table();
end
