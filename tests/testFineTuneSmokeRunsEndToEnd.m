%% NAME-REGISTRY:TEST testFineTuneSmokeRunsEndToEnd
function tests = testFineTuneSmokeRunsEndToEnd
%TESTFINETUNESMOKERUNSENDTOEND Run encoder fine-tuning end-to-end.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testRunsEndToEnd
end

function testRunsEndToEnd(testCase)
    chunkTbl = minimalChunkTbl();
    yMat = zeros(0, 0);
    dsStruct = reg.ftBuildContrastiveDataset(chunkTbl, yMat);
    testCase.verifyClass(dsStruct, 'struct');

    encoderStruct = reg.ftTrainEncoder(dsStruct);
    testCase.verifyClass(encoderStruct, 'struct');
    testCase.fatalAssertFail('Not implemented yet');
end

function chunkTbl = minimalChunkTbl()
    chunkTbl = table();
end
