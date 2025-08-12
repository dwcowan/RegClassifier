%% NAME-REGISTRY:TEST testFineTuneSmokeRunsEndToEnd
function testFineTuneSmokeRunsEndToEnd(testCase)
%TESTFINETUNESMOKERUNSENDTOEND Run encoder fine-tuning end-to-end.
    chunkTbl = minimalChunkTbl();
    yMat = zeros(0, 0);
    dsStruct = reg.ftBuildContrastiveDataset(chunkTbl, yMat);
    testCase.verifyClass(dsStruct, 'struct');

    encoderStruct = reg.ftTrainEncoder(dsStruct);
    testCase.verifyClass(encoderStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
end

function chunkTbl = minimalChunkTbl()
    chunkTbl = table();
end
