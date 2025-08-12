%% NAME-REGISTRY:TEST testFineTuneResumePersistsState
function tests = testFineTuneResumePersistsState
%TESTFINETUNERESUMEPERSISTSSTATE Verify fine-tune resume persists training state.
%   Each local test must assign Tags per the test style guide.
%
% Outputs
%   tests - handle to local tests
%
tests = functiontests(localfunctions);
tests(1).Tags = {'Integration'}; % testPersistsState
end

function testPersistsState(testCase)
    dsStruct = minimalDatasetStruct();
    encoderStruct = reg.ftTrainEncoder(dsStruct);
    testCase.verifyClass(encoderStruct, 'struct');
    testCase.assumeFail('Not implemented yet');
end

function dsStruct = minimalDatasetStruct()
    dsStruct = struct();
end
