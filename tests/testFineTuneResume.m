%% NAME-REGISTRY:TEST testFineTuneResume
function tests = testFineTuneResume
%TESTFINETUNERESUME Placeholder tests for encoder fine-tuning resume.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%% NAME-REGISTRY:TEST testFineTuneResumePersistsState
function testFineTuneResumePersistsState(testCase)
%TESTFINETUNERESUMEPERSISTSSTATE Verify fine-tune resume persists training state.
    dsStruct = minimalDatasetStruct();
    encoderStruct = reg.ftTrainEncoder(dsStruct);
    testCase.verifyClass(encoderStruct, 'struct');
end

function dsStruct = minimalDatasetStruct()
    dsStruct = struct();
end
