%% NAME-REGISTRY:TEST testFineTuneResumePersistsState
function testFineTuneResumePersistsState(testCase)
%TESTFINETUNERESUMEPERSISTSSTATE Verify fine-tune resume persists training state.
    dsStruct = minimalDatasetStruct();
    encoderStruct = reg.ftTrainEncoder(dsStruct);
    testCase.verifyClass(encoderStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
end

function dsStruct = minimalDatasetStruct()
    dsStruct = struct();
end
