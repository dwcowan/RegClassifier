%% NAME-REGISTRY:TEST testFineTuneResume
function tests = testFineTuneResume
%TESTFINETUNERESUME Placeholder tests for encoder fine-tuning resume.
%
% Outputs
%   tests - handle to local tests

tests = functiontests(localfunctions);
end

%TESTFINETUNERESUMEPERSISTSSTATE Verify fine-tune resume persists training state.
function testFineTuneResumePersistsState(testCase)
    reg.ftTrainEncoder(struct());
    testCase.assumeFail('Not implemented yet');
end
